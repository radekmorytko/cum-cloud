require 'net/http'
require 'client/configurable'
require 'logger'

class RestMessenger
  include Configurable

  @@logger = Logger.new(STDOUT)                                                                                               
  @@logger.level = Logger::DEBUG

  def post(url, body, headers, host = nil, port = nil)
    host ||= config['cloud_broker']['host']
    port ||= config['cloud_broker']['port']

    @@logger.debug("Posting a message: host -> #{host}, port -> #{port}, body -> #{body}")
    @@logger.debug("Posting a message: headers #{headers}")

    response = Net::HTTP.new(host, port)
                        .request_post(url, body, headers)
    response.body
  end
end

