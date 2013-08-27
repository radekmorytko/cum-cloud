require 'rspec'
require 'cloud_broker'

describe 'Cloud broker' do

  before {
    @storage = double('storage', :set => 1, :get => 1)
    @publisher = double('publisher', :publish => true)
    @cloud_broker = Intercloud::CloudBroker.new(:database => @storage, :publisher => @publisher)
  }
  subject { @cloud_broker  }

  context 'when receives a deploy request' do
    it 'saves the request data in the database' do
      @storage.should_receive(:set)
      subject.deploy('{}', 'user_endpoint')
    end


    it 'broadcasts it to a queue' do
      @publisher.should_receive(:publish)
      subject.deploy('{}', 'user_endpoint')
    end
  end

end