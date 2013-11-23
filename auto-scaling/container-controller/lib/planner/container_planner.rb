require 'rubygems'
require 'logger'
require 'set'

require 'models/models'

module AutoScaling
  class ContainerPlanner

    @@logger = Logger.new(STDOUT)

    def initialize(executor, service_controller)
      @executor = executor
      @service_controller = service_controller
    end

    def monitor(data)
      @@logger.debug "Planning actions based on data #{data}"

      data = {}
      data
    end

  end
end
