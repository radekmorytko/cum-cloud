require 'common/configurable'
require 'json'
require 'logger'
## TODO remove this once the offer mechanism is done
require 'securerandom'

class OfferConsumer
  include Configurable

  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def initialize(publisher)
    @publisher = publisher
  end

  def handle_offer_request(metadata, payload)
    @@logger.info('Handling an offer request')

    message = JSON.parse(payload)

    mock_offer = {
      :cost          => SecureRandom.random_number(100),
      :controller_id => config['amqp']['controller_routing_key'],
      :service_id    => message['service_id']
    }.to_json

    @publisher.publish(mock_offer, :routing_key => message['offers_routing_key'])
    @@logger.info("Sent a mock offer: #{mock_offer}")
  end

  def handle_deploy_request(metadata, payload)
    @@logger.info('Handling deploy request')
  end
end
