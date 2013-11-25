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
    let(:stacks_attributes) do
      [
        {
          :type => 'java',
          :instances => 2
        },
        {
          :type => 'tomcat',
          :instances => 3
        }
      ]
    end
    let(:service_spec) do
      JSON.generate({
        :name => 'sample service',
        :stacks => stacks_attributes
      })
    end 

    let(:headers) { {'HTTP_CLIENT_ENDPOINT' => '127.0.0.1:12345'} }

    it 'sends offers to cloud controllers' do
      @publisher.should_receive(:publish)
      post '/service', service_spec, headers
      expect(last_response).to be_ok
    end

    it 'creates a service specification' do
      post '/service', service_spec, headers
      expect(ServiceSpecification.get(last_response.body)).not_to be_nil 
    end

    it 'creates stacks for the given service' do
      post '/service', service_spec, headers
      expect(ServiceSpecification.get(last_response.body).stacks.count).to eq stacks_attributes.count
    end
  end
end

