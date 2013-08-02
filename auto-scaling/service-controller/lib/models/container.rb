require 'rubygems'
require 'data_mapper'

module AutoScaling
  class Container
    include DataMapper::Resource

    # id should correspond to internal container representation (ie. opennebula vm id)
    property :id, Integer, :key => true
    belongs_to :stack

    property :ip, IPAddress, :required => true
    property :type, Enum[ :master, :slave ], :default => :slave, :required => true

    # monitoring
    property :probed, String, :default => "0"

    def self.master(stack)
      (all(:stack => stack) & all(:type => :master))[0]
    end

    def self.slaves(stack)
      all(:stack => stack) & all(:type => :slave)
    end

    def master?
      self == Container.master(self.stack)
    end

  end
end
