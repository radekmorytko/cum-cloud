require 'rubygems'
require 'data_mapper'
require "test/unit"

require 'utils'
require 'models/models'

module AutoScaling
  class ServiceTest < Test::Unit::TestCase

    def setup
      Utils::setup_database
    end

    def test_persistence_model
      DataMapper.finalize

      DataMapper.finalize
      @slaves = [
        Container.create(
          :id => 10,
          :ip => '192.168.122.1'
        ),
        Container.new(
            :id => 11,
            :ip => '192.168.122.2'
        )
      ]

      @master = Container.new(
          :id => 0,
          :ip => '192.168.122.200'
      )

      @stack = Stack.create(
        :type => :java,
        :data => 'http://jenkins.com/path/to/my/app.war',
        :slaves => @slaves,
        :master => @master
      )

      @service = ::AutoScaling::Service.create(
        :id => 110,
        :name => 'enterprise-app',
        :stacks => [@stack]
      )

    end
  end
end
