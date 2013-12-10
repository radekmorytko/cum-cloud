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
      post(container, payload)
    end

    def increase_memory(container)
      payload = '{ "chef" => "MEMORY" }'
      post(container, payload)
    end

    private
    def post(container, payload)
      RestClient.post(url(container), payload){ |response, request, result, &block|
        case response.code
          when 200
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
