require 'spec_helper'
require 'cloud-broker-amqp/offer_consumer'
require 'models/service_specification'
require 'models/offer'

describe OfferConsumer do
  before do
    @offer_consumer = OfferConsumer.new
    @service_spec   = ServiceSpecification.create(
      :specification => JSON.generate({:a => 'ala'}),
      :client_endpoint => 'client endpoint'
    )
    @message = JSON.generate({
      :service_id => @service_spec.id,
      :cost => 123.12,
      :controller_id => 'controller_dfsa'
    })
  end

  it 'creates an offer for the given ss' do
    offers_count = ServiceSpecification.get(@service_spec.id).offers.count
    @offer_consumer.handle_cloud_offer('', @message)
    expect(ServiceSpecification.get(@service_spec.id).offers.count).to eq(offers_count+1)
  end

end
