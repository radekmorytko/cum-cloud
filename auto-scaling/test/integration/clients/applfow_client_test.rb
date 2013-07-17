require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'fakeweb'

require 'rest-client'

require 'appflow_client'

module AutoScaling
  class AppflowClientTest < Test::Unit::TestCase
    def setup
      options = {
          :username => 'oneadmin',
          :password => 'password',
          :server => 'http://one:2474'
      }

      @appflow_client = AppflowClient.new options
    end

    def teardown
    end

    def test_create_template

      service_template =
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

      template_id = @appflow_client.create_template(service_template)
      # in fact test will pass as long there will be no exceptions and create_template will return just some unsigned int
      assert_equal true, template_id >= 0

      @appflow_client.delete_template template_id
    end

  end
end
