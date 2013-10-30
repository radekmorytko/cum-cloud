require 'model/offer'
require 'model/service_specification'

# finalize the models
Intercloud::ServiceSpecification.finalize
Intercloud::Offer.finalize
