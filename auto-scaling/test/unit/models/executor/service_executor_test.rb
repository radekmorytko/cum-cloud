require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'models/executor/service_executor'

module AutoScaling

  class ServiceExecutorTest < Test::Unit::TestCase

    def setup
      @appflow_client = mock()
      @one_client = mock()

      @executor = ServiceExecutor.new @appflow_client, @one_client
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
      @appflow_client.expects(:create_template).with(service_template).returns(template_id)
      @appflow_client.expects(:instantiate_template).with(template_id).returns(instance_id)

      @executor.deploy_service service, mappings

      assert_equal instance_id, @executor.services[instance_id].service_id
    end

    def test_configuration
      instance_id = 10
      vm_ids = {:loadbalancer => 0, :worker => [1, 2, 3]}
      @appflow_client.expects(:vm_ids).with(instance_id).returns(vm_ids)

      ips = ['192.168.122.1', '192.168.122.10', '192.168.122.11', '192.168.122.12']
      [0,1,2,3].each do |id|
        @one_client.expects(:vm_ip).with(id).returns(ips[id])
      end

      @executor.ips instance_id
    end
  end

end