require 'rubygems'
require 'common/config_utils'
require 'cloud_controller/publisher'
require 'cloud_controller/offer_consumer'
require 'logger'
require 'amqp'

module AutoScaling
  class CloudController
    @@logger = Logger.new(STDOUT)
    @@instance = nil

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
      Thread.start { CloudController.run }
      @@instance = CloudController.new
    end

    def self.run
      EM.run do

        config = ConfigUtils.load_config
        amqp_conf = config['amqp']

        AMQP.connect(:host => amqp_conf['host']) do |connection|
          @@logger.info('Connected to AMQP')
          channel = AMQP::Channel.new(connection)

          offer_consumer = OfferConsumer.new(Publisher.new(channel.default_exchange))

          offers_exchange = channel.fanout(amqp_conf['offers_exchange_name'])
          channel.queue('').bind(offers_exchange).subscribe(&offer_consumer.method(:handle_offer_request))
          channel.queue(amqp_conf['controller_routing_key']).subscribe(&offer_consumer.method(:handle_deploy_request))
        end

      end
    end
  end
end


