module Intercloud

  class CloudBrokerClientEndpoint < Sinatra::Base

    #set :environment, ENV['INTERCLOUD_ENV'] || ENV['RACK_ENV'] || :development

    #configure do
    #  set :port, 33331
    #  set :config, YAML.load_file('config/config.yaml')
    #end

    #configure :development do
    #  register Sinatra::Reloader
    #
    #  database = {}
    #
    #  def database.set(key, val)
    #    self[key]= val
    #  end
    #
    #  def database.get(key)
    #    self[key]
    #  end
    #
    #  def database.del(key)
    #    self.delete(key)
    #  end
    #
    #  set :db, database
    #end


    #configure :production do
    #  set :db, Redis.new(:host => settings.config['redis']['host'], :port => settings.config['redis']['port'])
    #end


    #configure do
    #  set :cloud_broker, Intercloud::CloudBroker.new(settings.db)
    #end

    helpers do

      def prepare_service_spec_request(service_spec)
        message = service_spec.attributes
        message[:offers_routing_key] = settings.offers_routing_key
        message.delete(:client_endpoint)
        message.to_json
      end
    end

    post '/service' do #, :provides => :json do
      return 400 if not env['HTTP_IC_RETURN_ENDPOINT'] or not request.accept? 'application/json'

      service_specification_attributes                   = JSON.parse(request.body.read)
      service_specification_attributes[:client_endpoint] = env['HTTP_IC_RETURN_ENDPOINT']

      service_specification = ServiceSpecification.create!(service_specification_attributes)
      settings.schedule_message_queue << prepare_service_spec_request(service_specification)
      Rack::Response.new(service_specification.id.to_s, 201)
    end

    get '/service/:id' do
      puts 'dziffka'
    end

  end
end

