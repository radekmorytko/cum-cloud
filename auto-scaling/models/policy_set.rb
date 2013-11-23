require 'rubygems'
require 'json'
require 'data_mapper'

module AutoScaling
  class PolicySet
    include DataMapper::Resource

    property :id, Integer, :key => true
    belongs_to :stack

    property :max_vms, Integer, :required => true
    property :min_vms, Integer, :required => true
    has n, :policies

    def to_s
      JSON.pretty_generate(self)
    end

  end
end
