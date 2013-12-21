require 'thread'

module AutoScaling

  class InsufficientResources < Exception
  end

  class ReservationManager

    @@logger       = Logger.new(STDOUT)

    def initialize(cloud_provider, capacity = {}, requirements = {})
      # map that stores available resources, e.g. {:cpu => 4, :memory => 3}
      # note:
      # - currently units are ignored
      # - reservation is in fact approximation - we don't known at this stage how cloud-provider scheduler
      #   behaves, hence, it we can't predict if resources are in fact sufficient
      if capacity == {}
        @capacity = cloud_provider.capacity()
      else
        @capacity = capacity
      end

      @reservation = Mutex.new
      @requirements = requirements
      @cloud_provider = cloud_provider

      @@logger.debug "ReservationManager instantiated with #{@requirements} and #{@cloud_provider}"
    end

    # Checks required resources for a given stack
    #
    # * *Args* :
    # - +stack+ -> hashmap of resources to be reserved
    # * *Returns* :
    # {
    #   :cpu => 0.3,      [vcpus]
    #   :memory => 256    [MBs]
    # }
    def resources(stack_type)
      requirements = @requirements[stack_type.to_s]['requirements']
      Hash[requirements.map(){|key, value| [key.to_sym(), value.to_f] }]
    end

    # Checks if resource reservation is possible
    #
    # * *Args* :
    # - +unit+ -> hashmap of resources to be reserved
    # {
    #   :cpu => 2,
    #   :memory => 3
    # }
    def reserve?(stack_data)
      needs = resources(stack_data['type'])
      needs.each {|k, v| needs[k] = v * stack_data['instances'].to_i}

      needs.each do |key, value|
        return false if @capacity[key] < value
      end

      return true
    end

    def scale_up(container, parameter, requested)
      @reservation.synchronize do
        host = @cloud_provider.host_by_container(container.correlation_id)
        current_state = @cloud_provider.monitor_host(host)

        if current_state[parameter] < requested then
          raise InsufficientResources.new("CONTAINER Cannot reserve: #{requested} with #{current_state} at #{host}")
          return
        end

        current = container.requirements[parameter.to_s]
        @capacity[parameter] -= (requested - current)
        container.requirements[parameter.to_s] = requested
        container.save
      end
    end

    # Reserves resources
    #
    # * *Args* :
    # - +unit+ -> hashmap of resources to be reserved
    # {
    #   :cpu => 2,
    #   :memory => 3
    # }
    def reserve(units)
      @reservation.synchronize do
        backup = @capacity.clone

        units.each do |key, value|
          if @capacity[key] < value then
            @capacity = backup
            raise InsufficientResources.new("STACK Cannot reserve: #{units} with #{@capacity}")
          end

          @capacity[key] -= value
        end
      end
    end

    def free(units)
      @reservation.synchronize do
        units.each { |key, value| @capacity[key] += value }
      end
    end

  end
end