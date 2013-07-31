require 'rspec'
require 'sender/http_sender'
require 'pp'

module Intercloud

  describe 'Intercloud http sender' do

    it 'prepares a deploy msg' do
      own_endpoint = { 'host' => '127.0.0.1', 'port' => '11621'}
      dest_endpoint = { 'host' => 'b', 'port' => '2' }
      data_source = {'endpoint' => own_endpoint, 'cloud_broker' => dest_endpoint}
      sender = HttpSender.new
      msg = sender.prepare_deploy_message(data_source, '')
      msg.headers['Accept'].should eq 'application/json'
      msg.headers['IC_RETURN_ENDPOINT'].should eq own_endpoint['host'] + ':' + own_endpoint['port']
      msg.to.should eq dest_endpoint
    end
  end
end