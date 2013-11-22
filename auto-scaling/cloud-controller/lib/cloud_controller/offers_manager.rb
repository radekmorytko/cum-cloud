require 'rubygems'
require 'logger'
require 'common/configurable'
## TODO remove this once the offer mechanism is done
require 'securerandom'

class OffersManager
  include Configurable

  @@logger       = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def get_offer(service_specification)
    if deployable?(service_specification)
      prepare_offer(service_specification)
    else
      nil
    end
  end

  private
  def prepare_offer(service_specification)
    {
      :cost          => SecureRandom.random_number(100),
      :controller_id => config['amqp']['controller_routing_key'],
      :service_id    => service_specification['service_id']
    }.to_json
  end

  def deployable?(service_specification)
    true
  end
end
