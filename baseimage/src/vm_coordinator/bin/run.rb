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
chef = ChefExecutor.new

chef_executor = OneChef.new(
    :chef => chef,
    :redis => redis,
    :role => role,
    :service_id => ENV['SERVICE_ID']
)

logger.debug('Coordinator initialized')

logger.debug('Running chef')
chef_executor.run_chef(
    {
        :node_object => {
            :data => ENV['NODE']
        },
    }
)
