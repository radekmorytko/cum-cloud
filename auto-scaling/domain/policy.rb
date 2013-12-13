require 'rubygems'
require 'json'
require 'data_mapper'

module AutoScaling
  class Policy
    include DataMapper::Resource

    property :id, Serial
    property :name, String
    belongs_to :policy_set, :required => false

    property :arguments, Object

    def to_s
      JSON.pretty_generate(self)
    end

  end
end
