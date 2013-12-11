require 'rubygems'
require 'test/unit'
require 'data_mapper'
require 'mocha/setup'
require 'fakeweb'

require 'utils'
require 'executor/stack_executor'

module AutoScaling

  class StackExecutorTest < Test::Unit::TestCase

    MAPPINGS = {
      'onetemplate_id' => 7,

      # supported stacks
      'appstage' => {
        'java' => {
            'master' => 39,
            'slave' => 25
        }
      }
    }

    def setup
      @cloud_provider = mock()
      Utils::setup_database

      @executor = StackExecutor.new(@cloud_provider, MAPPINGS)
    end

    def test_shall_successfully_deploy_stack
      stack_template =
<<-eos
{
    "name": "stack-name",
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

      stack = {
          'type' => 'java',
          'instances' => 2,
          'name' => 'stack-name',
          'policy_set' => {
              'min_vms' => 0,
              'max_vms' => 2,
              'policies' => [{'name' => 'threshold_model', 'parameters' => {'min' => '5', 'max' => '50'} }]
          }
      }

      template_id = 100
      instance_id = 69
      configuration = {
         "master" => [{:ip=>"192.168.122.100", :id=>"138"}],
         "slave" => [{:ip=>"192.168.122.101", :id=>"139"}]
      }

      @cloud_provider.expects(:render).with(stack, MAPPINGS).returns(stack_template)
      @cloud_provider.expects(:create_template).with(stack_template).returns(template_id)
      @cloud_provider.expects(:instantiate_template).with(template_id).returns(instance_id)
      @cloud_provider.expects(:configuration).with(instance_id).returns(configuration)

      @executor.deploy_stack stack
    end

    def test_shall_update_model
      instance_id = 69
      conf = {
         'master' => [{:ip=>"192.168.122.100", :id=>"138"}],
         'slave' => [{:ip=>"192.168.122.101", :id=>"139"}, {:ip=>"192.168.122.102", :id=>"140"}]
      }

      stack = Stack.create(:type => 'java', :correlation_id => instance_id)

      @cloud_provider.expects(:configuration).with(instance_id).returns(conf)
      @executor.send(:update, stack)

      assert_equal Stack.correlated(instance_id).state, :deployed
      assert_equal Container.correlated(138).ip, "192.168.122.100"
      assert_equal Container.correlated(139).ip, "192.168.122.101"
      assert_equal Container.correlated(140).ip, "192.168.122.102"
    end

    def test_shall_converge_and_update_master
      instance_id = 69

      containers = [
          Container.create(
              :correlation_id => 10,
              :ip => '192.168.122.1'
          ),
          Container.create(
              :correlation_id => 11,
              :ip => '192.168.122.2'
          ),
          Container.create(
              :correlation_id => 0,
              :ip => '192.168.122.200',
              :type => :master
          )
      ]

      stack = Stack.create(
        :type => 'java',
        :containers => containers,
        :correlation_id => instance_id
      )

      FakeWeb.register_uri(:post,
                           "http://192.168.122.200:4567/chef",
                           :status => ["200", "OK"])

      @executor.converge(Container.master(stack).id)
    end

    def test_shall_deploy_new_container
      instance_id = 69
      master_ip = '192.168.122.200'

      containers = [
          Container.create(
              :correlation_id => 10,
              :ip => '192.168.122.1'
          ),
          Container.create(
              :correlation_id => 0,
              :ip => master_ip,
              :type => :master
          )
      ]

      stack = Stack.create(
          :type => 'java',
          :containers => containers,
          :correlation_id => instance_id
      )

      container_id = 800
      container_ip = '192.168.122.69'
      response = 'Od przedszkola do Opola, kupuj szybko dzis bejzbola'
      @cloud_provider.expects(:instantiate_container).with('java', 'slave', MAPPINGS).returns({:id => container_id, :ip=> container_ip})
      FakeWeb.register_uri(:post,
                           "http://#{master_ip}:4567/chef",
                           :body => response,
                           :status => ["200", "OK"])

      id = @executor.deploy_container stack
      assert_equal 2, Container.slaves(stack).size

      slaves = Container.slaves(stack)
      container = Container.first(:correlation_id => container_id)

      assert slaves.include?(container)
    end

    def test_shall_delete_container
      master_ip = '192.168.122.200'
      correlation_id = 69

      containers = [
          Container.create(
              :correlation_id => 10,
              :ip => '192.168.122.1'
          ),
          Container.create(
              :correlation_id => 0,
              :ip => master_ip,
              :type => :master
          )
      ]

      stack = Stack.create(
          :type => 'java',
          :containers => containers,
          :correlation_id => correlation_id
      )

      response = 'Hulaj dusza, baki ida'
      FakeWeb.register_uri(:post,
                           "http://#{master_ip}:4567/chef",
                           :body => response,
                           :status => ["200", "OK"])
      @cloud_provider.expects(:delete_container).with(10)

      @executor.delete_container(Stack.get(stack.id))
      assert_equal 0, Container.slaves(stack).size
    end

    def test_shall_throw_exception_when_there_is_no_slaves_left
      stack = Stack.create(
          :type => 'java',
          :containers => []
      )

      assert_raise RuntimeError do
        @executor.delete_container(Stack.get(stack.id))
      end
    end

  end

end