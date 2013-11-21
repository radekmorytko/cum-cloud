require 'rubygems'
require 'json'
require 'data_mapper'

module AutoScaling
  class Container
    include DataMapper::Resource

    property :id, Serial
    property :correlation_id, Integer

    belongs_to :stack

    property :ip, IPAddress, :required => true
    property :type, Enum[ :master, :slave ], :default => :slave, :required => true
    # last time when container was probed
    property :probed, String, :default => "0"

    def self.master(stack)
      (all(:stack => stack) & all(:type => :master))[0]
    end

    def self.slaves(stack)
      all(:stack => stack) & all(:type => :slave)
    end

    def self.correlated(correlation_id)
      first(:correlation_id => correlation_id)
    end

    def master?
      type == :master
    end

    def to_s
      JSON.pretty_generate(self)
    end

  end
end
