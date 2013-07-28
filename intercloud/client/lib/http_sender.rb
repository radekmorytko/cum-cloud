require 'ostruct'
require 'net/http'

module Intercloud
  class HttpSender
    def send(msg)
      http_handler = Net::HTTP.new(msg.to['host'], msg.to['port'])
      response = http_handler.request_post('/service', msg.body, msg.headers)
    end

    def prepare_deploy_message(data_source, body)
      msg = OpenStruct.new
      msg.to = data_source['cloud_broker']
      msg.headers = {}
      msg.headers['Accept'] = 'application/json'
      msg.headers['IC_RETURN_ENDPOINT'] = data_source['endpoint']['host'] + ':' + data_source['endpoint']['port'].to_s
      msg.body = body
      msg
    end
  end
end
