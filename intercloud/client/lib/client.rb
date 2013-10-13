require 'rubygems'
require 'bundler/setup'

require 'yaml'
require 'erb'

module Intercloud

  class Client

    attr_reader :config

    def initialize(sender, database)
      @database = database
      @sender   = sender
    end

    def deploy(service_spec)
      msg        = @sender.prepare_deploy_message(config, service_spec)
      service_id = @sender.send(msg)
      @database.set('service_id', service_id)
    end

    def check_status(service_id)

    end

    def config
      @config ||= YAML.load(ERB.new(File.read('config/config.yaml')).result)
    end

  end
end