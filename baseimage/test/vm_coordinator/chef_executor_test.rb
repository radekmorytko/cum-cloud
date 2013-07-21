require 'rubygems'
require 'base64'
require "test/unit"
require 'mocha/setup'

require 'models/chef_executor'

class ChefExecutorTest < Test::Unit::TestCase
  TMP_DIR = 'tmp'
  CHEF_EXECUTABLE = '/that/path/doesnt/exists'

  def setup
    @chef = ChefExecutor.new('chef.conf', CHEF_EXECUTABLE)
    FileUtils.mkdir_p TMP_DIR
  end

  def teardown
    FileUtils.remove_dir TMP_DIR, :true
    FileUtils.remove "#{VM_COORDINATOR_LOG}/chef_executor.log", :force => :true
  end

  def test_if_chef_runs
    node_data = Base64::encode64('{"name":"tomcat-worker","run_list":["recipe[tomcat]"]}')
    node_object = {
      :file => "#{TMP_DIR}/node.json",
      :data => node_data
    }
    command_str = "#{CHEF_EXECUTABLE} -c chef.conf -j #{node_object[:file]} >> #{VM_COORDINATOR_LOG}/chef_executor.log 2>&1"

    executor = mock()
    executor.expects(:execute).with(command_str).returns([10, 0])

    result = @chef.run(node_object, executor)
    assert_equal 0, result[1]
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