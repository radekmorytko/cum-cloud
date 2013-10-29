module Intercloud
  class OffersMatcher
    attr_reader :strategy

    def initialize(strategy)
      @strategy = strategy
    end

    def match(service_specification, offers)
      @strategy.match(service_specification, offers)
    end

    def strategy=(new_strategy)
      raise 'Not a matcher' unless new_strategy.respond_to? :match
      @strategy = new_strategy
    end

  end
end
