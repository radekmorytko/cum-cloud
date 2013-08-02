$: << File.join(File.dirname(File.expand_path(__FILE__)), 'src')
$: << File.join(File.dirname(File.expand_path(__FILE__)), 'lib')
$: << File.join(File.dirname(File.expand_path(__FILE__)), '..')

require 'rubygems'
require 'logger'
require 'rufus-scheduler'

require 'planner/service_planner'
require 'executor/service_executor'
require 'monitor/service_monitor'
require 'analyzer/service_analyzer'
require 'models/models'

module AutoScaling

  class ServiceJob
    @@logger = Logger.new(STDOUT)

    def initialize(service, controller)
      @service = service
      @controller = controller
    end

    def call(job)
      @@logger.debug "Executing job: #{job}"

      monitoring_data = @controller.monitor.monitor(@service)
      conclusions = @controller.analyzer.analyze(monitoring_data)
      @controller.planner.plan(conclusions)
    end
  end

  class ServiceController

    attr_reader :monitor, :analyzer, :planner

    def initialize(monitor, analyzer, planner, scheduler = nil)
      @monitor, @analyzer, @planner = monitor, analyzer, planner
      scheduler ||= Rufus::Scheduler.new

      @scheduler = scheduler
    end

    def schedule(job, interval)
      @scheduler.every interval, job
    end

  end
end
