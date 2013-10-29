require 'offer'
require 'service_specification'

# finalize the models
Intercloud::ServiceSpecification.finalize
Intercloud::Offer.finalize