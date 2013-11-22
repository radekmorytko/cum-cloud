require 'common/configurable'
## TODO remove this once the offer mechanism is done
require 'securerandom'

class StackPriceMappingFlatStrategy
  include Configurable

  def price
    config['pricing_mapping']['flat']['stack']
  end

  def calculate_price(stack)
    raise 'Invalid stack type' unless price.has_key?(stack['type'])
    price[stack['type']] * stack['instances']
  end
end

