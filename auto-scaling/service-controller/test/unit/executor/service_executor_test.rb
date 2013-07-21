require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'fakeweb'

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

    def test_shall_successfully_deploy_service
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

    def test_shall_update_model
      instance_id = 69
      conf = {
         'master' => [{:ip=>"192.168.122.100", :id=>"138"}],
         'slave' => [{:ip=>"192.168.122.101", :id=>"139"}, {:ip=>"192.168.122.102", :id=>"140"}]
      }

      stacks = [Stack.create(:type => 'java')]

      service = Service.create(
          :id => instance_id,
          :name => 'service-name',
          :stacks => stacks
      )
      assert_equal Service.get(instance_id).status, :new

      @cloud_provider.expects(:configuration).with(instance_id).returns(conf)
      @executor.update service

      assert_equal Service.get(instance_id).status, :converged
      assert_equal Container.get(138).ip, "192.168.122.100"
      assert_equal Container.get(139).ip, "192.168.122.101"
      assert_equal Container.get(140).ip, "192.168.122.102"
    end

    def test_shall_converge_and_update_master
      instance_id = 69

      slaves = [
          Container.create(
              :id => 10,
              :ip => '192.168.122.1'
          ),
          Container.new(
              :id => 11,
              :ip => '192.168.122.2'
          )
      ]

      master = Container.new(
          :id => 0,
          :ip => '192.168.122.200'
      )

      stacks = [
          Stack.create(
              :type => 'java',
              :master => master,
              :slaves => slaves
          )
      ]

      service = Service.create(
          :id => instance_id,
          :name => 'service-name',
          :stacks => stacks,
          :status => :converged
      )

      response = "Miod, smietana, pij browara do rana"
      FakeWeb.register_uri(:post,
                           "http://192.168.122.200:4567/chef",
                           :body => response,
                           :status => ["200", "OK"])

      actual = @executor.converge(service, master)
      assert_equal response, actual
    end

  end

end