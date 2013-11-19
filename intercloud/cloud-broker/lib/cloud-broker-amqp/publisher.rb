
class Publisher
  attr_writer :exchange

  def publish(message, options = {})
    @exchange.publish(message, options)
  end
end
