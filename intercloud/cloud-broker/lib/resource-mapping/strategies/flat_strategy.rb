
class FlatStrategy
  
  # select the minimal offer per stack
  def select(offers)
    offers.min_by { |o1| o1.cost }
  end
end
