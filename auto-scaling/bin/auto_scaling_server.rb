#!/usr/bin/env ruby

$: << File.join(File.dirname(File.expand_path('../', __FILE__)), 'service-controller')
$: << File.join(File.dirname(File.expand_path('../', __FILE__)), 'cloud-provider')


require 'rubygems'
require 'logger'
require 'sinatra'
require 'rest-client'

require 'cloud_provider'
require 'service_controller'

logger = Logger.new(STDOUT)
RestClient.log = Logger.new(STDOUT)

options = {
    :username => 'oneadmin',
    :password => 'password',
    :server => 'one:2474'
}

# database
DataMapper::Logger.new($stdout, :debug)
db_path = File.join(File.expand_path(File.dirname(__FILE__)), 'auto-scaling.db')
logger.debug "Using database: #{db_path}"
DataMapper.setup(:default, "sqlite://#{db_path}")
DataMapper.auto_migrate!

# service-controller
cloud_provider = AutoScaling::OpenNebulaClient.new options
service_executor = AutoScaling::ServiceExecutor.new cloud_provider
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

post '/service/:service_id/container/:container_id' do |service_id, container_id|
  service = ::AutoScaling::Service.get(service_id)

  logger.debug("Container #{container_id} (service: #{service.id}) converged")

  begin
    service_executor.converge service, container_id
    status 200
  rescue RuntimeError => e
    logger.error e
    status 503
  end

end

put '/service/:service_id/stack/:stack_id' do |service_id, stack_id|
  stack = ::AutoScaling::Stack.get(stack_id)
  logger.debug("Scaling up stack #{stack.id} (service: #{service_id})")

  begin
    service_executor.deploy_container stack
    status 200
  rescue RuntimeError => e
    logger.error e
    status 503
  end

end

delete '/service/:service_id/stack/:stack_id' do |service_id, stack_id|
  stack = ::AutoScaling::Stack.get(stack_id)
  logger.debug("Scaling down stack #{stack.id} (service: #{service_id})")

  begin
    service_executor.delete_container stack
    status 200
  rescue RuntimeError => e
    logger.error e
    status 503
  end

end
