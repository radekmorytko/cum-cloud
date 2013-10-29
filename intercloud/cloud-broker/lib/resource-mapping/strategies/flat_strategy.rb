module Intercloud
  class FlatStrategy
    def match(service_specification, offers)
      p 'Flat strategy .. I am matching'
      offers.choice
    end
  end
end