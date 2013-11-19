require 'spec_helper'
require 'rack/test'
require 'cloud-broker-ws/cb_ws'
require 'common/config_utils'


describe 'CloudBrokerWS' do
  include Rack::Test::Methods

  def app
    CloudBrokerWS
  end

  before do
    @publisher = double('publisher', :publish => true)
    app.set :publisher, @publisher
    app.set :config, ConfigUtils.load_config
  end
  
  describe 'when is to deploy a service' do
    before do
      @service_spec = JSON.generate({
        :stack => 'java',
        :instances => 2,
        :name => 'enterprise-app'
      })
      @headers = {
        'HTTP_CLIENT_ENDPOINT' => '127.0.0.1:12345'
      }
    end

    it 'sends offers to cloud controllers' do
      @publisher.should_receive(:publish)
      puts "service_spec: " << @service_spec
      post '/service', @service_spec, @headers
      expect(last_response).to be_ok
    end

    it 'creates a service specification' do
      initial_count = ServiceSpecification.all.count
      post '/service', @service_spec, @headers
      expect(ServiceSpecification.all.count).to eq(initial_count+1)
    end
  end
end

