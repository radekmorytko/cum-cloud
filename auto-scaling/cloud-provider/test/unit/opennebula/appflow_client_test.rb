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
      expected = {
          "slave"=>[{:ip=>"192.168.122.101", :id=>"139"}],
          "master"=>[{:ip=>"192.168.122.100", :id=>"138"}]
      }

      response = OpenNebulaGenerator.show_service(
              :service_id => service_id,
              :state => 2,
              :master_id => expected['master'][0][:id],
              :master_ip => expected['master'][0][:ip],
              :slave_id => expected['slave'][0][:id],
              :slave_ip => expected['slave'][0][:ip]
      )
      FakeWeb.register_uri(:get, url(service_id), [{:body => response, :times => 2}, {:body => response}])

      actual = @appflow_client.configuration service_id

      assert_equal expected, actual
    end


    def test_shall_throw_exception_when_service_is_pending
      service_id = 120
      expected = {
          "slave"=>[{:ip=>"192.168.122.101", :id=>"139"}],
          "master"=>[{:ip=>"192.168.122.100", :id=>"138"}]
      }
      response = OpenNebulaGenerator.show_service(
          :service_id => service_id,
          :state => 1,
          :master_id => expected['master'][0][:id],
          :master_ip => expected['master'][0][:ip],
          :slave_id => expected['slave'][0][:id],
          :slave_ip => expected['slave'][0][:ip]
      )

      FakeWeb.register_uri(:get, url(service_id), {:body => response, :times => 4})

      assert_raises RuntimeError do
        @appflow_client.configuration service_id
      end

    end

  end
end
