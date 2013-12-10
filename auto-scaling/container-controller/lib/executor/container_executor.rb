require 'rubygems'
require 'logger'
require 'rest_client'

require 'domain/domain'

module AutoScaling
  class ContainerExecutor

    @@logger = Logger.new(STDOUT)

    def initialize()
    end

    def increase_cpu(container)
      payload = '{ "chef" => "CPU" }'
      @@logger.debug "Prepared payload for CPU increase: #{payload} for #{container}"
      result = post(container, payload)
    end

    def increase_memory(container)
      payload = '{ "chef" => "MEMORY" }'
      @@logger.debug "Prepared payload for MEMORY increase: #{payload} for #{container}"
      post(container, payload)
    end

    private
    def post(container, payload)
      url = url(container)

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

    def url(container)
      "http://#{container.ip}:4567/chef"
    end

  end
end
