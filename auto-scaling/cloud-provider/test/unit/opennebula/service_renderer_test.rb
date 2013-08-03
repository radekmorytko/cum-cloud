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
    "deployment": "straight",
    "roles": [
        {
            "name": "master",
            "vm_template": 6,
            "appstage_id": 9,
            "cardinality": 1
        },
        {
            "name": "slave",
            "parents": ["master"],
            "vm_template": 6,
            "appstage_id": 20,
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
        'onetemplate_id' => 6,

        # supported stacks
        'appstage' => {
          'java' => {
            'master' => 9,
            'slave' => 20
          }
        }
      }

      # test it from client side - ie. using opennebula
      actual = OpenNebulaClient.new({}).render(service, mappings)
      assert_equal expected.strip!, actual.strip!
    end
  end
end
