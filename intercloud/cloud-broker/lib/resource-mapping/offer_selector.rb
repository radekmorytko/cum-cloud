require 'common/configurable'
require 'resource-mapping/strategies/flat_strategy'
require 'logger'

class OfferSelector
  include Configurable

  @@logger       = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG
  
  # select appropriate offers from a given service spec
  def select(offers)
    @strategy.select(offers)
  end

  def initialize
    class_name = prepare_offers_match_classname(config['resource_mapping']['strategy'])
    @strategy  = Object.const_get(class_name).new
    @@logger.debug('Initialized offers matcher with ' << class_name)
  end

  private
  def prepare_offers_match_classname(offers_matching_strategy)
    offers_matching_strategy.capitalize + 'Strategy'
  end
end
