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

    post '/service' do #, :provides => :json do
      return 400 if not env['HTTP_IC_RETURN_ENDPOINT'] or not request.accept? 'application/json'
      request_body = JSON.parse(request.body.read)
      cloud_broker = settings.cloud_broker

      return 400 unless cloud_broker.valid?(request_body)

      id = cloud_broker.deploy(request_body, env['HTTP_IC_RETURN_ENDPOINT'])
      id.to_s
    end

    get '/service/:id' do
      puts 'dziffka'
    end

  end
end

