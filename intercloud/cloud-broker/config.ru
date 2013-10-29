%w(
  /lib
  /lib/resource-mapping
  /lib/resource-mapping/strategies
  /model
).each do |path|
  $LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + path
end

require 'rubygems'
require 'bundler/setup'

require 'redis'
require 'yaml'
require 'amqp'
require 'thread'
require 'json'
require 'erb'
require 'dm-core'
require 'dm-redis-adapter'
require 'all_models'

# offers matching
require 'offers_matcher'
require 'flat_strategy'

require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'redis'

# sinatra app
require 'app.rb'

config                 = YAML.load(ERB.new(File.read('config/config.yaml')).result)
# queue for messages
schedule_message_queue = Queue.new
database               = Redis.new(:host => config['redis']['host'], :port => config['redis']['port'])

DataMapper.setup(:default, :adapter  => "redis")

rest_thread = Thread.new do
  Intercloud::CloudBrokerClientEndpoint.run!(
      :schedule_message_queue => schedule_message_queue,
      :offers_routing_key     => config['amqp']['offers_routing_key'],
      :port                   => config['port'],
      :broker_id              => config['broker_id']
  )
end

# amqp reactor
require 'message_processor'

wait_thread = Thread.new do
  sleep 1 until Intercloud::CloudBrokerClientEndpoint.running?
end

wait_thread.join

Intercloud::MessageProcessor.new(schedule_message_queue, config).run




