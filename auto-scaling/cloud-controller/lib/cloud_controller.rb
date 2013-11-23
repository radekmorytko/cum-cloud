$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'rubygems'
require 'common/configurable'
require 'cloud_controller/publisher'
require 'cloud_controller/service_offer_preparer'
require 'cloud_controller/stack_offer_preparer'
require 'cloud_controller/offer_response_preparer'
require 'logger'
require 'amqp'
require 'json'

module AutoScaling
  class CloudController
    include Configurable

    @@logger       = Logger.new(STDOUT)
    @@logger.level = Logger::DEBUG
    @@instance = nil

    attr_reader :amqp_thread

    # Handle request passed from lower layer (service-controller)
    #
    # * *Args* :
    # - +conclusion+ -> an action that lower layer wanted to perform
    # - +stack+ -> subject of above-mentioned action
    def forward(conclusion, stack)
      @@logger.info("Received request of #{conclusion} to be performed on #{stack}")
    end

    def self.build
      raise 'There can be only one instance of CloudController' unless @@instance.nil?
      @@instance = CloudController.new(
        Publisher.new,
        ServiceOfferPreparer.new(StackOfferPreparer.new),
        OfferResponsePreparer.new
      )
      @@instance.run
      @@instance
    end


        
    def run
      @amqp_thread = Thread.new do
        EM.run do

          amqp_conf = config['amqp']

          AMQP.connect(:host => amqp_conf['host']) do |connection|
            @@logger.info('Connected to AMQP')
            channel = AMQP::Channel.new(connection)

            @publisher.exchange = channel.default_exchange

            offers_exchange = channel.fanout(amqp_conf['offers_exchange_name'])
            channel.queue('').bind(offers_exchange).subscribe(&method(:handle_offer_request))
            channel.queue(amqp_conf['controller_routing_key']).subscribe(&method(:handle_deploy_request))
          end
        end
      end
    end

    def handle_offer_request(metadata, payload)
      @@logger.info("Handling an offer request")
      request = JSON.parse(payload)
      offer = @service_offer_preparer.prepare_offer(request['specification'])
      if offer
        response = @offer_response_preparer.publishify_offer(offer, :service_id => request['service_id'])
        respond_with(response, request['offers_routing_key'])
        @@logger.info("Respondend with an offer: #{response}")
      else
        @@logger.info("The service is not deployable on this cloud - nothing has been sent")
      end
      offer
    end

    private
    def respond_with(message, to)
      @publisher.publish(message, :routing_key => to)
    end

    def handle_deploy_request(metadata, payload)
      @@logger.info("Handling a deploy request")
    end

    def initialize(publisher, service_offer_preparer, offer_response_preparer)
      @publisher               = publisher
      @service_offer_preparer  = service_offer_preparer
      @offer_response_preparer = offer_response_preparer
    end
  end
end


