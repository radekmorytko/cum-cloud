#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(File.expand_path('..', __FILE__)))

require 'rubygems'
require 'logger'
require 'sinatra'

require 'domain/chef_configuration'
require 'domain/chef_executor'

logger = Logger.new(STDOUT)

conf = ChefConfiguration.new
conf.prepare
chef = ChefExecutor.new(conf.conf_template[:config_path], conf.chef_solo)

logger.info("VmCoordinator server initialized")

## sinatra part
set :bind, '0.0.0.0'

post '/chef' do
  logger.info("Handling running chef")
  logger.info("Node object json: #{Base64::decode64(params[:node_object_data])}")

  chef.run( :data => params[:node_object_data] )

  status 200
end

