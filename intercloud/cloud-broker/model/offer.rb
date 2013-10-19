module Intercloud
  class Offer
    include DataMapper::Resource

    property :id, Serial

    property :controller_id, String # and its routing key as well
    property :received_at,   DateTime, :default => DateTime.now

    property :memory, Integer
    property :price,    Integer
    belongs_to :service_specification
  end
end