$LOAD_PATH << File.expand_path(File.dirname(__FILE__)) + '/lib'

require 'rubygems'
require 'bundler/setup'
require 'client'
require 'http_sender'
require 'command_line_parser'

db = {}

def db.set(key, val)
  self[key]= val
end

def db.get(key)
  self[key]
end

options = Intercloud::CommandLineParser.parse
client = Intercloud::Client.new(Intercloud::HttpSender.new, db)

case options[:command]
  when 'deploy'
    client.deploy(options[:arguments])
  else
    puts 'Unknown command'
end
