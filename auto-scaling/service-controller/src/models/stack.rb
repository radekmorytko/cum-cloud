require 'rubygems'
require 'data_mapper'

module Service
  class Stack
    include DataMapper::Resource

    property :id, Serial
    belongs_to :service_data

    property :type, String
    property :data, String

    has n, :containers

    # TODO who should have information about where stack is deployed (ex. opennebula endpoint?)
    # -> probably cloud controller who scales to different cloud
  end
end
