require 'spec_helper'
require 'cloud-broker-amqp/offer_retriever'
require 'models/service_specification'
require 'models/stack'
require 'securerandom'

describe OfferRetriever do
  let(:publisher) { double(:publish => true) }
  subject { OfferRetriever.new(publisher) }
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

  let(:candidates) {
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
  }

  let(:deployed_candidates) {
    [
      {
        :type => 'java',
        :instances => 2,
        :policy_set => policy_set,
        :status => :deployed
      },
      {
        :type => 'tomcat',
        :instances => 3,
        :policy_set => policy_set,
        :status => :failed
      },
      {
        :type => 'python',
        :policy_set => policy_set,
        :instances => 2
      }
    ]
  }

  def create_service_spec(stacks_attributes)
    ServiceSpecification.create(
      :name => "service name #{SecureRandom.urlsafe_base64(4)}",
      :client_endpoint => 'pussylord.com:4126',
      :stacks => stacks_attributes
    )
  end

  describe 'when there is one candidate to get info' do
    let(:service_spec) { create_service_spec(deployed_candidates) }
    before { service_spec.reload }
    it 'fetches info only about it' do
      expect(subject.prepare_fetch_cloud_offers_message(service_spec)[:stacks].count).to eq 1
    end
  end
  describe 'when there are candidates to get info' do
    let(:service_spec) { create_service_spec(candidates) }
    before { service_spec.reload }
    it 'fetches info only about all of them' do
      expect(subject.prepare_fetch_cloud_offers_message(service_spec)[:stacks].count).to eq 2
    end
    
    it 'publishes message to amqp' do
      publisher.should_receive(:publish).once
      subject.fetch_cloud_offers(service_spec)
    end
  end
end
