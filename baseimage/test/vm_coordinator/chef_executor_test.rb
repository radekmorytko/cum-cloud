require 'rubygems'
require 'base64'
require "test/unit"
require 'mocha/setup'

require 'models/chef_executor'
load 'config/vm_coordinator.conf'

class ChefExecutorTest < Test::Unit::TestCase
  TMP_DIR = 'tmp'

  def teardown
    FileUtils.remove_dir TMP_DIR, :true
  end

  def setup
    @chef = ChefExecutor.new(:file => 'chef.conf')
    FileUtils.mkdir_p TMP_DIR
  end

  def test_if_chef_runs
    node_data = Base64::encode64('{"name":"tomcat-worker","run_list":["recipe[tomcat]"]}')
    node_object = {
      :file => "#{TMP_DIR}/node.json",
      :data => node_data
    }
    command_str = "/usr/bin/chef-solo -c chef.conf -j #{node_object[:file]} >> #{VM_COORDINATOR_LOG}/chef-executor.log 2>&1"

    executor = mock()
    executor.expects(:execute).with(command_str)

    @chef.run(node_object, executor)
  end

  def test_run_chef_with_empty_or_nil_node_list

    assert_raise ArgumentError do
      @chef.run(nil)
    end

    assert_raise ArgumentError do
      @chef.run({})
    end

  end
end