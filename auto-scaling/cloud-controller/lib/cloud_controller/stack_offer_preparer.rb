## TODO remove this once the offer mechanism is done
require 'securerandom'

class StackOfferPreparer
  def prepare_offer(stack)
    # TODO implement mechanism
    { :cost => SecureRandom.random_number(100) } if deployable?(stack)
  end

  def deployable?(stack)
    # TODO implement
    true
  end
end

