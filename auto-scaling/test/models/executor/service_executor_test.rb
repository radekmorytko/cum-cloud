require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'executor/service_executor'

module AutoScaling

  class ServiceExecutorTest < Test::Unit::TestCase

    def setup
      @appflow_client = mock()

      @planner = ServiceExecutor.new @appflow_client
    end

    def teardown
    end

    # Fake test
    def test_deploy_service
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

            "vm_template": 2,
            "appstage_id": 20,
            "cardinality": 2
        }
    ]
}
      eos

      service = {
          :stack => :java,
          :instances => 2,
          :name => 'service-name'
      }


      template_id = 100
      @appflow_client.expects(:create_service_template).with(service_template).returns(template_id)
      @appflow_client.expects(:instantiate_service).with(template_id)

      @planner.deploy_service service
    end
  end

end