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
          'username' => 'oneadmin',
          'password' => 'password',
          'endpoints' =>  {
            'opennebula' => 'http://one:2633/RPC2',
            'appflow' => 'http://one:2474'
          },
          'monitoring_keys' => ['CPU', 'MEMORY']
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

    ensure
      # cleanup
      @opennebula_client.appflow.delete_instance instance_id if instance_id
      @opennebula_client.appflow.delete_template template_id if template_id
    end

    def test_shall_instantiate_container
      mappings = {
          'onetemplate_id' => 7,

          # supported stacks
          'appstage' => {
              'java' => {
                  'master' => 39,
                  'slave' => 25
              }
          }
      }

      service_id = 1

      container_info = @opennebula_client.instantiate_container('java', service_id, mappings)
      assert_equal true, container_info[:id] >= 0
      assert_equal true, container_info[:ip] != ''

      data = @opennebula_client.monitor_container(container_info[:id])
      assert_equal 2, data.size

      @opennebula_client.delete_container container_info[:id]
    end

  end
end
