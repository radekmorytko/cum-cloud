require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'utils'
require 'planner/service_planner'

module AutoScaling

  class ServicePlannerTest < Test::Unit::TestCase

    def setup
      @executor = mock()

      @planner = ServicePlanner.new @executor
    end

    def teardown

    end

    def test_shall_plan_service_deployment
      service = {
          'stack' => 'java',
          'instances' => 2,
          'name' => 'enterprise-app'
      }
      @executor.expects(:deploy_service).with(service, {})

      @planner.plan_deployment(service, {})
    end

    def test_shall_plan_appropriate_executor_actions
      stack_1 = mock()
      stack_2 = mock()

      data = {
        stack_1 => [:insufficient_slaves, :overloaded_master],
        mock() => [:healthy],
        stack_2 => [:redundant]
      }

      @executor.expects(:deploy_container).with(stack_1)
      @executor.expects(:delete_container).with(stack_2)

      @planner.plan(data)
    end

  end

end