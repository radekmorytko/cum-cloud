$: << File.join(File.dirname(File.expand_path(__FILE__)), 'lib')

require 'rubygems'
require 'logger'
require 'rufus-scheduler'

require 'planner/stack_planner'
require 'planner/reservation_manager'
require 'executor/stack_executor'
require 'monitor/stack_monitor'
require 'analyzer/stack_analyzer'
require 'analyzer/policy_evaluator'
require 'domain/domain'

module AutoScaling

  class StackController

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

    def converge(stack)
      master = Container.master(stack)
      @executor.converge(master.id)
    end

    # Checks if resource reservation is possible
    #
    # * *Args* :
    # - +stack_data+ ->
    def reserve?(stack_data)
      @planner.reserve?(stack_data)
    end

    # Build a stack-controller instance
    #
    # * *Args* :
    # - +cloud_provider+ -> cloud provider, ie, open nebula
    # - +cloud_controller+ -> an instance of CloudController
    # - +reservation_manager+ -> an instance of ReservationManager
    # - +mappings+ -> an instance of hashmap, used to configure ServiceExecutor
    def self.build(cloud_provider, settings)
      # shortcuts
      cloud_controller = settings['cloud_controller']
      mappings = settings['mappings'][settings['cloud_provider_name']]

      # mapek model
      monitor = StackMonitor.new(cloud_provider)
      analyzer = StackAnalyzer.new(PolicyEvaluator.new)
      executor = StackExecutor.new(cloud_provider, mappings)

      capacity = {}
      if settings['endpoints'][settings['cloud_provider_name']].key?('capacity')
        capacity = settings['endpoints'][settings['cloud_provider_name']]['capacity']
      end
      reservation_manager = ReservationManager.new(cloud_provider, capacity)
      planner = StackPlanner.new(executor, cloud_controller, reservation_manager)

      stack_controller = StackController.new(monitor, analyzer, planner, executor)
      cloud_controller.stack_controller = stack_controller

      return stack_controller
    end

  end
end
