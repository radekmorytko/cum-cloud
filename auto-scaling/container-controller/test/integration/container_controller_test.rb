require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'rack/test'
require 'json'
require 'fakeweb'
require 'uri'
require 'rest-client'

require 'utils'
require 'container_controller'

module AutoScaling
  class ContainerControllerTest < Test::Unit::TestCase

    def setup
      Utils::setup_database

      @cloud_provider = mock()
      @reservation_manager = mock()

      @controller = ContainerController.build(@cloud_provider, @reservation_manager)
    end


    def test_shall_perform_a_full_lifecycle
      id = 100
      container = Container.create(
          :ip => '192.168.122.1',
          :correlation_id => id
      )
      policy_set = PolicySet.create(
          :min_vms => 1,
          :max_vms => 10,
          :policies => [
              Policy.create(
                :name => 'threshold_model',
                :arguments => {'min' => '5', 'max' => '50'}
              )
          ]
      )
      stack = Stack.create(
          :type => 'java',
          :containers => [container],
          :policy_set => policy_set
      )

      data = { "CPU" => [["1", "100"], ["5", "105"]] }
      @cloud_provider.expects(:monitor_container).with(id).returns(data)
      @reservation_manager.expects(:scale_up).with(container, :cpu)
      FakeWeb.register_uri(:post, "http://#{container.ip}:4567/chef", :body => '{ "status" => "ok" }')

      @controller.schedule(container, '1s')

      sleep 2
    end

  end
end
