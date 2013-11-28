require 'spec_helper'
require 'cloud-broker-amqp/offer_consumer'
require 'models/service_specification'

describe OfferConsumer do

  let(:offer_retriever) { double(:fetch_cloud_offers => true) }
  subject { OfferConsumer.new(offer_retriever) }

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
  def create_service_spec
    ServiceSpecification.create(
      :name => 'service name',
      :client_endpoint => 'pussylord.com:4125',
      :stacks => stacks_attributes
    )
  end
  describe 'when handling a service-scale message' do
    let(:service_spec) { create_service_spec }
    let(:message_attributes) do 
      {
        :type => 'java',
        :service_id => service_spec.id
      }
    end
    let(:message) { message_attributes.to_json }

    before do 
      # change status of stacks to :deployed
      service_spec.stacks.update(:status => :deployed)
      # has to reload to reflect the changes
      service_spec.reload
    end

    it 'changes status of the given stack to `scaling\'' do
      subject.handle_autoscaling_message(nil, message)
      # has to reload to reflect the changes
      service_spec.reload
      expect(service_spec.stacks(:type => message_attributes[:type]).first.status).to eq(:scaling)
    end

    it 'fetches offers from clouds' do
      offer_retriever.should_receive(:fetch_cloud_offers).once
      subject.handle_autoscaling_message(nil, message)
    end
  end

  describe 'when handling a service-deployment message' do
    let(:service_spec) { create_service_spec }
    let(:message) do
      JSON.generate({
        :service_id    => service_spec.id,
        :controller_id => 'cack-controller',
        :offers        => stacks_attributes.map { |sa| { :type => sa[:type], :cost => 24  } }
      })
    end

    it 'creates offers for stacks of a service specification' do
      subject.handle_cloud_offer(nil, message)
      expect(ServiceSpecification.get(service_spec.id).stacks.reduce(0) { |sum, s| sum + s.offers(:examined => false).count }).to be > 0
    end

  end
end
