require 'rubygems'
require 'data_mapper'

module AutoScaling
  class Service
    include DataMapper::Resource

    # id should correspond to internal service representation (ie. appflow)
    property :id, Integer, :key => true

    property :name, String

    has n, :stacks
  end
end
