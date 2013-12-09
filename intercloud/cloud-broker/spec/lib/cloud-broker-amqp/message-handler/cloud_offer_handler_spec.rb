require 'spec_helper'
require 'domain/service_specification'
require 'cloud-broker-amqp/message-handler/cloud_offer_handler'

describe CloudOfferHandler do
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
  let(:service_spec) { create_service_spec }
  let(:message) do
    JSON.generate({
      :service_id    => service_spec.id,
      :controller_id => 'cack-controller',
      :offers        => stacks_attributes.map { |sa| { :type => sa[:type], :cost => 24  } }
    })
  end

  it 'creates offers for stacks of a service specification' do
    subject.handle_message(nil, message)
    expect(ServiceSpecification.get(service_spec.id).stacks.reduce(0) { |sum, s| sum + s.offers(:examined => false).count }).to be > 0
  end

end
