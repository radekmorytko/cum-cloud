require 'rubygems'
require 'logger'

require 'executor/service_executor'

module AutoScaling
  class ServicePlanner

    @@logger = Logger.new(STDOUT)

    def initialize(executor)
      @executor = executor
    end

    def plan_deployment(service)
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
      data.each do |stack, conclusions|
        conclusions.each do |conclusion|
          self.send(conclusion, stack)
        end
      end
    end

    private
    def insufficient_slaves(stack)
      # TODO reserve resources

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