#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(File.expand_path('..', __FILE__)))

require 'rubygems'
require 'rest_client'

require 'models/chef_configuration'
require 'models/chef_executor'

# prepare the node
conf = ChefConfiguration.new
conf.prepare

# apply appstage configuration
chef = ChefExecutor.new(conf.conf_template[:config_path], conf.chef_solo)

if ['NODE', 'AUTO_SCALING_SERVER', 'SERVICE_ID', 'VM_ID'].all? {|k| ENV.include?(k)}
  raise RuntimeError, "Can't configure and converge environment. One of the values: NODE, AUTO_SCALING_SERVER, SERVICE_ID, VM_ID cannot be find in env: #{ENV}"
  return
end

chef.run( :data => ENV['NODE'] )
RestClient.post "#{ENV['AUTO_SCALING_SERVER']}/service/#{ENV['SERVICE_ID']}/container/#{ENV['VM_ID']}", "{}"

