$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib'

require 'rubygems'
require 'bundler/setup'

require 'redis'
require 'yaml'
require 'amqp'
require 'thread'
require 'json'

require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'redis'
require 'cloud_broker'

# sinatra app
require 'app.rb'

config        = YAML.load_file('config/config.yaml')
message_queue = Queue.new

rest_thread = Thread.new do
  Intercloud::CloudBrokerClientEndpoint.run!(
      :db           => (db = Redis.new(:host => config['redis']['host'], :port => config['redis']['port'])),
      :cloud_broker => Intercloud::CloudBroker.new(:db => db, :message_queue => message_queue),
      :port => 33331
  )
end

# amqp reactor
require 'message_processor'

wait_thread = Thread.new do
  sleep 1 until Intercloud::CloudBrokerClientEndpoint.running?
  puts "ok, trap registered"
end

wait_thread.join

Intercloud::MessageProcessor.new(message_queue).run




