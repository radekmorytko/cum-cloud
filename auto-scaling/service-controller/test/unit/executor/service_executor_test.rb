require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'executor/service_executor'

module AutoScaling

  class ServiceExecutorTest < Test::Unit::TestCase

    def setup
      @cloud_provider = mock()

      Utils::setup_database

      @executor = ServiceExecutor.new @cloud_provider
    end

    def teardown

    end

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
          :onetemplate_id => 6,

          :appstage => {
              :loadbalancer => 9,
              :java => 20
          }
      }

      template_id = 100
      instance_id = 69
      @cloud_provider.expects(:render).with(service, mappings).returns(service_template)
      @cloud_provider.expects(:create_template).with(service_template).returns(template_id)
      @cloud_provider.expects(:instantiate_template).with(template_id).returns(instance_id)

      @executor.deploy_service service, mappings
    end

  end

end