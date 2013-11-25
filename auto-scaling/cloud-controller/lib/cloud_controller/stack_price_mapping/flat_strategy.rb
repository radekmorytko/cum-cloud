require 'common/configurable'

class StackPriceMappingFlatStrategy
  include Configurable

  def price
    config['pricing_mapping']['flat']['stack']
  end

  def calculate_price(stack)
    type          = stack['type'] || stack[:type]
    instances_cnt = stack['instances'] || stack[:instances]

    raise 'Invalid stack type' unless price.has_key?(type)

    price[type] * instances_cnt
  end
end

