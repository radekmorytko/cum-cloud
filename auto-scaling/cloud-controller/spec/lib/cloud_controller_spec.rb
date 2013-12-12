require 'spec_helper'
require 'cloud_controller'

module AutoScaling
  describe CloudController do
    let(:publisher) { double('Publisher', :publish => true) }
    let(:service_offer_preparer) { double('ServiceOfferPreparer', :prepare_offer => {}) }
    let(:offer_response_preparer) { double('OfferResponsePreparer', :publishify_offer => '') }
    let(:service_deployer) { double(:deploy => true) }

    subject { CloudController.new(publisher, service_offer_preparer, offer_response_preparer, service_deployer) } 

    describe 'when deploying' do
      it 'calls service deployer' do
        service_deployer.should_receive(:deploy).once
        subject.handle_deploy_request(nil, {}.to_json)
      end
    end

    describe 'when autoscaling' do
      let(:stack)       {  Stack.new }
      let(:wrong_stack) {  { :type => 'tomcat', :service_id => 15} }

      before {
        Service.destroy
        Stack.destroy
        s = Service.new(:autoscaling_queue_name => 'q', :name => 'n')
        s.stacks << stack
        s.save
      }

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
