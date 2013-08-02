require 'sender/sender'
require 'ostruct'
require 'net/http'

module Intercloud
  class HttpSender
    include Sender

    def send(msg)
      http_handler = Net::HTTP.new(msg.to['host'], msg.to['port'])
      http_handler.request_post('/service', msg.body, msg.headers)
    end

    def prepare_deploy_message(data_source, _body)
      msg = OpenStruct.new
      msg.to                            = data_source['cloud_broker']
      msg.headers                       = {}
      msg.headers['Accept']             = 'application/json'
      msg.headers['IC_RETURN_ENDPOINT'] = data_source['endpoint']['host'] + ':' + data_source['endpoint']['port'].to_s
      msg
    end
  end
end