require 'data_mapper'
require 'dm-validations'

class Offer
  include DataMapper::Resource

  property :id,            Serial
  property :cost,         Float
  property :controller_id, String # cc id and its routing key as well
  property :received_at,   DateTime, :default => DateTime.now

  belongs_to :service_specification

end
