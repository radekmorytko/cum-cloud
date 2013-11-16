require 'rubygems'
require 'test/unit'

require 'opennebula/opennebula_client'

module AutoScaling
  class ServiceTest < Test::Unit::TestCase

    def test_instantiate
      expected =
<<-eos
{
    "name": "service-name",
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

      service = {
          'stack' => 'java',
          'instances' => 2,
          'name' => 'service-name'
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
      actual = OpenNebulaClient.new(options).render(service, mappings)
      assert_equal expected.strip!, actual.strip!
    end
  end
end
