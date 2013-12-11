require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'utils'
require 'planner/stack_planner'

module AutoScaling

  class StackPlannerTest < Test::Unit::TestCase

    def setup
      @executor = mock()
      @cloud_controller = mock()
      @reservation_manager = mock()

      @planner = StackPlanner.new(@executor, @cloud_controller, @reservation_manager)
    end

    def test_shall_plan_service_deployment
      service = {
          'stack' => 'java',
          'instances' => 2,
          'name' => 'enterprise-app'
      }
      @executor.expects(:deploy_stack).with(service)

      @planner.plan_deployment(service)
    end

    def test_shall_plan_appropriate_executor_actions
      stack_1 = mock()
      stack_2 = mock()
      stack_1.expects(:type).returns(:java)
      stack_2.expects(:type).returns(:java)

      data = {
        stack_1 => [:insufficient_slaves, :overloaded_master],
        mock() => [:healthy],
        stack_2 => [:redundant]
      }

      @reservation_manager.expects(:resources).with(:java).returns(:cpu => 5, :memory => 5)
      @reservation_manager.expects(:reserve).with(:cpu => 5, :memory => 5).returns(true)
      @executor.expects(:deploy_container).with(stack_1)
      @reservation_manager.expects(:resources).with(:java).returns(:cpu => 5, :memory => 5)
      @reservation_manager.expects(:free).with(:cpu => 5, :memory => 5)
      @executor.expects(:delete_container).with(stack_2)

      @planner.plan(data)
    end

    def test_shall_delegate_to_cloud_controller
      stack_1 = mock()
      stack_1.expects(:type).returns(:java)
      data = {
          stack_1 => [:insufficient_slaves],
      }

      @reservation_manager.expects(:resources).with(:java).returns(:cpu => 5, :memory => 5)
      @reservation_manager.expects(:reserve).with(:cpu => 5, :memory => 5).raises(InsufficientResources)
      @cloud_controller.expects(:forward).with(:insufficient_slaves, stack_1)

      @planner.plan(data)
    end

  end

end