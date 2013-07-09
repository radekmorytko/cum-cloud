$: << "#{File.dirname(__FILE__)}"

load "config/vm_coordinator.conf"

require 'models/one_chef'
require 'models/chef_executor'
require 'models/chef_configuration'
