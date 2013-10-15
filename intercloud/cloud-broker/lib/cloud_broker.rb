module Intercloud
  class CloudBroker

    def initialize(options = {})
      @message_queue = options[:message_queue]
      @routing_key   = options[:routing_key]
    end

    def deploy(service_specifation_attributes)
      service_specification = ServiceSpecification.create!(service_specifation_attributes)
      @message_queue << prepare_message(service_specification)
      service_specification.id
    end

    private

    def prepare_message(service_specification)
      message               = service_specification.attributes

      require 'pp'
      pp message

      message[:routing_key] = @routing_key
      message.delete(:client_endpoint)
      message.to_json
    end
  end
end