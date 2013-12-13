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
    @offer_retriever = double(:fetch_cloud_offers => true)
    app.set :offer_retriever, @offer_retriever
    app.set :config, ConfigUtils.load_config
  end
  
  describe 'when is to deploy a service' do
    let(:policy_set) { 
      {
        "min_vms"=>0,
        "max_vms"=>2,
        "policies"=>[
          {
            "name"=>"threshold_model",
            "parameters"=>{
              "min"=>"5",
              "max"=>"50"
            }
          }
        ]
      } 
    }
    let(:stacks_attributes) do
      [
        {
          :type => 'java',
          :instances => 2,
          :policy_set => policy_set
        },
        {
          :type => 'tomcat',
          :instances => 3,
          :policy_set => policy_set
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
      @offer_retriever.should_receive(:fetch_cloud_offers)
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

