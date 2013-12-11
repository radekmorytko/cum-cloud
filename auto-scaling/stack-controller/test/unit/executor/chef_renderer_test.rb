require 'rubygems'
require 'test/unit'
require 'data_mapper'
require 'mocha/setup'

require 'utils'
require 'executor/chef_renderer'

module AutoScaling

  class ChefRendererTest < Test::Unit::TestCase

    def setup
      Utils::setup_database
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

      instance_id = 69

      containers = [
          Container.create(
              :id => 10,
              :ip => '192.168.122.100'
          ),
          Container.create(
              :id => 11,
              :ip => '192.168.122.101'
          ),
          Container.create(
              :id => 0,
              :ip => '192.168.122.200',
              :type => :master
          )
      ]

      stack = Stack.create(
          :type => 'java',
          :containers => containers
      )

      actual = ChefRenderer.render(stack)

      assert_equal expected, actual
    end
  end

end