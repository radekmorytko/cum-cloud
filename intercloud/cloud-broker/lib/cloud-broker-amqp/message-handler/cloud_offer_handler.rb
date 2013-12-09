require 'domain/service_specification'
require 'logger'

class CloudOfferHandler
  @@logger       = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  ##
  # Creates an offer for the service specification's STACK
  #
  # Offer is of the form:
  # {
  #   'service_id': ID,
  #   'controller_id': CID,  <- cloud controller routing key
  #   'offers': [
  #     {'cost': X, 'type': Y},
  #     {'cost': R, 'type': S}
  #   ]
  # }
  def handle_message(metadata, payload)
    @@logger.info("Handling an offer from a cloud")

    message = JSON.parse(payload)
    @@logger.debug("Message: #{message}")
    service_specification = ServiceSpecification.get(message['service_id'])
    message['offers'].each { |offer| create_offer(service_specification, offer, message['controller_id']) }
  end

  private
  def create_offer(service_specification, offer, controller_id)

    # Check if there is a stack that has the same type as the offer
    stacks = service_specification.stacks(:type => offer['type'])
    raise "There can be only one stack of type `#{offer['type']}`" if stacks.count != 1

    stacks.first
          .offers
          .create(
            :cost => offer['cost'],
            :controller_id => controller_id
          )
  end
end
