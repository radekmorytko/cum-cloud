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
      set :cloud_provider, OpenNebulaClient.new(settings.endpoints['opennebula'])
      set :executor, ServiceExecutor.new(settings.cloud_provider)
      set :planner, ServicePlanner.new(settings.executor)
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
        service = JSON.parse(payload)
      rescue JSON::ParserError => e
        @@logger.error "Got invalid payload: #{payload}"
        @@logger.error e
        error 400
      end

      begin
        @@logger.debug "Planning deployment of: #{service}"
        service = settings.planner.plan_deployment(service, settings.mappings)
        @@logger.debug "Deployed service #{service.to_s}"
      rescue RuntimeError => e
        @@logger.error e
        status 503
      end

      [status(200), service.to_s]
    end

    # Deletes specified service
    delete '/service/:id' do |service_id|
      @@logger.info("Attempt to delete a service: #{service_id}")
      error 400
    end

    # Converges container - ie. sends appropriate configuration
    #
    # - service_id -> id of a service to which container belongs
    # - container_id -> id of a container
    post '/service/:service_id/container/:container_id' do |service_id, container_id|
      service = Service.get(service_id)

      logger.debug("Container #{container_id} (service: #{service.id}) converged")

      begin
        settings.executor.converge(service, container_id)
        status 200
      rescue RuntimeError => e
        status 503
      end

    end

    run! if app_file == $0
  end

end
