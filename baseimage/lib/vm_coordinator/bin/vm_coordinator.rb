#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(File.expand_path('..', __FILE__)))

require 'rubygems'
require 'logger'
require 'rest_client'

require 'models/chef_configuration'
require 'models/chef_executor'

# precondition
if not ['NODE', 'AUTO_SCALING_SERVER', 'SERVICE_ID', 'VM_ID'].all? {|k| ENV.include?(k)}
  raise RuntimeError, "Can't configure and converge environment. One of the values: NODE, AUTO_SCALING_SERVER, SERVICE_ID, VM_ID cannot be find in env: #{ENV}"
  return
end

# prepare the node
logger = Logger.new(STDOUT)
conf = ChefConfiguration.new
conf.prepare

# apply appstage configuration
chef = ChefExecutor.new(conf.conf_template[:config_path], conf.chef_solo)
result = chef.run( :data => ENV['NODE'] )

# notify server
url = "#{ENV['AUTO_SCALING_SERVER']}/service/#{ENV['SERVICE_ID']}/container/#{ENV['VM_ID']}"
logger.debug "Sending notification to #{url}"

RestClient.post(url, "{}") { |response, request, result, &block|
  case response.code
    when 200
      logger.info "Successfully sent converge notification"
    else
      logger.debug "Error occurred during sending a notification"
  end
}

