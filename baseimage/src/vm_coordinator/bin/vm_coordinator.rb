#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(File.expand_path('..', __FILE__)))

require 'models/chef_configuration'
require 'models/chef_executor'

# prepare the node
conf = ChefConfiguration.new
conf.prepare

# apply appstage configuration
chef = ChefExecutor.new(conf.conf_template[:config_path], conf.chef_solo)

if ENV.key? 'NODE'
  chef.run( :data => ENV['NODE'] )
else
  puts "Environment variable NODE is not set"
end

