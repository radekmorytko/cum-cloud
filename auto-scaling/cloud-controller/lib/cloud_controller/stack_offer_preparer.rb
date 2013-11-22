require 'logger'
require 'cloud_controller/stack_price_mapping/flat_strategy'

class StackOfferPreparer
  include Configurable

  @@logger       = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def initialize
    @stack_price_mapper = initialize_stack_price_mapper
    @@logger.info("Stack-Price mapper initialized with #{@stack_price_mapper.class}")
  end

  def prepare_offer(stack)
    { :cost => @stack_price_mapper.calculate_price(stack) } if deployable?(stack)
  end

  def deployable?(stack)
    # TODO implement
    true
  end

  private
  def initialize_stack_price_mapper
    Object.const_get(stack_price_mapper_classname).new
  end

  def stack_price_mapper_classname
    'StackPriceMapping' + config['pricing_mapping']['strategy'].capitalize + 'Strategy'
  end
end

