require 'spec_helper'
require 'cloud_controller/offer_response_preparer'

describe OfferResponsePreparer do
  let(:preparer) { OfferResponsePreparer.new }

  describe 'when has valid input parameters' do
    let(:offer) { [] }
    let(:options) { { :service_id => 'kubus puchatek' } }

    subject { preparer.publishify_offer(offer, options)}
    it { should be_instance_of String }
  end
  describe 'when has INVALID input parameters' do
    let(:offer) { [] }
    let(:options) { { :random_key => 'papa smerf' } }

    it 'raises an error' do 
      expect { preparer.publishify_offer(offer, options) }.to raise_error
    end
  end
end
