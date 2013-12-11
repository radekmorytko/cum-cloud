require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'utils'
require 'stack-controller/stack_controller'

module AutoScaling

  class StackControllerTest < Test::Unit::TestCase

    def setup
      @monitor, @analyzer, @planner = mock(), mock(), mock()
      @scheduler = Rufus::Scheduler.new

      @controller = StackController.new @monitor, @analyzer, @planner, @scheduler
    end

    def test_shall_perform_full_cycle
      service = mock()
      monitoring_data, conclusions = mock(), mock()

      @monitor.expects(:monitor).with(service).returns(monitoring_data)
      @analyzer.expects(:analyze).with(monitoring_data).returns(conclusions)
      @planner.expects(:plan).with(conclusions)

      scheduled_job = @controller.schedule service, '1s'

      # give some time to finish job and then pause scheduler
      sleep 2;
    end

  end

end