#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(File.expand_path('..', __FILE__)))
$LOAD_PATH.unshift(File.join(File.dirname(File.expand_path('../../', __FILE__)), 'lib'))

require 'rubygems'
require 'logger'
require 'sinatra'

require 'clients/appflow_client'
require 'models/planner/service_planner'
require 'models/executor/service_executor'

logger = Logger.new(STDOUT)

options = {
    :username => 'oneadmin',
    :password => 'password',
    :server => 'http://one:2474'
}

appflow_client = AutoScaling::AppflowClient.new options
service_executor = AutoScaling::ServiceExecutor.new appflow_client
service_planner = AutoScaling::ServicePlanner.new service_executor

logger.info("auto-scaling server initialized")

## sinatra part
set :bind, '0.0.0.0'

# JSON:
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

  logger.info("Got service creation request: #{service}")

  begin
    service_planner.plan service
  rescue RuntimeError => e
    logger.error e
    error 400
  end

  status 200
end
