require 'rubygems'
require 'logger'
require 'common/configurable'
require 'cloud_controller/stack_offer_preparer'

module AutoScaling
  class ServiceOfferPreparer
    include Configurable

    @@logger       = Logger.new(STDOUT)
    @@logger.level = Logger::DEBUG


    def initialize(stack_offer_preparer)
      @stack_offer_preparer = stack_offer_preparer end

    def prepare_offer(service_specification)
      if not Service.get(service_specification['service_name'])
        prepare_stacks_offers(service_specification['stacks'])
      else
        nil
      end
    end

    private
    def prepare_stacks_offers(stacks)
      stacks.map { |stack| @stack_offer_preparer.prepare_offer(stack) }.select { |offer| not offer.nil? }
    end
  end
end
