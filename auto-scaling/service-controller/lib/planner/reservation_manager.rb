require 'thread'

module AutoScaling

  class InsufficientResources < Exception
  end

  class ReservationManager

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
            raise InsufficientResources.new("Cannot reserve: #{units} with #{@capacity}")
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