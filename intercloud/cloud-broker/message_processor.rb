module Intercloud
  class MessageProcessor
    def initialize(schedule_queue, config)
      @config          = config
      @schedule_queue  = schedule_queue
    end

    def run
      EM.run do
        AMQP.connect('amqp://' + @config['amqp']['host'] + ':' + @config['amqp']['port'].to_s) do |connection|
          channel = AMQP::Channel.new(connection)

          offers_exchange = channel.fanout(@config['amqp']['offers_exchange_name'])

          channel.queue(@config['amqp']['offers_routing_key']).subscribe do |metadata, payload|
            puts "Got an offer! #{metadata.type} and payload: #{payload}"
            message = JSON.parse(payload)

            puts 'Adding the offer to db'
            # add the offer to the DB
            service_specification = ServiceSpecification.get(message['id'])
            service_specification.offers.create(
                :controller_id => message['controller_routing_key'],
                :price         => message['offer']['price'],
                :memory        => message['offer']['memory']
            )
            service_specification.save!

            # to change
            channel.default_exchange.publish("I'm accepting your offer", :routing_key => message['controller_routing_key'])
          end

          EM.add_periodic_timer(1) do

            # getting offers from clouds
            while not @schedule_queue.empty?
              puts 'sending a message: ' + (msg = @schedule_queue.pop).to_s
              offers_exchange.publish(msg)
            end
          end

          Signal.trap('INT') {
            puts 'Closing AMQP connection'
            connection.close {
              EM.stop
            }
          }
        end
      end

    end
  end
end