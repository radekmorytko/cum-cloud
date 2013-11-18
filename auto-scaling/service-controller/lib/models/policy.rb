require 'rubygems'
require 'json'
require 'data_mapper'

module AutoScaling
  class Policy
    include DataMapper::Resource

    property :id, Integer, :key => true
    property :name, String

    property :arguments, Object

    def to_s
      JSON.pretty_generate(self)
    end

  end
end
