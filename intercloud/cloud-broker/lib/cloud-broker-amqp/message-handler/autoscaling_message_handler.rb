require 'models/service_specification'
require 'logger'

class AutoscalingMessageHandler
  @@logger       = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def initialize(offer_retriever)
    @offer_retriever = offer_retriever
  end

  def handle_message(metadata, payload)
    @@logger.info("Handling an autoscaling message: #{payload}")
    message        = JSON.parse(payload)

    service_name   = message['service_name']
    stack_type     = message['type']
    stack_to_scale = ServiceSpecification.get(service_name)
                                         .stacks(:type => stack_type)
                                         .first
    stack_to_scale.update(:status => :scaling)

    @offer_retriever.fetch_cloud_offers(stack_to_scale.service_specification)
  end
end
