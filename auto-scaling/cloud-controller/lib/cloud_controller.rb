$:.unshift "#{File.dirname(__FILE__)}/../lib"
$:.unshift File.dirname(File.expand_path('../..', __FILE__))

require 'rubygems'

# Cloud-Controller solely
require 'common/configurable'
require 'cloud_controller/publisher'
require 'cloud_controller/service_offer_preparer'
require 'cloud_controller/stack_offer_preparer'
require 'cloud_controller/stack_info_retriever'
require 'cloud_controller/offer_response_preparer'

# Remaining CSAP stack
require 'cloud-provider/cloud_provider'
require 'stack-controller/service_controller'
require 'container-controller/container_controller'

# common
require 'logger'
require 'amqp'
require 'json'

module AutoScaling
  class CloudController
    include Configurable

    @@logger       = Logger.new(STDOUT)
    @@logger.level = Logger::DEBUG

    attr_writer :service_controller
    attr_writer :container_controller

    # Handle request passed from lower layer (stack-controller)
    #
    # * *Args* :
    # - +conclusion+ -> an action that lower layer wanted to perform
    # - +stack+ -> subject of above-mentioned action
    def forward(conclusion, stack)
      @@logger.info("Received request of #{conclusion} to be performed on a stack #{stack.inspect}")

      raise 'Invalid `stack\' structure - it must have `autoscaling_key\', ' \
            'service_id and type of the stack!' unless valid_stack?(stack)

      # TODO save this key while deploying a service
      autoscaling_key = 'scaling.sap_broker_1'

      respond_with(stack.to_json, autoscaling_key)
    end

    def self.build
      instance = CloudController.new(
        Publisher.new,
        ServiceOfferPreparer.new(
          StackOfferPreparer.new(StackInfoRetriever.new)
        ),
        OfferResponsePreparer.new
      )

      @@logger.info("Cloud Controller initialized")

      setup_database
      
      config = ConfigUtils.load_config
      config['cloud_controller'] = instance

      @@logger.info("Initializing OpenNebulaClient")
      cloud_provider = OpenNebulaClient.new(config['endpoints'][config['cloud_provider_name']])

      @@logger.info("Initializing ServiceController")
      service_controller            = StackController.build(cloud_provider, config)
      instance.service_controller   = service_controller
      config['service_controller']  = service_controller

      @@logger.info("Initializing Container Controller")
      instance.container_controller = ContainerController.build(cloud_provider, config)

      @@logger.info("Cloud Controller setup completed")
      instance
    end

    # The only reason for exposing this method is testing
    def initialize(publisher, service_offer_preparer, offer_response_preparer)
      @publisher               = publisher
      @service_offer_preparer  = service_offer_preparer
      @offer_response_preparer = offer_response_preparer
    end

        
    def run
      EM.run do

        amqp_conf = config['amqp']

        AMQP.connect(:host => amqp_conf['host']) do |connection|
          @@logger.info('Connected to AMQP')
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

      begin
        service = {}
        @@logger.debug "Planning deployment of: #{service_data}"
        service = @service_controller.plan_deployment(service_data)
        @@logger.debug "Deployed service #{service.to_json}"

        @service_controller.converge(service)

        service.stacks.containers.each do |container|
          @container_controller.schedule(container, config['scheduler']['interval'])
        end

      rescue RuntimeError => e
        @@logger.error e
        raise e
      end
      service.attributes
    end

    private
    def respond_with(message, to)
      @publisher.publish(message, :routing_key => to)
    end

    
    def valid_stack?(stack)
      return false if stack.nil?
      %w(autoscaling_key service_id type).reduce(true) do |result, key|
        result and (stack.has_key?(key) or stack.has_key?(key.to_sym))
      end
    end

    def self.setup_database
      DataMapper::Logger.new($stdout, :info)
      db_path = File.join(File.expand_path(File.dirname(__FILE__)), 'auto-scaling.db')

      DataMapper.setup(:default, "sqlite://#{db_path}")
      DataMapper.auto_migrate!
    end

  end
end

