#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(File.expand_path('.', __FILE__)))

require 'rubygems'
require 'vm_coordinator'
require 'one_chef'
require 'logger'
require 'sinatra'

logger = Logger.new('/var/log/vm-coordinator-server.log')

chef = OneChef.new
coordinator = VMCoordinator.new(:chef => chef)

logger.debug('Coordinator initialized')

## sinatra part

set :bind, '0.0.0.0'

post '/action/run_chef' do
  logger.debug("Handling running chef")
  logger.debug("Cookbooks url: #{params[:cookbooks_url]}")
  logger.debug("Node object json: #{Base64::decode64(params[:node_object_data])}")

  coordinator.run_chef(
      {
          :node_object => {
              :data => params[:node_object_data]
          },
          :cookbooks_url => params[:cookbooks_url]
      }
  )
end

