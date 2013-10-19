module Intercloud
  class ServiceSpecification
    include DataMapper::Resource

    property :id, Serial

    property :stack, String
    property :instances, Integer
    property :name, String
    property :client_endpoint, String

    has n, :offers

  end
end