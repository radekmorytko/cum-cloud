require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'fakeweb'

require 'opennebula/appflow_client'
require 'opennebula_generator'

module AutoScaling
  class OpenNebulaClientTest < Test::Unit::TestCase

    OPTIONS = {
        'username' => 'oneadmin',
        'password' => 'password',
        'endpoints' => {'appflow' => 'http://example.com'}
    }

    def setup
      @appflow_client = AppflowClient.new OPTIONS
    end

    def url(service_id)
      "http://#{OPTIONS['username']}:#{OPTIONS['password']}@example.com/service/#{service_id}"
    end

    def test_shall_return_configuration_when_service_is_running
      service_id = 120
      response = OpenNebulaGenerator.show_service(ShowService.new(service_id, 2))
      FakeWeb.register_uri(:get, url(service_id), [{:body => response, :times => 2}, {:body => response}])

      expected = {
          "slave"=>[{:ip=>"192.168.122.101", :id=>"139"}],
          "master"=>[{:ip=>"192.168.122.100", :id=>"138"}]
      }
      actual = @appflow_client.configuration service_id

      assert_equal expected, actual
    end


    def test_shall_throw_exception_when_service_is_pending
      service_id = 120
      response = OpenNebulaGenerator.show_service(ShowService.new(service_id, 1))
      FakeWeb.register_uri(:get, url(service_id), {:body => response, :times => 4})

      assert_raises RuntimeError do
        @appflow_client.configuration service_id
      end

    end

  end
end
