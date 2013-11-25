require 'spec_helper'
require 'cloud-broker-amqp/offer_consumer'
require 'models/service_specification'

describe OfferConsumer do
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

  let(:message) do
    JSON.generate({
      :service_id    => @service_spec.id,
      :controller_id => 'cack-controller',
      :offers        => stacks_attributes.map { |sa| { :type => sa[:type], :cost => 24  } }
    })
  end

  before do
    @service_spec = ServiceSpecification.create(
      :name => 'service name',
      :client_endpoint => 'pussylord.com:4125',
      :stacks => stacks_attributes
    )
  end

  it 'creates offers for stacks of a service specification' do
    subject.handle_cloud_offer(nil, message)
    expect(ServiceSpecification.get(@service_spec.id).stacks.reduce(0) { |sum, s| sum + s.offers.count }).to be > 0
  end

end
