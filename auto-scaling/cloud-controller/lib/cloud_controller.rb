require 'rubygems'
require 'common/configurable'
require 'cloud_controller/publisher'
require 'cloud_controller/offers_manager'
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
      @@instance = CloudController.new( Publisher.new, OffersManager.new )
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

      message = JSON.parse(payload)

      offer = @offers_manager.get_offer(message)
      if offer
        respond_with(offer, message['offers_routing_key'])
        @@logger.info("Sent an offer: #{offer}")
      else
        @@logger.info("The service is not deployable on this cloud - nothing has been sent")
      end
    end

    private
    def respond_with(message, to)
      @publisher.publish(message, :routing_key => to)
    end

    def handle_deploy_request(metadata, payload)
      @@logger.info("Handling a deploy request")
    end

    def initialize(publisher, offers_manager)
      @publisher      = publisher
      @offers_manager = offers_manager
    end

  end
end


