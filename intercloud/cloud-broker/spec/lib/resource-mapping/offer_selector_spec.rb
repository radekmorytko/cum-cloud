require 'spec_helper'
require 'resource-mapping/offer_selector'
require 'domain/offer'

describe OfferSelector do

  let(:offers) do
    [
      # from one controller
      Offer.new(:cost => 7,  :controller_id => 'c1'),
      Offer.new(:cost => 3,  :controller_id => 'c1'),

      # from another
      Offer.new(:cost => 6,  :controller_id => 'c2'),
      Offer.new(:cost => 5,  :controller_id => 'c2'),
    ]
  end

  let(:min_offer) { offers[1] }

  it 'returns an offer instance' do
    expect(subject.select(offers)).to be_instance_of(Offer)
  end

  it 'returns an offer of the minimal price' do
    expect(subject.select(offers)).to eql(min_offer)
  end

end
