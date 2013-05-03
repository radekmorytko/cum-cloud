#!/usr/bin/ruby

$LOAD_PATH.unshift(File.dirname(File.expand_path('.', __FILE__)))

require 'vm_coordinator'
require 'one_chef'
require 'logger'
require 'base64'

logger = Logger.new('/tmp/coordinator.log')

chef = OneChef.new
coordinator = VMCoordinator.new(:chef => chef)

logger.debug('Coordinator initialized')

coordinator.run_chef(
    {
        :node_object => {
            :data => ENV['NODE']
        },
        :cookbooks_url =>  ENV['COOKBOOKS']
    }
)