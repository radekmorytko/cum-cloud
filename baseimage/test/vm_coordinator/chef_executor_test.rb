require 'rubygems'
require 'vm_coordinator'
require 'base64'
require "test/unit"
require 'mocha/setup'

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
    command_str = "/usr/bin/chef-solo -c chef.conf -j #{node_object[:file]} >> /var/log/chef-system-out.log 2>&1"

    executor = mock()
    executor.expects(:execute).with(command_str)

    @chef.run(node_object, executor)
  end
end