require 'spec_helper'
require 'cloud-broker-amqp/offer_retriever'
require 'domain/service_specification'
require 'domain/stack'

describe OfferRetriever do
  let(:publisher) { double(:publish => true) }
  subject { OfferRetriever.new(publisher) }

  let(:candidates) {
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
  }

  let(:deployed_candidates) {
    [
      {
        :type => 'java',
        :instances => 2,
        :status => :deployed
      },
      {
        :type => 'tomcat',
        :instances => 3,
        :status => :failed
      },
      {
        :type => 'python',
        :instances => 2
      }
    ]
  }

  def create_service_spec(stacks_attributes)
    ServiceSpecification.create(
      :name => 'service name',
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
