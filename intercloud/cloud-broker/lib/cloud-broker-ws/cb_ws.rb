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
    # get cloud offers
    def fetch_cloud_offers(service_specification)
      settings.offer_retriever.fetch_cloud_offers(service_specification)
    end
    
    # private scope
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
    Rack::Response.new(service_specification.name, 201)
  end
end
