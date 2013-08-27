module Intercloud
  class CloudBroker

    def initialize(options = {})
      @database      = options[:db]
      @message_queue = options[:message_queue]
    end

    def deploy(service_spec, client_endpoint)
      id = save_deploy_request(service_spec, client_endpoint)
      @message_queue << {:id => id, :service_spec => service_spec}.to_json
      id
    end

    def valid?(service_spec)
      true
    end

    private

    def save_deploy_request(service_spec, client_endpoint)
      database_record = prepare_database_record(
          :service_spec    => service_spec,
          :client_endpoint => client_endpoint
      )
      @database.set(database_record[:id], database_record[:record])
      database_record[:id]
    end

    def generate_id(seed)
      Digest::SHA1.hexdigest(seed)
    end

    def prepare_database_record(options)
      {
          :id => generate_id(options[:client_endpoint] + options[:service_spec]),
          :record => JSON.generate({
            :client_endpoint => options[:client_endpoint],
            :service_spec    => options[:service_spec]
          })
      }
    end
  end
end