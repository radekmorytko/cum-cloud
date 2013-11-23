require 'rubygems'
require 'json'
require 'data_mapper'

module AutoScaling
  class Service
    include DataMapper::Resource

    property :id, Serial

    property :name, String, :required => true
    property :status, Enum[ :new, :converged ], :default => :new

    has n, :stacks

    def to_s
      JSON.pretty_generate(self)
    end

  end
end
