$: << File.join(File.dirname(File.expand_path(__FILE__)), 'lib')

require 'rubygems'
require 'logger'
require 'rufus-scheduler'

require 'planner/service_planner'
require 'planner/reservation_manager'
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

    def plan_deployment(service_data)
      @planner.plan_deployment(service_data)
    end

    def converge(service, container_id)
      @executor.converge(service, container_id)
    end

    # Build a service-controller instance
    #
    # * *Args* :
    # - +cloud_provider+ -> cloud provider, ie, open nebula
    # - +cloud_controller+ -> an instance of CloudController
    # - +reservation_manager+ -> an instance of ReservationManager
    # - +mappings+ -> an instance of hashmap, used to configure ServiceExecutor
    def self.build(cloud_provider, cloud_controller, mappings)
      monitor = ServiceMonitor.new(cloud_provider)
      analyzer = ServiceAnalyzer.new(ThresholdModel.new(30, 80))
      executor = ServiceExecutor.new(cloud_provider, mappings)
      reservation_manager = ReservationManager.new(cloud_provider)
      planner = ServicePlanner.new(executor, cloud_controller, reservation_manager)

      ServiceController.new(monitor, analyzer, planner)
    end

  end
end
