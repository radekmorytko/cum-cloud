#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path(File.dirname(__FILE__)) + '/..'

require 'rubygems'
require 'bundler/setup'
require 'redis'
require 'yaml'
require 'pp'
require 'sinatra/base'


module Intercloud
  class ClientEndpoint < Sinatra::Base

    set :config, YAML.load_file('config/client_endpoint.yaml')
    set :port, config['port']
    set :environment, ENV['INTERCLOUD_ENV'] || ENV['RACK_ENV'] || :development
    set :db, Redis.new(:host => config['redis']['host'], :port => config['redis']['port'])

    post '/service_status' do
      service_id = params[:service_id]
      status     = params[:status]
      db.set(service_id, status)
      200
    end

    run! if app_file == $0
  end
end
