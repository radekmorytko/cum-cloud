#!/usr/bin/env ruby

$: << File.dirname(File.expand_path('..', __FILE__))

require 'rubygems'
require 'logger'
require 'sinatra'
require 'sinatra/config_file'
require 'rest-client'
require 'yaml'

require 'cloud-provider/cloud_provider'
require 'service-controller/service_controller'

module AutoScaling

  class AutoScalingServer < Sinatra::Base
    register Sinatra::ConfigFile

    @@logger = Logger.new(STDOUT)
    config_file 'config/config.yaml'

    # configuration
    configure do
      RestClient.log = Logger.new(STDOUT)
      enable :logging
      enable :dump_error
    end

    # setup database
    configure do
      DataMapper::Logger.new($stdout, :info)
      db_path = File.join(File.expand_path(File.dirname(__FILE__)), 'auto-scaling.db')

      DataMapper.setup(:default, "sqlite://#{db_path}")
      DataMapper.auto_migrate!
    end

    # setup components
    configure do
      set :cloud_provider, OpenNebulaClient.new(settings.endpoints[settings.cloud_provider_name])

      set :monitor, ServiceMonitor.new(settings.cloud_provider)
      # TODO specify model as a part of policy
      set :analyzer, ServiceAnalyzer.new(ThresholdModel.new(30, 80))
      set :executor, ServiceExecutor.new(settings.cloud_provider, settings.mappings[settings.cloud_provider_name])
      set :planner, ServicePlanner.new(settings.executor)

      set :controller, ServiceController.new(settings.monitor, settings.analyzer, settings.planner)
    end

    # Deploys new service.
    #
    # Request should contain a proper JSON body in form:
    # {
    #   'stack' => 'tomcat',
    #   'instances' => 2,
    #   'name' => 'enterprise-app'
    # }
    post '/service' do

      payload = request.body.read
      @@logger.debug "Got body #{payload}"

      begin
        service_data = JSON.parse(payload)
      rescue JSON::ParserError => e
        @@logger.error "Got invalid payload: #{payload}"
        @@logger.error e
        error 400
      end

      begin
        @@logger.debug "Planning deployment of: #{service_data}"
        service = settings.planner.plan_deployment(service_data)
        @@logger.debug "Deployed service #{service.to_json}"

        settings.controller.schedule(service, settings.scheduler['interval'])
        @@logger.debug "Scheduled job execution for a service: #{service.to_json}"
      rescue RuntimeError => e
        @@logger.error e
        status 503
      end

      [status(200), service.to_json]
    end

    # Deletes specified service
    delete '/service/:id' do |service_id|
      @@logger.info("Attempt to delete a service: #{service_id}")
      error 400
    end

    # Method used to bootstrap a container template
    post '/service/bootstrap/container/:container_id' do |container_id|
      provider = settings.cloud_provider
      logger.info "Bootstrap container template: #{container_id}"
      provider.save_container(container_id)
      provider.shutdown_container(container_id)
    end

    # Converges container - ie. sends appropriate configuration
    #
    # - service_id -> id of a service to which container belongs
    # - container_id -> id of a container
    post '/service/:service_id/container/:container_id' do |service_id, container_id|
      service = Service.get(service_id)

      logger.debug("Attempt to converge container #{container_id} (service: #{service.id})")

      begin
        settings.executor.converge(service, container_id)
        logger.debug("Container #{container_id} (service: #{service.id}) successfully converged")
        status 200
      rescue RuntimeError => e
        status 503
      end

    end

    run! if app_file == $0
  end

end
