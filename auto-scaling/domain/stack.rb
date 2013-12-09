require 'rubygems'
require 'json'
require 'data_mapper'

module AutoScaling
  class Stack
    include DataMapper::Resource

    property :id, Serial
    property :correlation_id, Integer

    belongs_to :service

    has 1, :policy_set
    has n, :containers

    property :type, Enum[ :invalid, :java ], :default => :invalid
    property :state, Enum[ :invalid, :queued, :pending, :deployed ], :default => :invalid
    property :data, String

    def to_s
      JSON.pretty_generate(self)
    end

  end
end
