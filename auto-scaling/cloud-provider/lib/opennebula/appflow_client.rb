require 'rubygems'
require 'logger'
require 'json'
require 'rest_client'
require 'uri'

module AutoScaling

  class AppflowClient

    CLIENT = {
        :user_agent => "auto-scaling",
        :timeout => 100,
        :retries => 3
    }

    RESOURCES = {
        :service => '/service',
        :service_template => '/service_template'
    }

    @@logger = Logger.new(STDOUT)

    def initialize(options)
      @options = options
    end

    def create_template(service_template)
      client(RESOURCES[:service_template]).post(service_template) {|response, request, result, &block|
        case response.code
          when 201, 200
            template = JSON.parse(response.body)
            id = template['DOCUMENT']['ID'].to_i
            @@logger.debug "Created template: #{id}"
            id
          else
            error response
        end
      }
    end

    def delete_template(service_template_id)
      client("#{RESOURCES[:service_template]}/#{service_template_id}").delete {|response, request, result, &block|
        case response.code
          when 201, 200
            0
          else
            error response
        end
      }
    end

    def instantiate_template(template_id)
      action = {
          :action => {
              :perform => 'instantiate'
          }
      }

      client("#{RESOURCES[:service_template]}/#{template_id}/action").post(action.to_json){|response, request, result, &block|
        case response.code
          when 201, 200
            template = JSON.parse(response.body)
            template['DOCUMENT']['ID'].to_i
          else
            error response
        end
      }
    end

    def delete_instance(instance_id)
      client("#{RESOURCES[:service]}/#{instance_id}").delete {|response, request, result, &block|
        case response.code
          when 201, 200
            0
          else
            error response
        end
      }
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
        resource = client("#{RESOURCES[:service]}/#{instance_id}").get
        document_hash = JSON.parse(resource)
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
    def client(path)
      uri = URI(@options['endpoints']['appflow'])

      RestClient::Resource.new(
          "#{uri.scheme}://#{@options['username']}:#{@options['password']}@#{uri.host}:#{uri.port}#{uri.path}#{path}",
          :timeout => @options['timeout'],
          :open_timeout => @options['timeout']
      )
    end

    def error(response)
      raise RuntimeError, "Cannot execute client action: #{response.code.to_i}, #{response.to_s}"
    end

  end
end
