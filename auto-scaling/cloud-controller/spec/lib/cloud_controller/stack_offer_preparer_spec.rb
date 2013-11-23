require 'spec_helper'
require 'cloud_controller/stack_offer_preparer'

describe StackOfferPreparer do

  let(:stack) { {:type => 'java', :instances => 4} }

  describe 'when a stack is NOT deployable' do
    let(:stack_info_retriever) { double('Stack Info Retriever', :deployable? => false) }
    subject { StackOfferPreparer.new(stack_info_retriever) }

    it 'does not prepare and offer' do
      expect(subject.prepare_offer(stack)).to be_nil
    end
  end


  describe 'when a stack is deployable' do
    let(:stack_info_retriever) { double('Stack Info Retriever', :deployable? => true) }
    subject { StackOfferPreparer.new(stack_info_retriever).prepare_offer(stack) }

    it { should have_key(:cost) }
    it { should be_instance_of Hash }
  end
end
