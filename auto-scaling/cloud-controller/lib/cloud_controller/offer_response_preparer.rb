require 'common/configurable'

class OfferResponsePreparer
  include Configurable

  def publishify_offer(offer, options)
    raise 'Offer should have set `service name` parameter!' unless options.has_key?(:service_name)
    {
      :controller_id => config['amqp']['controller_routing_key'],
      :service_name  => options[:service_name],
      :offers        => offer
    }.to_json
  end
end

