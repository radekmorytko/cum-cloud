require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'opennebula/opennebula_client'

module AutoScaling
  class OpenNebulaClientTest < Test::Unit::TestCase

    SERVICE_TEMPLATE =
<<-eos
{
"name": "service-name",
    "deployment": "straight",
    "roles": [
    {
        "name": "master",
        "vm_template": 7,
        "appstage_id": 39,
        "cardinality": 1
    },

    {
        "name": "slave",
        "parents": [ "master" ],
        "vm_template": 7,
        "appstage_id": 25
    }]

}
eos

    def setup
      options = {
          :username => 'oneadmin',
          :password => 'password',
          :server => '192.168.122.181:2474'
      }

      @opennebula_client = OpenNebulaClient.new options
    end

    def test_create_template
      template_id = @opennebula_client.create_template(SERVICE_TEMPLATE)
      # in fact test will pass as long there will be no exceptions and create_template will return just some unsigned int
      assert_equal true, template_id >= 0

      @opennebula_client.appflow.delete_template template_id
    end

    def test_instantiate_template
      template_id = @opennebula_client.create_template(SERVICE_TEMPLATE)
      assert_equal true, template_id >= 0
      instance_id = @opennebula_client.instantiate_template(template_id)
      assert_equal true, instance_id >= 0

      # cleanup
      @opennebula_client.appflow.delete_instance instance_id
      @opennebula_client.appflow.delete_template template_id
    end

  end
end
