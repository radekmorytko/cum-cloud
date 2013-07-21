require 'rubygems'
require 'data_mapper'

module AutoScaling
  class Container
    include DataMapper::Resource

    # id should correspond to internal container representation (ie. opennebula vm id)
    property :id, Integer, :key => true
    belongs_to :stack

    property :ip, IPAddress, :required => true

    def master?
      stack.master == self
    end
  end
end
