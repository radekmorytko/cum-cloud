$: << File.join(File.dirname(File.expand_path(__FILE__)), 'lib')

require 'rubygems'
require 'logger'
require 'rufus-scheduler'

require 'planner/service_planner'
require 'executor/service_executor'
require 'monitor/service_monitor'
require 'analyzer/service_analyzer'
require 'models/models'

module AutoScaling

  class ServiceController

    @@logger = Logger.new(STDOUT)
    attr_reader :monitor, :analyzer, :planner

    def initialize(monitor, analyzer, planner, scheduler = nil)
      @monitor, @analyzer, @planner = monitor, analyzer, planner
      scheduler ||= Rufus::Scheduler.new

      @scheduler = scheduler
    end

    def schedule(service, interval)
      @scheduler.every(interval) do
        @@logger.debug "Executing job for a #{service}"

        monitoring_data = monitor.monitor(service)
        conclusions = analyzer.analyze(monitoring_data)
        planner.plan(conclusions)

        @@logger.debug "Job execution has finished"
      end
    end

  end
end
