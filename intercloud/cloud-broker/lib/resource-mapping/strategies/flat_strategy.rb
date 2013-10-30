module Intercloud
  class FlatStrategy
    def match(service_specification, offers)
      p '[FlatStrategy - I am matching]'
      offers.min { |o1, o2| o1.cpu_cost <=> o2.cpu_cost }
    end
  end
end