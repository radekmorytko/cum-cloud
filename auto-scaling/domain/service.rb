require 'rubygems'
require 'json'
require 'data_mapper'
require 'logger'

module AutoScaling
  class Service
    include DataMapper::Resource

    property :name, String, :key => true, :unique => true
    property :autoscaling_queue_name, String, :required => true

    has n, :stacks

    def to_s
      JSON.pretty_generate(self)
    end

    def deployed?
      return false if stacks.empty?
      stacks.reduce(true) { |acc, s| acc and s.state == :deployed }
    end
  end
end

