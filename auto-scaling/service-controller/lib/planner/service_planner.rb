require 'rubygems'
require 'logger'

require 'executor/service_executor'

module AutoScaling
  class InsufficientResources < Exception
  end

  class ServicePlanner

    @@logger = Logger.new(STDOUT)

    def initialize(executor, cloud_controller)
      @executor = executor
      @cloud_controller = cloud_controller
    end

    def plan_deployment(service)
      @@logger.debug "Planning deployment of a #{service}"
      # are there enough resources?

      # reserve resources

      # deploy
      @executor.deploy_service service
    end

    # Analyzes data using supplied model
    #
    # * *Args* :
    # - +data+ -> hashmap that contains analysis conclusions
    # {
    #   stack => [:insufficient_slaves, :overloaded_master],
    #   stack => [:healthy]
    # }
    #
    def plan(data)
      @@logger.debug "Planning actions based on data #{data}"

      data.each do |stack, conclusions|
        conclusions.each do |conclusion|
          begin
            self.send(conclusion, stack)
          rescue InsufficientResources => msg
            @@logger.info msg
            @@logger.info 'Delegating execution to a cloud-controller'

            @cloud_controller.forward stack
          end
        end
      end
    end

    private
    def insufficient_slaves(stack)
      # TODO reserve resources
      if !@executor.reserve?(stack)
        raise InsufficientResources.new("There is not enough resources to deploy a stack: #{stack}")
      end

      @executor.deploy_container(stack)
    end

    def redundant(stack)
      # TODO free resources

      @executor.delete_container(stack)
    end

    def overloaded_master(stack)
      @@logger.warn "Stack #{stack} has overloaded master. Currently, nothing can be done"
    end

    def healthy(stack)
      @@logger.info "Stack #{stack} is healthy. Ignoring"
    end

  end
end