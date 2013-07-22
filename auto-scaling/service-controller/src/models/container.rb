require 'rubygems'
require 'data_mapper'

module AutoScaling
  class Container
    include DataMapper::Resource

    # id should correspond to internal container representation (ie. opennebula vm id)
    property :id, Integer, :key => true
    belongs_to :stack

    property :ip, IPAddress
    property :type, Enum[ :master, :slave ], :default => :slave, :required => true

    def self.master(stack)
      (all(:stack => stack) & all(:type => :master))[0]
    end

    def self.slaves(stack)
      all(:stack => stack) & all(:type => :slave)
    end
  end
end
