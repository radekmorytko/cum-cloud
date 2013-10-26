#!/usr/bin/env ruby

require 'pp'
require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'erb'
require 'json'
require 'securerandom'

require 'amqp'

config = YAML.load(ERB.new(File.read('config/config.yaml')).result)

EM.run do
  AMQP.connect('amqp://' + config['amqp']['host'] + ':' + config['amqp']['port'].to_s) do |connection|
    channel = AMQP::Channel.new(connection)

    ##
    # Receiving
    ##
    offers_exchange = channel.fanout(config['amqp']['offers_exchange_name'])
    channel.queue('').bind(offers_exchange).subscribe do |metadata, payload|
      message = JSON.parse(payload)

      p 'Got an offer request: '
      pp message

      ## TODO get the cloud offer
      mock_offer = {
          :memory => SecureRandom.random_number(4096),
          :price => SecureRandom.random_number(200) # /h
      }

      reply = {
          :id    => message['id'], # service id
          :controller_routing_key => config['amqp']['controller_routing_key'], # controller id
          :offer => mock_offer
      }

      p 'Sending a mock offer'
      channel.default_exchange.publish(reply.to_json, :routing_key => message['offers_routing_key'])
    end

    # messages that are addressed directly to this controller
    channel.queue(config['amqp']['controller_routing_key']).subscribe do |metadata, payload|
      pp payload
      puts 'Deploying a service'
    end


    Signal.trap('INT') {
      connection.close {
        EM.stop
      }
    }
  end
end


