#!/usr/bin/env ruby

$: << File.join(File.dirname(File.expand_path('../', __FILE__)), 'service-controller')
$: << File.join(File.dirname(File.expand_path('../', __FILE__)), 'cloud-provider')
$: << File.join(File.dirname(File.expand_path('../../', __FILE__)), 'lib')


require 'rubygems'
require 'logger'
require 'sinatra'
require 'rest-client'

require 'cloud_provider'
require 'service_controller'

module AutoScaling

  class CloudBrokerClientEndpoint < Sinatra::Base

    configure do

      RestClient.log = Logger.new(STDOUT)

      # database
      DataMapper::Logger.new($stdout, :debug)
      db_path = File.join(File.expand_path(File.dirname(__FILE__)), 'auto-scaling.db')
      DataMapper.setup(:default, "sqlite://#{db_path}")
      DataMapper.auto_migrate!

    end

    configure do
      options = {
          :username => 'oneadmin',
          :password => 'password',
          :server => 'one:2474'
      }

      set :cloud_provider, OpenNebulaClient.new(options)
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

      begin
        service = JSON.parse(payload)
      rescue JSON::ParserError => e
        logger.error "Got invalid payload: #{payload}"
        logger.error e
        error 400
      end

      settings.planner.plan_deployment service

      status 200
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
        logger.error e
        status 503
      end

    end

    run! if app_file == $0

  end

end
