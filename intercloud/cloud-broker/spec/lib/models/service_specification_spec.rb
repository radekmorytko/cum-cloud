require 'spec_helper'

describe ServiceSpecification do
  def create_service_spec
    @service_spec = ServiceSpecification.create!(
      :specification => {},
      :client_endpoint => 'client endpoint'
    )
  end
  def create_service_spec_with_offers
    create_service_spec
    @service_spec.offers.create!(
        :cost => 123.1,
        :controller_id => '1fdsfsda',
        :received_at => DateTime.new(2013, 11, 18, 13, 20, 56)
      )
  end
  describe 'when it has already been deployed' do
    before do
      create_service_spec
      @service_spec.deployed = true
    end
    it 'is not applicable for deployment' do
      expect(@service_spec.ready_to_deploy?).to be_false
    end
  end
  describe 'when has no offers' do
    before { create_service_spec }
    it 'is not ready for deployment' do
      expect(@service_spec.ready_to_deploy?).to be_false
    end
  end
  describe 'when has some offers created some time ago' do
    before do
      create_service_spec_with_offers
    end
    it 'is ready for deployment' do 
      expect(@service_spec.ready_to_deploy?).to be_true
    end
  end
end
