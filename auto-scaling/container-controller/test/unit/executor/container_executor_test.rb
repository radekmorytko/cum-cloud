require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'fakeweb'

require 'utils'
require 'executor/container_executor'

module AutoScaling
  class ContainerExecutorTest < Test::Unit::TestCase


    def setup
      Utils::setup_database

      @cloud_provider = mock()
      @container = Container.create(
          :ip => '192.168.122.1',
          :correlation_id => 10
      )
      @executor = ContainerExecutor.new(@cloud_provider)
    end

    def test_shall_increase_cpu
      request = '{"cpulimit":50.0}'
      @cloud_provider.expects(:host_by_container).with(@container.correlation_id).returns('localhost')
      FakeWeb.register_uri(:post, "http://localhost:4567/container/10/configuration", :body => '{ "status" => "ok" }')
      @executor.increase_cpu(@container, 0.5)
      puts FakeWeb.last_request.body
      assert_equal FakeWeb.last_request.body, request
    end

    def test_shall_increase_memory
      request = '{"physpages":1024}'
      @cloud_provider.expects(:host_by_container).with(@container.correlation_id).returns('localhost')
      FakeWeb.register_uri(:post, "http://localhost:4567/container/10/configuration", :body => '{ "status" => "ok" }')
      @executor.increase_memory(@container, 1024)
      assert_equal FakeWeb.last_request.body, request
    end

  end
end
