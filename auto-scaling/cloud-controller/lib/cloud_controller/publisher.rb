
class Publisher
  attr_writer :exchange

  def initialize(exchange = nil)
    @exchange = exchange
  end

  def publish(message, options = {})
    @exchange.publish(message, options)
  end
end

