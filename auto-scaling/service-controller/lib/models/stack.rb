require 'rubygems'
require 'data_mapper'

module AutoScaling
  class Stack
    include DataMapper::Resource

    property :id, Serial
    belongs_to :service

    property :type, Enum[ :invalid, :java ], :default => :invalid
    # add name when handling a multiple stacks scenario (identifies deployed app)
    #property :name, String
    property :data, String

    has n, :containers

    def to_s
      {
        :id => @id,
        :type => @type,
        :containers => @containers
      }.to_s
    end

    # TODO who should have information about where stack is deployed (ex. opennebula endpoint?)
    # -> probably cloud controller who scales to different cloud
  end
end
