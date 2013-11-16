require 'rubygems'
require 'json'
require 'data_mapper'

module AutoScaling
  class Stack
    include DataMapper::Resource

    property :id, Serial
    belongs_to :service

    property :type, Enum[ :invalid, :java ], :default => :invalid
    property :state, Enum[ :invalid, :queued, :pending, :deployed ], :default => :invalid
    # add name when handling a multiple stacks scenario (identifies deployed app)
    #property :name, String
    property :data, String
    property :policy_set, Object

    has n, :containers

    def to_s
      JSON.pretty_generate(self)
    end

    # TODO who should have information about where stack is deployed (ex. opennebula endpoint?)
    # -> probably cloud controller who scales to different cloud
  end
end
