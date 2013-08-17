module Intercloud
  class MessageProcessor
    def initialize(queue, config = YAML.load_file('config/config.yaml'))
      @config = config
      @queue  = queue
    end

    def run
      EM.run do
        AMQP.connect('amqp://' + @config['amqp']['host'] + ':' + @config['amqp']['port'].to_s) do |connection|
          channel = AMQP::Channel.new(connection)
          exchange = channel.fanout(@config['amqp']['exchange_name'])

          channel.queue(@config['amqp']['routing_key']).subscribe do |metadata, payload|
            puts "Received message with type: #{metadata.type} and payload: #{payload}"
          end

          EM.add_periodic_timer(1) do
            #puts 'sending: ' + queue.pop while not queue.empty?
            while not @queue.empty?
              puts 'sending a message: ' + (msg = @queue.pop).to_s
              exchange.publish(msg)
            end
          end

          # sending a message to cloud controllers
          #exchange = channel.fanout(@config['amqp']['exchange_name'])
          #exchange.publish('test')

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