module Intercloud
  class ServiceSpecification
    include DataMapper::Resource

    property :id, Serial

    property :broker_id, String

    property :stack, String
    property :instances, Integer
    property :cpu_unit, Integer
    property :name, String
    property :client_endpoint, String

    property :deployed, Boolean, :default => false

    has n, :offers

  end
end