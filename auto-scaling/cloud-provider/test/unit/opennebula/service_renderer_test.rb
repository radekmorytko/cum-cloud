require 'rubygems'
require 'test/unit'

require 'opennebula/opennebula_client'

module AutoScaling
  class ServiceTest < Test::Unit::TestCase

    def test_instantiate
      expected =
<<-eos
{
    "name": "stack-name",
    "roles": [
        {
            "name": "master",
            "vm_template": 9,
            "cardinality": 1
        },
        {
            "name": "slave",
            "parents": ["master"],
            "vm_template": 20,
            "cardinality": 2
        }
    ]
}
eos

      stack = {
        'type' => 'java',
        'instances' => 2,
        'name' => 'stack-name',
        'policy_set' => {
            'min_vms' => 0,
            'max_vms' => 2,
            'policies' => [{'name' => 'threshold_model', 'parameters' => {'min' => '5', 'max' => '50'} }]
        }
      }

      mappings = {
        # supported stacks
        'stacks' => {
          'java' => {
            'master' => 9,
            'slave' => 20
          },
        }
      }

      options = {
          'username' => 'oneadmin',
          'password' => 'password',
          'endpoints' => {'appflow' => 'http://example.com'}
      }

      # test it from client side - ie. using opennebula
      actual = OpenNebulaClient.new(options).render(stack, mappings)
      assert_equal expected.strip!, actual.strip!
    end
  end
end
