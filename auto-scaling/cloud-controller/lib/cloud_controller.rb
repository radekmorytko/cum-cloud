require 'rubygems'
require 'common/configurable'
require 'cloud_controller/publisher'
require 'logger'
require 'amqp'
require 'json'
## TODO remove this once the offer mechanism is done
require 'securerandom'

module AutoScaling
  class CloudController
    include Configurable

    @@logger = Logger.new(STDOUT)
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
      @@instance = CloudController.new
    end


    private
    def initialize
      @publisher   = Publisher.new
      @amqp_thread = Thread.new { run }
    end

    def handle_offer_request(metadata, payload)
      @@logger.info("Handling an offer request")
      message = JSON.parse(payload)

      mock_offer = {
        :cost          => SecureRandom.random_number(100),
        :controller_id => config['amqp']['controller_routing_key'],
        :service_id    => message['service_id']
      }.to_json

      @publisher.publish(mock_offer, :routing_key => message['offers_routing_key'])
      @@logger.info("Sent a mock offer: #{mock_offer}")

    end

    def handle_deploy_request(metadata, payload)
      @@logger.info("Handling a deploy request")
    end

    def run
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
end


