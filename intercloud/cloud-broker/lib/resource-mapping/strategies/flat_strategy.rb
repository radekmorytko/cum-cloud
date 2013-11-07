module Intercloud
  class FlatStrategy
    def match(service_specification, offers)
      p '[FlatStrategy - I am matching]'
      offers.reject! { |o| pp o.cpu_specification; o.cpu_specification[:unit] < service_specification.cpu_unit } unless service_specification.nil?
      offers.min { |o1, o2| o1.cpu_cost <=> o2.cpu_cost }
    end
  end
end