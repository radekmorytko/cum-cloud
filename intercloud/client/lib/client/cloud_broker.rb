require 'logger'

# stub (in an rpc sense) of a cloud broker
class CloudBroker
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def initialize(messenger, message_preparer)
    @messenger = messenger
    @message_preparer = message_preparer
  end
  def deploy(service_specification)
    message = @message_preparer.prepare_deploy_message(service_specification)
    @@logger.debug("Message headers: #{message.headers}")
    @messenger.post('/service', message.body, message.headers)
  end
end

