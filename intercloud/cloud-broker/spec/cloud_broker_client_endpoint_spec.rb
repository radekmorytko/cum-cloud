require 'app'
require 'rack/test'
require 'json'

module Intercloud

  describe "CloudBroker-ClientEndpoint" do
    include Rack::Test::Methods

      class CloudBrokerDouble
        def initialize(database)

        end
        def valid?(request_body)
          true
        end
        def deploy(request_body, client_endpoint)

        end
      end

      def app
        if @app
          @app
        else
          CloudBrokerClientEndpoint.set(:cloud_broker, CloudBrokerDouble.new(nil))
          CloudBrokerClientEndpoint.set(:environment, :test)
          @app = CloudBrokerClientEndpoint
        end
      end

      it "should accept requests with client endpoint and json payload" do
        body = JSON.generate({ :service => 'name' })
        post '/service', body , {'HTTP_IC_RETURN_ENDPOINT' => '192.168.21.153:8712', 'HTTP_ACCEPT' => "application/json"}
        last_response.should be_ok
      end

      it "should reject requests without client endpoint or json payload" do
        post '/service'
        last_response.should_not be_ok

        post '/environment', {}, {'HTTP_IC_RETURN_ENDPOINT' => '192.168.21.153:8712'}
        last_response.should_not be_ok

        post '/service', {}, {'HTTP_ACCEPT' => "application/json"}
        last_response.should_not be_ok
      end

    end
end