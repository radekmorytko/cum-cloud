require 'spec_helper'
require 'models/service_specification'
require 'cloud-broker-amqp/message-handler/cloud_offer_handler'

describe CloudOfferHandler do
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
      :name => "service name #{SecureRandom.urlsafe_base64(4)}",
      :client_endpoint => 'pussylord.com:4125',
      :stacks => stacks_attributes
    )
  end
  let(:service_spec) { create_service_spec }
  let(:message) do
    JSON.generate({
      :service_name    => service_spec.name,
      :controller_id => 'cack-controller',
      :offers        => stacks_attributes.map { |sa| { :type => sa[:type], :cost => 24  } }
    })
  end

  it 'creates offers for stacks of a service specification' do
    subject.handle_message(nil, message)
    expect(ServiceSpecification.get(service_spec.name).stacks.reduce(0) { |sum, s| sum + s.offers(:examined => false).count }).to be > 0
  end

end
