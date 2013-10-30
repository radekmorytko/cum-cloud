require 'spec_helper'

module Intercloud
  describe FlatStrategy do

    before(:each) {
      @strategy = FlatStrategy.new
    }

    describe 'when the offers has only CPU' do
      before {
        @offer1 = Offer.new(:cpu_specification => [{:time_span => {:from => '00', :to => '00'}, :price => 15.41 }])
        @offer2 = Offer.new(:cpu_specification => [{:time_span => {:from => '00', :to => '00'}, :price => 16 }])
        @offer3 = Offer.new(:cpu_specification => [{:time_span => {:from => '00', :to => '00'}, :price => 9.3 }])
      }
      it 'chooses the cheapest one' do
        expect(@strategy.match(nil, [@offer1, @offer2, @offer3])).to equal(@offer3)
      end
    end
  end
end