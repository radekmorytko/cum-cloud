require 'spec_helper'

module Intercloud

  describe Offer do
    before {
      @offer = Offer.new
    }

    describe 'when computes the toal cost of' do
      describe 'cpu' do
        describe 'when there are two ranges and midnight involved' do
          before {
            @offer.cpu_specification = { :schedule => [
                {
                    :time_span => { :from => '9', :to => '17'},
                    :price => 20
                },
                {
                    :time_span => { :from => '17', :to => '00'},
                    :price => 15.5
                },
                {
                    :time_span => { :from => '00', :to => '09'},
                    :price => 15.5
                }
            ]}
          }
          it { expect(@offer.cpu_cost).to eq(408) }
        end
        describe 'when there is a 24 hour range' do
          before {
            @offer.cpu_specification = { :schedule => [
                {
                    :time_span => { :from => '00', :to => '00'},
                    :price => 20
                }
            ]}
          }
          it { expect(@offer.cpu_cost).to eq(480) }
        end
        describe 'when there is not enough hours' do\
          before {
            @offer.cpu_specification = { :schedule => [
                {
                    :time_span => { :from => '00', :to => '01'},
                    :price => 0.7
                }
            ]}
          }
          it { expect { @offer.cpu_cost }.to raise_exception(InvalidOfferTimeRange) }
        end
        describe 'when there there are more hours than 24' do
          before {
            @offer.cpu_specification = { :schedule => [
                {
                    :time_span => { :from => '00', :to => '26'},
                    :price => 0.7
                }
            ]}
          }
          it { expect { @offer.cpu_cost }.to raise_exception(InvalidOfferTimeRange) }
        end
      end
    end
  end
end