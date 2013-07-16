require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'planner/service_planner'

module AutoScaling

  class ServicePlannerTest < Test::Unit::TestCase

    def setup
      @executor = mock()

      @planner = ServicePlanner.new @executor
    end

    def teardown
    end

    # Fake test
    def test_plan
      service = {
          :stack => :java,
          :instances => 2,
          :name => 'enterprise-app'
      }
      @executor.expects(:deploy_service).with(service)

      @planner.plan service
    end
  end

end