$: << File.join(File.dirname(File.expand_path(__FILE__)), 'lib')

require 'rubygems'
require 'logger'
require 'rufus-scheduler'

require 'planner/container_planner'
require 'executor/container_executor'
require 'monitor/container_monitor'
require 'analyzer/container_analyzer'
require 'models/models'

module AutoScaling

  class ContainerController

    @@logger = Logger.new(STDOUT)

    # Build a service-controller instance
    #
    # * *Args* :
    # - +cloudLogger.new(STDOUT)
    attr_reader :monitor, :analyzer, :planner

    def initialize(monitor, analyzer, planner, executor, scheduler = nil)
      @monitor, @analyzer, @planner, @executor = monitor, analyzer, planner, executor
      scheduler ||= Rufus::Scheduler.new

      @scheduler = scheduler
    end

    def schedule(container, interval)
      @scheduler.every(interval) do
        @@logger.debug "Executing job for a #{container}"

        monitoring_data = monitor.monitor(container)
        conclusions = analyzer.analyze(monitoring_data)
        planner.plan(conclusions)

        @@logger.debug "Job execution has finished"
      end
    end

    #_provider+ -> cloud provider, ie, open nebula
    # - +cloud_controller+ -> an instance of CloudController
    def self.build(cloud_provider, settings)
      # mapek model
      monitor = ContainerMonitor.new(cloud_provider)
      analyzer = ContainerAnalyzer.new()
      executor = ContainerExecutor.new(cloud_provider)
      planner = ContainerPlanner.new(executor, settings.service_controller)

      ContainerController.new(monitor, analyzer, planner, executor)
    end

  end
end
