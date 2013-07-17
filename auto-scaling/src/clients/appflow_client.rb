require 'rubygems'
require 'logger'
require 'json'

require 'appflow_helper'
require 'cloud/CloudClient'

module AutoScaling

  class AppflowClient

    USER_AGENT = "auto-scaling"
    RESOURCE_PATH = '/service_template'

    def initialize(options)
      @options = options
    end

    def create_template(service_template)
      response = client.post(RESOURCE_PATH, service_template)

      if CloudClient::is_error?(response)
        [response.code.to_i, response.to_s]
      else
        template = JSON.parse(response.body)
        template['DOCUMENT']['ID']
      end

    end

    def delete_template(service_template_id)
      client.delete("#{RESOURCE_PATH}/#{service_template_id}")
    end

    private
    def client
      Service::Client.new(
          :username   => @options[:username],
          :password   => @options[:password],
          :url        => @options[:server],
          :user_agent => USER_AGENT)
    end

  end
end
