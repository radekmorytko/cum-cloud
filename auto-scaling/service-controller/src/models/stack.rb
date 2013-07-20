require 'rubygems'
require 'data_mapper'

module AutoScaling
  class Stack
    include DataMapper::Resource

    property :id, Serial
    belongs_to :service

    property :type, String
    # add name when handling a multiple stacks scenario (identifies deployed app)
    #property :name, String
    property :data, String

    has 1, :master, 'Container'
    has n, :slaves, 'Container'

    # TODO who should have information about where stack is deployed (ex. opennebula endpoint?)
    # -> probably cloud controller who scales to different cloud
  end
end
