require 'common/config_utils'
require 'models/models'
require 'sinatra'
require 'json'
require 'logger'

class CloudBrokerWS < Sinatra::Base
  use Rack::CommonLogger

  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def initialize(app = nil, options = {})
    super(app)
    Sinatra::Base.set options
  end

  helpers do
    # publish a message to AMQP
    def publish(message, options = {})
      settings.publisher.publish(message, options)
    end

    # get cloud offers
    def fetch_cloud_offers(service_specification)
      message = prepare_fetch_cloud_offers_message(service_specification)
      @@logger.debug("Publishing a cloud-offers-fetching message: #{message}")
      publish(message)
    end
    
    # private scope
    def prepare_fetch_cloud_offers_message(service_spec)
      {
        :specification => service_spec.specification,
        :offers_routing_key => settings.config['amqp']['offers_routing_key'],
        :service_id => service_spec.id
      }.to_json
    end
  end

  post '/service' do
    return 400 if not env['HTTP_CLIENT_ENDPOINT'] or not request.accept? 'application/json'
    @@logger.info("Got a service deployment message")
    message = request.body.read
    service_specification = ServiceSpecification.create(
      :specification   => message,
      :client_endpoint => env['HTTP_CLIENT_ENDPOINT']
    )
    fetch_cloud_offers(service_specification)
    Rack::Response.new(service_specification.id.to_s, 201)
  end
end
