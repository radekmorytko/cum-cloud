require 'rspec'
require 'client'

module Intercloud

  describe 'Intercloud client' do
    before(:each) do
      @db = double('storage', :set => 1, :get => 1)
      @sender = double('sender', :send => 1, :prepare_deploy_message => 1)
      @client = Client.new(@sender, @db)
    end

    it 'saves id of the deployed env' do
      @db.should_receive(:set)
      @client.deploy(nil)
    end

    it 'sends a deploy messsage' do
      @sender.should_receive(:send)
      @sender.should_receive(:prepare_deploy_message)
      @client.deploy(nil)
    end
  end

end