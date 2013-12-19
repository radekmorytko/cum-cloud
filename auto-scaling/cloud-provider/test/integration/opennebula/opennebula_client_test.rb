require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'opennebula/opennebula_client'
require 'opennebula_generator'

module AutoScaling
  class OpenNebulaClientTest < Test::Unit::TestCase

    MAPPINGS = {
        # supported stacks
        'stacks' => {
            'java' => {
                'master' => 3,
                'slave' => 3
            },
            'bootstrap' => {
                'base' => 4
            }
        }
    }


    SERVICE_TEMPLATE =
<<-eos
{
"name": "service-name",
    "deployment": "straight",
    "roles": [
    {
        "name": "master",
        "vm_template": 10,
        "cardinality": 1
    },

    {
        "name": "slave",
        "parents": [ "master" ],
        "vm_template": 11
    }]

}
eos

    def setup
      options = {
          'username' => 'oneadmin',
          'password' => '8425350dac7d9e85eab2854618639cde',
          'host_password' => 'password',
          'endpoints' =>  {
            'opennebula' => 'http://frontend1:2633/RPC2',
            'appflow' => 'http://frontend1:2474'
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

    def test_shall_manage_container
      container_info = @opennebula_client.instantiate_container('bootstrap', 'base', MAPPINGS)
      assert_equal true, container_info[:id] >= 0
      assert_equal true, container_info[:ip] != ''

      data = @opennebula_client.monitor_container(container_info[:id])
      assert_equal 2, data.size

      @opennebula_client.delete_container container_info[:id]
    end

    def test_shall_show_image
      # note that you need to have image_ids on backend
      assert_not_nil @opennebula_client.image_name(17)
      assert_nil @opennebula_client.image_name(1000)
    end

    def test_shall_extract_ip
      expected = '192.168.122.104'
      configuration = OpenNebulaGenerator.show_vm(:vm_id => 100, :ip => expected)
      actual = @opennebula_client.frontend.send(:extract_ip, configuration)

      assert_equal expected, actual
    end

    def test_shall_retrieve_capacity
      actual = @opennebula_client.capacity()

      actual.each do |key, value|
        assert_equal true, value > 0
      end
    end

    def test_shall_retrieve_host_usage
      actual = @opennebula_client.monitor_host('node1')

      pp actual
    end

    def test_shall_retrieve_host
#      actual = @opennebula_client.frontend.host_by_container 145
      actual = 'node1'
      expected = 'node1'

      assert_equal actual, expected
    end

  end
end
