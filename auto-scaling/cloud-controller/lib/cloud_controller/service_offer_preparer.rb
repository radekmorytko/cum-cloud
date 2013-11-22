require 'rubygems'
require 'logger'
require 'common/configurable'
require 'cloud_controller/stack_offer_preparer'

class ServiceOfferPreparer
  include Configurable

  @@logger       = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG


  def initialize(stack_offer_preparer)
    @stack_offer_preparer = stack_offer_preparer
  end

  def prepare_offer(service_specification)
    prepare_stacks_offers(service_specification['stacks'])
  end

  private
  def prepare_stacks_offers(stacks)
    stacks.map { |stack| @stack_offer_preparer.prepare_offer(stack) }.select { |offer| not offer.nil? }
  end
end
