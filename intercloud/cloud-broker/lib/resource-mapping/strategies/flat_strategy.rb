
class FlatStrategy
  def match(service_specification, offers)
    offers.min { |o1, o2| o1.cost <=> o2.cost }
  end
end
