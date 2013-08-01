#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path(File.dirname(__FILE__)) + '/lib'

require 'rubygems'
require 'json'
require 'bundler/setup'
require 'client'
require 'sender/http_sender'
require 'sender/client_sender'
require 'command_line_parser'
require 'pp'

db = {}

def db.set(key, val)
  self[key]= val
end

def db.get(key)
  self[key]
end

options = Intercloud::CommandLineParser.parse
client = Intercloud::Client.new(Intercloud::ClientSender.new(Intercloud::HttpSender.new), db)

case options[:command]
  when 'deploy'
    filename = options[:arguments]
    raise 'File with the environment does not exist!' unless File.exists?(filename)
    service_specification = JSON.parse(File.read(filename))
    client.deploy(service_specification)
  else
    puts 'Unknown command'
end
