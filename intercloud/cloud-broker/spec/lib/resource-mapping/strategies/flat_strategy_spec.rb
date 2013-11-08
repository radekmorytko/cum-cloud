require 'spec_helper'

module Intercloud
  describe FlatStrategy do

    before(:each) {
      @strategy = FlatStrategy.new
    }

    describe 'when the offers has only CPU' do
      before {
        @offer1 = Offer.new(:cpu_specification => { :schedule => [{:time_span => {:from => '00', :to => '00'}, :price => 15.41}], 'unit' => 1400 })
        @offer2 = Offer.new(:cpu_specification => { :schedule => [{:time_span => {:from => '00', :to => '00'}, :price => 16}], 'unit' => 1200})
        @offer3 = Offer.new(:cpu_specification => { :schedule => [{:time_span => {:from => '00', :to => '00'}, :price => 9.3}], 'unit' => 1500})
        @offers = [@offer1, @offer2, @offer3]
      }
      it 'chooses the cheapest one' do
        expect(@strategy.match(nil, [@offer1, @offer2, @offer3])).to equal(@offer3)
      end

      describe 'and the requirement is too high' do
        before { @service_spec = ServiceSpecification.new(:stack => 'tomcat', :instances => 2, :name => 'ble', :cpu_unit => 2000) }
        it 'returns nil' do
          expect(@strategy.match(@service_spec, @offers)).to be_nil
        end
      end

    end

    describe 'when there are no offers' do
      it 'returns nil' do
        expect(@strategy.match(nil, [])).to be_nil
      end
    end
  end
end