
module Intercloud
  class Publisher
    def initialize(options = {})
      @config = options[:config]
    end

    def publish(message, options)
      AMQP.start(@config[:amqp][:host]+ ':' + @config[:amqp][:port]) do |connection, open_ok|
        channel = AMQP::Channel.new(connection)
        channel.default_exchange.publish(message, options)
        connection.close { EventMachine.stop }
      end
    end
  end
end