#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(File.expand_path('..', __FILE__)))

require 'rubygems'
require 'logger'
require 'sinatra'

require 'models/chef_configuration'
require 'models/chef_executor'

conf = ChefConfiguration.new
chef = ChefExecutor.new conf

logger = Logger.new(STDOUT)
logger.debug( "VmCoordinator server initialized")

## sinatra part
set :bind, '0.0.0.0'

post '/chef' do
  logger.debug("Handling running chef")
  logger.debug("Node object json: #{Base64::decode64(params[:node_object_data])}")

  chef.run(
    :node_object => {
        :data => params[:node_object_data]
    }
  )
end

