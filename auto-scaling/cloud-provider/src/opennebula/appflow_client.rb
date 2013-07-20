require 'rubygems'
require 'logger'
require 'json'

require 'opennebula/appflow_helper'
require 'cloud/CloudClient'

module AutoScaling

  class AppflowClient

    CLIENT = {
        :user_agent => "auto-scaling",
        :timeout => 10,
        :retries => 3
    }

    RESOURCES = {
        :service => '/service',
        :service_template => '/service_template'
    }

    @logger = Logger.new(STDOUT)

    def initialize(options)
      @options = options
    end

    def create_template(service_template)
      response = client.post(RESOURCES[:service_template], service_template)

      return [response.code.to_i, response.to_s] if CloudClient::is_error?(response)

      template = JSON.parse(response.body)
      template['DOCUMENT']['ID'].to_i
    end

    def delete_template(service_template_id)
      client.delete("#{RESOURCES[:service_template]}/#{service_template_id}")
    end

    def instantiate_template(template_id)
      json_str = ::Service.build_json_action('instantiate')
      response = client.post("#{RESOURCES[:service_template]}/#{template_id}/action", json_str)

      return [response.code.to_i, response.to_s] if CloudClient::is_error?(response)

      template = JSON.parse(response.body)
      template['DOCUMENT']['ID'].to_i
    end

    def delete_instance(instance_id)
      client.delete("#{RESOURCES[:service]}/#{instance_id}")
    end

    # Returns configuration of a service as a list of roles and corresponding vms, ex:
    # {
    #   "loadbalancer" => [{:ip=>"192.168.122.100", :id=>"138"}],
    #   "worker" => [{:ip=>"192.168.122.101", :id=>"139"}]
    # }
    #
    # Note: method is blocking
    def configuration(instance_id)
      retry_count = 0

      begin
        response = client.get("#{RESOURCES[:service]}/#{instance_id}")

        # we return if there was an error on server
        # (retries apply only to a service state)
        return [response.code.to_i, response.to_s] if CloudClient::is_error?(response)

        document_hash = JSON.parse(response.body)
        template = document_hash['DOCUMENT']['TEMPLATE']['BODY']
        retry_count += 1

      end while retry_count <= CLIENT[:retries] and template['state'].to_i < 2

      raise RuntimeError, "Can't get service confiugration - it is still pending" if template['state'].to_i < 2

      result = {}
      template['roles'].each do |role|
        result[role['name']] = []

        role['nodes'].each do |node|

          result[role['name']] << {
              :id => node['vm_info']['VM']["ID"],
              :ip => node['vm_info']['VM']['TEMPLATE']['NIC']['IP']
          }
        end
      end

      result
    end

    private
    def client
      ::Service::Client.new(
          :username   => @options[:username],
          :password   => @options[:password],
          :url        => @options[:server],
          :timeout    => CLIENT[:timeout],
          :user_agent => CLIENT[:user_agent])
    end



  end
end
