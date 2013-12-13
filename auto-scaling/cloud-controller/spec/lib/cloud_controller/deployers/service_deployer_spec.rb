require 'spec_helper'
require 'cloud_controller/deployers/service_deployer'

module AutoScaling
  describe ServiceDeployer do
    let(:stack_deployer) { double(:deploy => Stack.new) }
    subject { ServiceDeployer.new(stack_deployer) }


    it { should respond_to(:deploy) }

    describe 'when deploying a service' do
      let(:service_data) { 
        {
          'name' => 'weszlo.com',
          'autoscaling_queue_name' => 'queue',
          'stacks' => [
            { 'type' => 'java' },
            { 'type' => 'ruby' }
          ]
        }
      }

      before { Stack.destroy; Service.destroy }

      it 'calls stack deployer' do
        stack_deployer.should_receive(:deploy).twice
        subject.deploy(service_data)
      end

      it 'saves the service data' do
        subject.deploy(service_data)
        service = Service.get(service_data['name'])
        expect(service).not_to be_nil
        expect(service.autoscaling_queue_name).not_to be_nil
      end

      describe 'with a duplicate service name' do
        # clean the db
        before { Service.destroy }

        it 'raises an exception' do
          subject.deploy(service_data)
          expect {subject.deploy(service_data)}.to raise_error
        end
      end
    end
  end
end
