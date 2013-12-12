require 'models/service_specification'
require 'logger'

class AutoscalingMessageHandler
  @@logger       = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def initialize(offer_retriever)
    @offer_retriever = offer_retriever
  end

  def handle_message(metadata, payload)
    @@logger.info("Handling an autoscaling message")
    message        = JSON.parse(payload)

    service_id     = message['service_id']
    stack_type     = message['type']
    stack_to_scale = ServiceSpecification.get(service_id)
                                         .stacks(:type => stack_type)
                                         .first
    stack_to_scale.update(:status => :scaling)

    @offer_retriever.fetch_cloud_offers(stack_to_scale.service_specification)
  end
end
