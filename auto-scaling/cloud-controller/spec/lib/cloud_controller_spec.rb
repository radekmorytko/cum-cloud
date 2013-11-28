require 'spec_helper'
require 'cloud_controller'

module AutoScaling
  describe CloudController do
    let(:publisher) { double('Publisher', :publish => true) }
    let(:service_offer_preparer) { double('ServiceOfferPreparer', :prepare_offer => {}) }
    let(:offer_response_preparer) { double('OfferResponsePreparer', :publishify_offer => '') }

    subject { CloudController.new(publisher, service_offer_preparer, offer_response_preparer) } 

    describe 'when autoscaling' do
      let(:stack)       {  { :autoscaling_key => 'akey', :type => 'tomcat', :service_id => 15} }
      let(:wrong_stack) {  { :type => 'tomcat', :service_id => 15} }

      it 'checks stack argument structure' do
        expect { subject.forward(nil, nil)         } .to raise_error
        expect { subject.forward(nil, wrong_stack) } .to raise_error
        expect { subject.forward(nil, stack)       } .not_to raise_error
      end

      it 'notifies CB about the need to scale the environment' do
        publisher.should_receive(:publish).once
        subject.forward(nil, stack)
      end
    end

  end
end
