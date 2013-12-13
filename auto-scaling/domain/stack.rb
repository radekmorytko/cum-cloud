require 'rubygems'
require 'json'
require 'data_mapper'

module AutoScaling
  class Stack
    include DataMapper::Resource

    property :id, Serial
    property :correlation_id, Integer

    has 1, :policy_set
    has n, :containers
    belongs_to :service, :required => false

    property :type, Enum[ :invalid, :java ], :default => :invalid
    property :state, Enum[ :invalid, :queued, :pending, :deployed, :converged ], :default => :invalid
    property :data, String

    def self.correlated(correlation_id)
      first(:correlation_id => correlation_id)
    end

    def to_s
      JSON.pretty_generate(self)
    end

  end
end
