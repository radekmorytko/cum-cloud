require 'spec_helper'
require 'models/service_specification'
require 'cloud-broker-amqp/message-handler/autoscaling_message_handler'


describe AutoscalingMessageHandler do
  let(:offer_retriever) { double(:fetch_cloud_offers => true) }
  subject { AutoscalingMessageHandler.new(offer_retriever) }

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

  def create_service_spec
    ServiceSpecification.create(
      :name => 'service name',
      :client_endpoint => 'pussylord.com:4125',
      :stacks => stacks_attributes
    )
  end

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
    subject.handle_message(nil, message)
    # has to reload to reflect the changes
    service_spec.reload
    expect(service_spec.stacks(:type => message_attributes[:type]).first.status).to eq(:scaling)
  end

  it 'fetches offers from clouds' do
    offer_retriever.should_receive(:fetch_cloud_offers).once
    subject.handle_message(nil, message)
  end

end

