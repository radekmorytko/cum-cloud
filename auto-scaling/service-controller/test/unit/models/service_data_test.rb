require 'rubygems'
require 'data_mapper'
require "test/unit"

require 'models/models'

module AutoScaling
  class ServiceTest < Test::Unit::TestCase
    URI = 'sqlite:///tmp/project.db'

    def setup
      DataMapper::Logger.new($stdout, :debug)
      DataMapper.setup(:default, URI)
    end

    def teardown
      File.delete URI if File.exists? URI
    end

    def test_persistence_model

      DataMapper.finalize
      @containers = [
        Container.create(
          :id => 10,
          :ip => '192.168.122.1'
        ),
        Container.new(
            :id => 11,
            :ip => '192.168.122.2'
        )
      ]

      @stack = Stack.create(
        :type => :java,
        :data => 'http://jenkins.com/path/to/my/app.war',
        :containers => @containers
      )

      @service = Service.create(
        :id => 110,
        :name => 'enterprise-app',
        :stacks => [@stack]
      )

      puts @containers
    end
  end
end
