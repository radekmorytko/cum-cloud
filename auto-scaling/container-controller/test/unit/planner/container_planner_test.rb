require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'utils'
require 'planner/container_planner'

module AutoScaling

  class ContainerPlannerTest < Test::Unit::TestCase

    def setup
      Utils::setup_database
      @executor = mock()
      @stack_controller = mock()
      @reservation_manager = mock()

      @planner = ContainerPlanner.new(@executor, @reservation_manager)
    end

    def test_shall_properly_plan_actions
      container = mock()
      container.expects(:requirements).returns({'cpu' => 1, 'memory' => 1000}).twice
      data = {
          :container => container,
          :conclusions => [:insufficient_cpu, :insufficient_memory]
      }

      @executor.expects(:increase_cpu).with(container)
      @reservation_manager.expects(:scale_up).with(container, :cpu, 1.3)

      @executor.expects(:increase_memory).with(container)
      @reservation_manager.expects(:scale_up).with(container, :memory, 1300)

      @planner.plan(data)
    end

    def test_shall_delegate_when_insufficient_resources
      container = mock()
      container.expects(:requirements).returns({'cpu' => 1, 'memory' => 1000})
      data = {
          :container => container,
          :conclusions => [:insufficient_cpu]
      }

      @reservation_manager.expects(:scale_up).with(container, :cpu, 1.3).raises(InsufficientResources)

      @planner.plan(data)
      assert_equal true, @planner.conclusions.include?({:container => container, :conclusion => :insufficient_cpu})
    end

  end

end
