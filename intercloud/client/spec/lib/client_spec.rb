require 'spec_helper'

describe Client do
  before do
    @service_specification = {}
    @cloud_broker = double('CloudBroker', :deploy => 12)
    @database     = double('Database', :set => 0, :get => 0)
    @client = Client.new(@cloud_broker, @database)
  end
  it 'deploys a service' do
    @cloud_broker.should_receive(:deploy)
    @database.should_receive(:set)
    @client.deploy(@service_specification)
  end
end
