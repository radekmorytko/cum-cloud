require 'spec_helper'
require 'domain/domain'
require 'cloud_controller/deployers/stack_deployer'

module AutoScaling
  describe StackDeployer do
    let(:stack_controller) { double(:plan_deployment => OpenStruct.new(:containers => [1, 2]), :converge => true) }
    let(:container_controller) { double(:schedule => true) }

    subject { StackDeployer.new(stack_controller, container_controller) }

    let(:stack_data) { { :type => 'java', :instances => 3 } }


    it { should respond_to(:deploy) }

    describe 'when deploying a stack' do
      it 'calls stack and container controllers' do
        stack_controller.should_receive(:plan_deployment).once
        stack_controller.should_receive(:converge).once
        container_controller.should_receive(:schedule).twice
        subject.deploy(stack_data)
      end
    end
  end
end

