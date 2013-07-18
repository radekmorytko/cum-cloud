require 'rubygems'
require 'logger'

require 'models/executor/service_executor'

module AutoScaling
  class ServicePlanner

    def initialize(executor)
      @executor = executor
    end

    def plan(service)
      # are there enough resources?

      # reserve resources

      # deploy
      @executor.deploy_service service
    end
  end
end