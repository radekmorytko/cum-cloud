require 'rubygems'
require 'data_mapper'

module Service
  class ServiceData
    include DataMapper::Resource

    # id should correspond to internal service representation (ie. appflow)
    property :id, String, :key => true

    property :name, String

    has n, :stacks
  end
end
