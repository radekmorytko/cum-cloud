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

    def initialize(monitor, analyzer, planner, executor, scheduler = nil)
      @monitor, @analyzer, @planner, @executor = monitor, analyzer, planner, executor
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

    def converge(service)
      service.stacks.each do |stack|
        master = Container.master(stack)
        @executor.converge(master.id)
      end
    end

    # Build a service-controller instance
    #
    # * *Args* :
    # - +cloud_provider+ -> cloud provider, ie, open nebula
    # - +cloud_controller+ -> an instance of CloudController
    # - +reservation_manager+ -> an instance of ReservationManager
    # - +mappings+ -> an instance of hashmap, used to configure ServiceExecutor
    def self.build(cloud_provider, settings)
      # shortcuts
      cloud_controller = settings.cloud_controller
      mappings = settings.mappings[settings.cloud_provider_name]

      # mapek model
      monitor = ServiceMonitor.new(cloud_provider)
      analyzer = ServiceAnalyzer.new(ThresholdModel.new(30, 80))
      executor = ServiceExecutor.new(cloud_provider, mappings)

      capacity = {}
      if settings.endpoints[settings.cloud_provider_name].key?('capacity')
        capacity = settings.endpoints[settings.cloud_provider_name]['capacity']
      end
      reservation_manager = ReservationManager.new(cloud_provider, capacity)
      planner = ServicePlanner.new(executor, cloud_controller, reservation_manager)

      ServiceController.new(monitor, analyzer, planner, executor)
    end

  end
end
