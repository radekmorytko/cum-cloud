require 'rubygems'
require 'logger'
require 'json'

require 'appflow_helper'
require 'cloud/CloudClient'

module AutoScaling

  class AppflowClient

    USER_AGENT = "auto-scaling"
    TIMEOUT = 10
    SERVICE_TEMPLATE_PATH = '/service_template'
    SERVICE_PATH = '/service'

    def initialize(options)
      @options = options
    end

    def create_template(service_template)
      response = client.post(SERVICE_TEMPLATE_PATH, service_template)

      if CloudClient::is_error?(response)
        [response.code.to_i, response.to_s]
      else
        template = JSON.parse(response.body)
        template['DOCUMENT']['ID'].to_i
      end

    end

    def delete_template(service_template_id)
      client.delete("#{SERVICE_TEMPLATE_PATH}/#{service_template_id}")
    end

    def instantiate_template(template_id)
      json_str = ::Service.build_json_action('instantiate')
      response = client.post("#{SERVICE_TEMPLATE_PATH}/#{template_id}/action", json_str)

      if CloudClient::is_error?(response)
        [response.code.to_i, response.to_s]
      else
        template = JSON.parse(response.body)
        template['DOCUMENT']['ID'].to_i
      end
    end

    def delete_instance(instance_id)
      client.delete("#{SERVICE_PATH}/#{instance_id}")
    end

    private
    def client
      ::Service::Client.new(
          :username   => @options[:username],
          :password   => @options[:password],
          :url        => @options[:server],
          :timeout    => TIMEOUT,
          :user_agent => USER_AGENT)
    end

  end
end
