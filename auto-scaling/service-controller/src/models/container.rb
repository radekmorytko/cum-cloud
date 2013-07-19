require 'rubygems'
require 'data_mapper'

module Service
  class Container
    include DataMapper::Resource

    # id should correspond to internal container representation (ie. opennebula vm id)
    property :id, String
    belongs_to :stack

    property :ip, String
  end
end
