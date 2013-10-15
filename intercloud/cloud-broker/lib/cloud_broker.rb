module Intercloud
  class CloudBroker

    def initialize(options = {})
      @database      = options[:db]
      @message_queue = options[:message_queue]
      @routing_key   = options[:routing_key]
    end

    def deploy(service_spec, client_endpoint)
      deploy_request = prepare_database_record(
          :service_spec    => service_spec,
          :client_endpoint => client_endpoint
      )
      save_deploy_request(deploy_request)
      @message_queue << deploy_request.to_json
      id
    end

    def valid?(service_spec)
      true
    end

    private

    def save_deploy_request(deploy_request)
      @database.set(deploy_request[:id], deploy_request[:record])
      deploy_request[:id]
    end

    def generate_id(seed)
      Digest::SHA1.hexdigest(seed)
    end

    def prepare_database_record(options)
      {
          :id => generate_id(options[:client_endpoint] + options[:service_spec].to_s),
          :record => {
            :routing_key     => @routing_key,
            :client_endpoint => options[:client_endpoint],
            :service_spec    => options[:service_spec]
          }
      }
    end
  end
end