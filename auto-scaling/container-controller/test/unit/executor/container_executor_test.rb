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

      @container = Container.create(
          :ip => '192.168.122.1'
      )
      @executor = ContainerExecutor.new()
    end

    def test_shall_increase_cpu
      request = '{ "chef" => "CPU" }'
      FakeWeb.register_uri(:post, "http://#{@container.ip}:4567/chef", :body => '{ "status" => "ok" }')
      @executor.increase_cpu(@container)
      assert_equal true, FakeWeb.last_request.body == request
    end

    def test_shall_increase_memory
      request = '{ "chef" => "MEMORY" }'
      FakeWeb.register_uri(:post, "http://#{@container.ip}:4567/chef", :body => '{ "status" => "ok" }')
      @executor.increase_memory(@container)
      assert_equal true, FakeWeb.last_request.body == request
    end

  end
end
