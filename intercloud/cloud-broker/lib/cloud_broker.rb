require 'rubygems'
require 'bundler/setup'

module Intercloud
  class CloudBroker

    def initialize(settings)

    end

    def deploy(service_spec, client_endpoint)
    end

    def valid?(service_spec)
      true
    end
  end
end