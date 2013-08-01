require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'utils'
require 'service_controller'

module AutoScaling

  class ServiceControllerTest < Test::Unit::TestCase

    def setup
      @monitor, @analyzer, @planner = mock(), mock(), mock()
      @scheduler = Rufus::Scheduler.new

      @controller = ServiceController.new @monitor, @analyzer, @planner, @scheduler
    end

    def test_shall_perform_full_cycle
      service = mock()
      job = ServiceJob.new service, @controller

      monitoring_data, conclusions = mock(), mock()

      @monitor.expects(:monitor).with(service).returns(monitoring_data)
      @analyzer.expects(:analyze).with(monitoring_data).returns(conclusions)
      @planner.expects(:plan).with(conclusions)

      scheduled_job = @controller.schedule job, '1s'

      # give some time to finish job and then pause scheduler
      sleep 2; scheduled_job.pause
    end

  end

end