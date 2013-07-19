require "test/unit"
require 'models/service'

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
            "name": "loadbalancer",
            "vm_template": 6,
            "appstage_id": 9,
            "cardinality": 1
        },
        {
            "name": "java-worker",
            "parents": ["loadbalancer"],

            "vm_template": 2,
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

      bindings = {
          :loadbalancer_template_id => 6,
          :loadbalancer_appstage_id => 9,
          :worker_template_id => 2,
          :worker_appstage_id => 20
      }

      actual = Service::instantiate service, bindings
      assert_equal expected.strip!, actual.strip!
    end
  end
end
