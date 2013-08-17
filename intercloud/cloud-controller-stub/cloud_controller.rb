#!/usr/bin/env ruby

require 'pp'
require 'rubygems'
require 'bundler/setup'

require 'amqp'


EM.run do
  AMQP.connect('amqp://localhost:5672') do |connection|
    channel = AMQP::Channel.new(connection)

    ##
    # Receiving
    ##
    exchange = channel.fanout('sample.fanout')
    channel.queue('').bind(exchange).subscribe do |metadata, payload|
      puts 'message received'
      puts 'payload: '
      pp payload
      channel.default_exchange.publish('reply', :routing_key => 'rkey')
    end

    ## publishing
    #channel.default_exchange.publish('reply', :routing_key => 'rkey')

    Signal.trap('INT') {
      connection.close {
        EM.stop
      }
    }
  end
end


