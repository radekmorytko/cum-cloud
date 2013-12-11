require 'rubygems'
require 'json'
require 'data_mapper'

module AutoScaling
  class Service
    include DataMapper::Resource

    property :id, Serial

    def to_s
      JSON.pretty_generate(self)
    end

  end
end
