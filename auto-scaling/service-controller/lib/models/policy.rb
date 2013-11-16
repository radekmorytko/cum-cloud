require 'rubygems'
require 'json'
require 'data_mapper'

module AutoScaling
  class Policy
    include DataMapper::Resource

    property :id, Integer, :key => true
    belongs_to :policy_set

    property :name, String, :required => true
    property :parameters, Object

    def to_s
      JSON.pretty_generate(self)
    end

  end
end
