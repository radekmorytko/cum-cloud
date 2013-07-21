require 'rubygems'
require 'data_mapper'

module AutoScaling
  class Service
    include DataMapper::Resource

    # id should correspond to internal service representation (ie. appflow)
    property :id, Integer, :key => true

    property :name, String, :required => true
    property :status, Enum[ :new, :converged ], :default => :new

    has n, :stacks
  end
end
