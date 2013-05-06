#!/usr/bin/env ruby

##
# It is assumed that the following variables are passed
# via contextualization:
# IP - ip of this vm
# REDIS_HOST & REDIS_PORT - ip and port of the redis database
# SERVICE_ID - id of the service currently deployed
# ROLE - either master or slave (assigned in Role.rb::initialize)
# NODE - base64 encoded chef node object (json) [this is included by default via oneapps]
# COOKBOOKS - url to cookbooks (tar.gz)
##


$LOAD_PATH.unshift(File.dirname(File.expand_path('.', __FILE__)))

require 'rubygems'
require 'vm_coordinator'
require 'one_chef'
require 'logger'
require 'base64'
require 'redis'
require 'rest_client'
require 'json'

logger = Logger.new('/tmp/coordinator.log')

role = ENV['ROLE'] == 'SLAVE' ? :slave : :master
redis = Redis.new(:host => ENV['REDIS_HOST'], :port => ENV['REDIS_PORT'])
chef = OneChef.new
coordinator = VMCoordinator.new(
    :chef => chef,
    :redis => redis,
    :role => role,
    :service_id => ENV['SERVICE_ID']
)

logger.debug('Coordinator initialized')

logger.debug('Running chef')
coordinator.run_chef(
    {
        :node_object => {
            :data => ENV['NODE']
        },
        :cookbooks_url =>  ENV['COOKBOOKS']
    }
)

if role == :slave
  logger.debug('[Slave] Fetching ip of the master')
  master_ip = coordinator.execute_db_operation do |key, db_handler|
    db_handler.hget(key, "master_ip")
  end

  chef_node_object = {
      :name => 'node-loadbalancer',
      :run_list => %w(recipe[apache_mod_jk]),
      :mod_jk => {
          :tomcat_workers => {
              ENV['VM_NAME'] => {
                  :port => 8009,
                  :type => 'ajp13',
                  :host => ENV['IP']
              }
          },
          :loadbalancer => {
              :added_workers => [ENV['VM_NAME']]
          }
      },

  }

  url = master_ip + ':4567/action/run_chef'

  logger.debug("[Slave] master rest endpoint: #{url}")
  logger.debug("[Slave] node-object: #{JSON.pretty_generate(chef_node_object)}")

  payload = {
     :node_object_data => Base64::encode64(JSON.generate(chef_node_object)),
     :cookbooks_url => ENV['COOKBOOKS']
  }
  RestClient.post(url, payload)
else
  ip = ENV['IP']
  logger.debug("[Master] Updating database, setting ip: #{ip}")
  coordinator.execute_db_operation do |key, db_handler|
    db_handler.hmset(key, "master_ip", ip)
  end
end
