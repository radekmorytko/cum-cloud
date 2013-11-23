require 'common/configurable'

class OfferResponsePreparer
  include Configurable

  def publishify_offer(offer, options)
    raise 'Offer should have set `service id` parameter!' unless options.has_key?(:service_id)
    {
      :controller_id => config['amqp']['controller_routing_key'],
      :service_id    => options[:service_id],
      :offers        => offer
    }.to_json
  end
end

