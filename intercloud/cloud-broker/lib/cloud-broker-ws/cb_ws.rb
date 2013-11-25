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
    def prepare_fetch_cloud_offers_message(service_specification)
      stacks_attributes = service_specification.stacks.map do |s|
        attributes = s.attributes
        [:type, :instances].reduce({}) { |acc, v| acc[v] = attributes[v]; acc }
      end 
      {
        :service_id => service_specification.id,

        # for a given stack select only limited no of attributes
        :stacks => stacks_attributes,

        # this broker id in an amqp sense
        :offers_routing_key => settings.config['amqp']['offers_routing_key'],
      }.to_json
    end

    def create_stacks(stacks_attr_list, service_specification)
      stacks_attr_list.each do |stack_attrs|
        service_specification.stacks.create(stack_attrs)
      end
    end

    def create_service_specification(params, headers)
      ServiceSpecification.create(
        :name            => params['name'],
        :client_endpoint => headers['HTTP_CLIENT_ENDPOINT']
      ) 
    end
  end

  post '/service' do
    return 400 if not env['HTTP_CLIENT_ENDPOINT'] or not request.accept? 'application/json'
    @@logger.info("Got a service deployment message")
    message = JSON.parse(request.body.read)
    service_specification = create_service_specification(message, env)
    # create stacks for the give service spec
    create_stacks(message['stacks'], service_specification)
    fetch_cloud_offers(service_specification)
    Rack::Response.new(service_specification.id.to_s, 201)
  end
end
