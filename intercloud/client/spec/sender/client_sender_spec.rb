require 'rspec'
require 'sender/sender'
require 'sender/client_sender'
require 'json'

module Intercloud
  describe "Client sender" do

    class ConcreteFailingSenderDouble
      include Sender
      def send(msg)
        OpenStruct.new(:code => 400)
      end
    end

    class ConcreteSenderDouble
      include Sender
      def send(msg)
        OpenStruct.new(:code => 200, :body => '12')
      end
    end

    context 'when response has a status code other than 200' do
      before { @sender = ClientSender.new(ConcreteFailingSenderDouble.new) }
      it 'raises error' do
          expect { @sender.send('')  }.to raise_error(DeploymentFailed)
      end
    end

    context 'when response succeeded' do
      subject { @sender = ClientSender.new(ConcreteSenderDouble.new) }
      it 'returns the id of a newly created service' do
        subject.send(nil).to_i.should eq 12
      end
    end

  end
end