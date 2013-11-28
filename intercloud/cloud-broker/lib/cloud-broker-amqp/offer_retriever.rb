require 'logger'
require 'common/configurable'

class OfferRetriever
  include Configurable

  @@logger       = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def initialize(publisher)
    @publisher = publisher
  end

  def fetch_cloud_offers(service_specification) 
    message_raw = prepare_fetch_cloud_offers_message(service_specification)
    message     = publishify(message_raw)
    @publisher.publish(message)
    @@logger.debug("Publishing a cloud-offers-fetching message: #{message_raw}")
  end

  def prepare_fetch_cloud_offers_message(service_specification)
    stacks_attributes = stacks_to_get_info_about(service_specification).map do |s|
      attributes = s.attributes
      [:type, :instances].reduce({}) { |acc, v| acc[v] = attributes[v]; acc }
    end 
    {
      :service_id => service_specification.id,

      # for a given stack select only limited no of attributes
      :stacks => stacks_attributes,

      # this broker id in an amqp sense
      :offers_routing_key => config['amqp']['offers_routing_key']
    }
  end

  private
  def stacks_to_get_info_about(service_specification)
    service_specification.stacks(:status => :initialized) |
    service_specification.stacks(:status => :scaling)
  end
  def publishify(message)
    message.to_json
  end
  
end
