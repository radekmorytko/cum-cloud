require 'rubygems'
require 'logger'
require 'set'

require 'common/common'
require 'executor/container_executor'
require 'domain/domain'


module AutoScaling
  class ContainerPlanner

    @@logger = Logger.new(STDOUT)

    attr_reader :conclusions

    def initialize(executor, reservation_manager)
      @executor = executor
      @reservation_manager = reservation_manager
      @conclusions = []
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

          @conclusions << {:conclusion => conclusion, :container => container}
        end
      end
    end

    private
    def insufficient_cpu(container)
      @@logger.debug "Attempt to scale CPU up for container: #{container}"
      @reservation_manager.scale_up(container, :cpu)
      @executor.increase_cpu(container)
    end

    def insufficient_memory(container)
      @@logger.debug "Attempt to scale MEMORY up for container: #{container}"
      @reservation_manager.scale_up(container, :memory)
      @executor.increase_memory(container)
    end

  end
end
