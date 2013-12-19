require 'rubygems'
require 'logger'
require 'set'

require 'common/common'
require 'executor/container_executor'
require 'domain/domain'


module AutoScaling
  class ContainerPlanner

    @@logger = Logger.new(STDOUT)

    attr_accessor :stack_controller

    def initialize(executor, reservation_manager)
      @executor = executor
      @reservation_manager = reservation_manager
    end

    # Plans actions that aims to scale container up
    #
    # * *Args* :
    # {
    #   :container => container,
    #   :conclusions => [:insufficient_cpu, :insufficient_memory]
    # }
    def plan(data)
      @@logger.debug "Planning actions based on data #{data}"

      container = data[:container]
      data[:conclusions].each do |conclusion|
        begin
          self.send(conclusion, container)
        rescue InsufficientResources => msg
          @@logger.info msg
          @@logger.info "Leaving a problem #{conclusion} on #{container} to a stack-controller"

          @stack_controller.forward(conclusion, container)
        end
      end
    end

    private
    def insufficient_cpu(container)
      @@logger.debug "Attempt to scale CPU up for a container: #{container}"
      scaled = scale_up(container, 'cpu')

      @reservation_manager.scale_up(container, :cpu, scaled)
      @executor.increase_cpu(container, scaled)
    end

    def insufficient_memory(container)
      @@logger.debug "Attempt to scale MEMORY up for a container: #{container}"
      scaled = scale_up(container, 'memory')

      @reservation_manager.scale_up(container, :memory, scaled)
      @executor.increase_memory(container, scaled)
    end


    def redundant_cpu(container)
      @@logger.debug "Redundant cpu #{container}: ignoring"
    end

    def redundant_memory(container)
      @@logger.debug "Redundant memory #{container}: ignoring"
    end

    def scale_up(container, resource)
      requirements = container.requirements
      requirements[resource] * 1.3
    end

  end
end
