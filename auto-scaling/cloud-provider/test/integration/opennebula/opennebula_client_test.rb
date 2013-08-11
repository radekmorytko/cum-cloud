require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'opennebula/opennebula_client'

module AutoScaling
  class OpenNebulaClientTest < Test::Unit::TestCase

    MAPPINGS = {
        # supported stacks
        'stacks' => {
            'java' => {
                'master' => 10,
                'slave' => 11
            },
            'bootstrap' => {
                'base' => 7
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

    def test_shall_manage_container
      container_info = @opennebula_client.instantiate_container('bootstrap', 'base', 'bootstrap', MAPPINGS)
      assert_equal true, container_info[:id] >= 0
      assert_equal true, container_info[:ip] != ''

      data = @opennebula_client.monitor_container(container_info[:id])
      assert_equal 2, data.size

      image_id = @opennebula_client.save_container(container_info[:id], 0, 'my_new_image')

      # sleep so the vm will be scheduler and we can shutdown it to perform vm save
      sleep 30
      @opennebula_client.shutdown_container(container_info[:id])

      @opennebula_client.delete_container container_info[:id]
      @opennebula_client.delete_image(image_id)
    end

    def test_shall_show_image
      # note that you need to have image_ids on backend
      assert_not_nil @opennebula_client.image_name(0)
      assert_nil @opennebula_client.image_name(1000)
    end

    def test_shall_create_stack
      definition = <<-eos
{
  "name": "tomcat-stack",
  "run_list": [
    "recipe[tomcat]"
  ]
}
      eos

      id = @opennebula_client.create_stack(definition)
      @opennebula_client.appstage.send(:delete_template, id)
    end

  end
end
