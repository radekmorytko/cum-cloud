require 'rubygems'
require 'json'
require "test/unit"
require 'utils'

require 'models/models'
require 'executor/chef_renderer'

module AutoScaling

  class ChefRendererTest < Test::Unit::TestCase

    def setup
      Utils::setup_database
      @chef = ChefRenderer.new
    end

    def teardown
      # Do nothing
    end

    def test_shall_configuration_for_java_stack
      expected = JSON.generate({
        :haproxy => {
          :members => [{
            "hostname" => "192.168.122.100",
            "ipaddress" => "192.168.122.100"
          }, {
            "hostname" => "192.168.122.101",
            "ipaddress" => "192.168.122.101"
          }],
        },

        :run_list => ["recipe[haproxy]"]
        }
      )

      master = Container.create(
        :id => 99,
        :ip => "192.168.122.99"
      )

      slaves = [
          Container.create(
              :id => 100,
              :ip => "192.168.122.100"
          ),
          Container.create(
              :id => 101,
              :ip => "192.168.122.101"
          )
      ]

      stack = Stack.create(
        :master => master,
        :slaves => slaves,
        :type => :java
      )

      actual = @chef.render(stack)

      assert_equal expected, actual
    end
  end

end