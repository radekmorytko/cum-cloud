require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'fakeweb'

require 'appflow_client'

module AutoScaling
  class AppflowClientTest < Test::Unit::TestCase
    URL = 'http://localhost'

    def setup
      @appflow_client = AppflowClient.new URL
    end

    def teardown
      # Do nothing
    end

    def test_create_template
      expected = "Hello World!"
      FakeWeb.register_uri(:post, "#{URL}/service_template", :body => expected)

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

      actual = @appflow_client.create_template service_template
      assert_equal actual, expected
    end

  end
end
