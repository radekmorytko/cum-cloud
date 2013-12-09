require 'rubygems'
require 'data_mapper'
require "test/unit"

require 'utils'
require 'domain/domain'

module AutoScaling
  class ServiceTest < Test::Unit::TestCase

    def setup
      Utils::setup_database
    end

    def test_persistence_model
      containers = [
        Container.create(
          :id => 10,
          :ip => '192.168.122.1'
        ),
        Container.create(
            :id => 11,
            :ip => '192.168.122.2'
        ),
        Container.create(
            :id => 0,
            :ip => '192.168.122.200',
            :type => :master
        )
      ]

      policy_set = PolicySet.create(
        :min_vms => 1,
        :max_vms => 3,
        :policies => [
          Policy.create(
            :name => 'threshold_model',
            :arguments => {:min => 2, :max =>3}
          ),
          Policy.create(
              :name => 'threshold_model_non_existing',
              :arguments => {:min => 2, :max =>3, :turbo => 69}
          )
        ]
      )

      @stack = Stack.create(
        :type => :java,
        :data => 'http://jenkins.com/path/to/my/app.war',
        :containers => containers,
        :policy_set => policy_set
      )

      @service = ::AutoScaling::Service.create(
        :id => 110,
        :name => 'enterprise-app',
        :stacks => [@stack]
      )

      # test_shall_get_information_if_container_is_a_master
      container = Container.get(0)
      assert_equal Container.master(Stack.get(@stack.id)), container

      slaves = Container.slaves(Stack.get(@stack.id))
      assert_equal 2, slaves.size
    end

  end
end
