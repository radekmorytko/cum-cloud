require 'rubygems'
require 'logger'

module AutoScaling
  class ServicePlanner

    def initialize(executor)
      @planner = executor
    end

    def plan(service)
      # are there enough resources?

      # reserve resources

      # deploy
      @planner.deploy_service service
    end
  end
end