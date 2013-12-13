require 'common/config_utils'
require 'common/database_utils'
require 'cloud-broker-ws/cb_ws'
require 'cloud-broker-amqp/offer_retriever'
require 'cloud-broker-amqp/message-handler/cloud_offer_handler'
require 'cloud-broker-amqp/message-handler/autoscaling_message_handler'
require 'cloud-broker-amqp/publisher'
require 'cloud-broker-amqp/service_deployer'
require 'resource-mapping/offer_selector'
require 'models/models'
require 'amqp'
  
def run(opts)
  EM.run do

    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG

    config = opts[:config]
    require 'pp'
    pp config

    server    = 'thin'
    host      = '0.0.0.0'
    port      = config['port']
    web_app   = opts[:app]
    multicast_publisher = opts[:publisher]

    ## initalize database
    DatabaseUtils.initialize_database

    dispatch = Rack::Builder.app do
      map '/' do
        run web_app
      end
    end

    Rack::Server.start({
      :app             => dispatch,
      :server          => server,
      :Host            => host,
      :Port            => port,
    })

    amqp_conf = config['amqp']
    AMQP.connect(:host => amqp_conf['host']) do |connection|
      logger.info('Connected to AMQP')

      channel                      = AMQP::Channel.new(connection)

      multicast_publisher.exchange = channel.fanout(amqp_conf['offers_exchange_name'])
      p2p_publisher                = Publisher.new
      p2p_publisher.exchange       = channel.default_exchange

      service_deployer             = ServiceDeployer.new(OfferSelector.new, p2p_publisher)

      # message handlers
      autoscaling_message_handler  = AutoscalingMessageHandler.new(OfferRetriever.new(multicast_publisher))
      cloud_offer_handler          = CloudOfferHandler.new

      channel.queue(amqp_conf['offers_routing_key'])
             .subscribe(&cloud_offer_handler.method(:handle_message))
      channel.queue(amqp_conf['autoscaling_queue_name'])
             .subscribe(&autoscaling_message_handler.method(:handle_message))

      EM.add_periodic_timer(amqp_conf['offers_select_interval']) do
        service_deployer.deploy_services
      end

      Signal.trap('INT') {
        logger.close
        connection.close { EM.stop }
      }
    end
  end
end
  
config    = ConfigUtils.load_config
publisher = Publisher.new
run :app => CloudBrokerWS.new(nil, :offer_retriever => OfferRetriever.new(publisher), :publisher => publisher, :config => config), :publisher => publisher, :config => config
      
