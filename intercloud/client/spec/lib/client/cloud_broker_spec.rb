require 'spec_helper'
require 'ostruct'

describe CloudBroker do
  describe 'when it deploys a new service' do
    before do
      @message_preparer = double('preparer', :prepare_deploy_message => OpenStruct.new(:body => '', :headers => ''))
      @messenger = double('messenger', :post => '')
      @cloud_broker = CloudBroker.new(@messenger, @message_preparer)
    end
    it 'invokes appropriate method in a preparer' do
      @message_preparer.should_receive(:prepare_deploy_message)
      @cloud_broker.deploy({})
    end
    it 'posts a message in messenger' do
      @messenger.should_receive(:post)
      @cloud_broker.deploy({})
    end
  end

end
  
