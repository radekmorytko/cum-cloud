require 'models/offer'
require 'models/service_specification'

class OfferConsumer
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def handle_cloud_offer(metadata, payload)
    @@logger.info("Handling an offer from a cloud")

    message = JSON.parse(payload)
    @@logger.debug("Message: #{message}")
    service_specification = ServiceSpecification.get(message['service_id'])
    service_specification.offers.create(
      :cost          => message['cost'],
      :controller_id => message['controller_id']
    )
  end
end
