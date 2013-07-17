require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'fakeweb'

require 'appflow_client'

module AutoScaling
  class AppflowClientTest < Test::Unit::TestCase

    SERVICE_TEMPLATE =
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

            "vm_template": 6,
            "appstage_id": 20,
            "cardinality": 2
        }
    ]
}
eos

    def setup
      options = {
          :username => 'oneadmin',
          :password => 'password',
          :server => 'http://one:2474'
      }

      @appflow_client = AppflowClient.new options
    end

    def test_create_template
      template_id = @appflow_client.create_template(SERVICE_TEMPLATE)
      # in fact test will pass as long there will be no exceptions and create_template will return just some unsigned int
      assert_equal true, template_id >= 0

      @appflow_client.delete_template template_id
    end

    def test_instantiate_template
      template_id = @appflow_client.create_template(SERVICE_TEMPLATE)
      instance_id = @appflow_client.instantiate_template(template_id)

      # cleanup
      @appflow_client.delete_instance instance_id
      @appflow_client.delete_template template_id
    end

  end
end
