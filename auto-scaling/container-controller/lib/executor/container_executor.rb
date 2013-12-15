require 'rubygems'
require 'logger'
require 'rest_client'

require 'domain/domain'

module AutoScaling
  class ContainerExecutor

    @@logger = Logger.new(STDOUT)

    def initialize(cloud_provider)
      @cloud_provider = cloud_provider
    end

    # Sets OpenVZ cpu limit to a specified amount
    def increase_cpu(container, amount)
      payload = { 'cpulimit' => amount }
      @@logger.debug "Prepared payload for CPU increase: #{payload} for #{container}"
      host = @cloud_provider.host_by_container(container.correlation_id)
      post(host, container, payload.to_json)
    end

    def increase_memory(container, amount)
      payload = { 'physpages' => amount }
      @@logger.debug "Prepared payload for MEMORY increase: #{payload} for #{container}"
      host = @cloud_provider.host_by_container(container.correlation_id)
      post(host, container, payload.to_json)
    end

    private
    def post(host, container, payload)
      url = url(host, container)

      RestClient.post(url, payload){ |response, request, result, &block|
        case response.code
          when 200
            @@logger.debug "Got response #{response} from #{url}"
            response
          else
            response.return!(request, result, &block)
        end
      }
    end

    def url(host, container)
      "http://#{host}:4567/container/#{container.correlation_id}/configuration"
    end

  end
end
