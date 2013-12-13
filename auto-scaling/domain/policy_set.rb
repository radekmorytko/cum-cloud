require 'rubygems'
require 'json'
require 'data_mapper'

module AutoScaling
  class PolicySet
    include DataMapper::Resource

    property :id, Serial
    belongs_to :stack, :required => false

    property :max_vms, Integer, :required => true
    property :min_vms, Integer, :required => true

    has n, :policies

    def to_s
      JSON.pretty_generate(self)
    end

  end
end
