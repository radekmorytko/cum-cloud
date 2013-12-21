$:.unshift "#{File.dirname(__FILE__)}/../lib"
$:.unshift File.dirname(File.expand_path('../..', __FILE__))

# Cloud-Controller solely
require 'common/configurable'
require 'cloud_controller/publisher'
require 'cloud_controller/service_offer_preparer'
require 'cloud_controller/stack_offer_preparer'
require 'cloud_controller/stack_info_retriever'
require 'cloud_controller/offer_response_preparer'
require 'cloud_controller/deployers/service_deployer'
require 'cloud_controller/deployers/stack_deployer'
require 'domain/domain'

# Remaining CSAP stack
require 'cloud-provider/cloud_provider'
require 'stack-controller/stack_controller'
require 'container-controller/container_controller'

# common
require 'logger'
require 'amqp'
require 'json'
require 'pp'

module AutoScaling
  class CloudController
    include Configurable

    @@logger       = Logger.new(STDOUT)
    @@logger.level = Logger::DEBUG

    attr_writer :service_deployer

    # Handle request passed from lower layer (stack-controller)
    #
    # * *Args* :
    # - +conclusion+ -> an action that lower layer wanted to perform
    # - +stack+ -> subject of above-mentioned action
    def forward(conclusion, stack)
      raise 'Improper type of <<stack>> argument' unless stack.is_a?(Stack)

      @@logger.info("Received request of #{conclusion} to be performed on a stack #{stack.inspect}")

      routing_key = stack.service.autoscaling_queue_name
      respond_with(stack.to_json, routing_key)
    end

    def self.build
      setup_database

      instance = CloudController.new(
        Publisher.new,
        ServiceOfferPreparer.new(
          StackOfferPreparer.new(StackInfoRetriever.new)
        ),
        OfferResponsePreparer.new,
        nil # it is left for tests only
      )

      @@logger.info("Cloud Controller initialized")
      
      config = ConfigUtils.load_config
      config['cloud_controller'] = instance

      @@logger.info("Initializing OpenNebulaClient")
      cloud_provider = OpenNebulaClient.new(config['endpoints'][config['cloud_provider_name']])

      @@logger.info("Initializing StackController")
      capacity = {}
      if config['endpoints'][config['cloud_provider_name']].key?('capacity')
        capacity = config['endpoints'][config['cloud_provider_name']]['capacity']
      end
      requirements = config['mappings']['opennebula']['stacks']
      reservation_manager = ReservationManager.new(cloud_provider, capacity, requirements)
      stack_controller = StackController.build(cloud_provider, reservation_manager, config)
      stack_controller.cloud_controller = instance

      @@logger.info("Initializing Container Controller")
      container_controller = ContainerController.build(cloud_provider, reservation_manager)
      container_controller.stack_controller = stack_controller

      instance.service_deployer = ServiceDeployer.new(
        StackDeployer.new(
          stack_controller, container_controller
        )
      )

      @@logger.info("Cloud Controller setup completed")
      instance
    end

    # The only reason for exposing this method is testing
    def initialize(publisher, service_offer_preparer, offer_response_preparer, service_deployer)
      @publisher               = publisher
      @service_offer_preparer  = service_offer_preparer
      @offer_response_preparer = offer_response_preparer
      @service_deployer        = service_deployer
    end

        
    def run
      EM.run do

        amqp_conf = config['amqp']

        AMQP.connect(:host => amqp_conf['host']) do |connection|
          @@logger.info("Connected to AMQP (host: #{amqp_conf['host']})")
          channel = AMQP::Channel.new(connection)

          @publisher.exchange = channel.default_exchange
          offers_exchange     = channel.fanout(amqp_conf['offers_exchange_name'])

          # the queue name will be generated by AMQP
          channel.queue('').bind(offers_exchange).subscribe(&method(:handle_offer_request))

          channel.queue(amqp_conf['controller_routing_key']).subscribe(&method(:handle_deploy_request))
        end
      end
    end

    def handle_offer_request(metadata, payload)
      @@logger.info("Handling an offer request")
      service_specification = JSON.parse(payload)
      offer = @service_offer_preparer.prepare_offer(service_specification)
      if offer
        response = @offer_response_preparer.publishify_offer(offer, :service_id => service_specification['service_id'])
        respond_with(response, service_specification['offers_routing_key'])
        @@logger.info("Respondend with an offer: #{response}")
      else
        @@logger.info("The service is not deployable on this cloud - nothing has been sent")
      end
      offer
    end

    def handle_deploy_request(metadata, payload)
      @@logger.info("Handling a deploy request")
      service_data = JSON.parse(payload)
      @@logger.debug("Payload: #{service_data.inspect}")
      @service_deployer.deploy(service_data)
    end

    private
    def respond_with(message, to)
      @publisher.publish(message, :routing_key => to)
    end

    def self.setup_database
      config = ConfigUtils.load_config['database']
      DataMapper::Logger.new($stdout, config['log_level'].to_sym)
      db_path = File.join(File.expand_path(File.dirname(__FILE__)), 'auto-scaling.db')

      #DataMapper.setup(:default, 'sqlite::memory:')

      DataMapper::Model.raise_on_save_failure = true
      DataMapper.setup(:default, "sqlite://#{db_path}")
      DataMapper.auto_migrate!
    end

  end
end

