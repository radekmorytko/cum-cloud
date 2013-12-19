require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'utils'
require 'monitor/container_monitor'
require 'cloud-provider/cloud_provider'

module AutoScaling

  class ContainerMonitorTest < Test::Unit::TestCase

    def setup
      options = {
          'username' => 'oneadmin',
          'password' => '8425350dac7d9e85eab2854618639cde',
          'host_password' => 'password',
          'endpoints' =>  {
              'opennebula' => 'http://frontend1:2633/RPC2',
              'appflow' => 'http://frontend1:2474'
          },
          'monitoring_keys' => ['CPU', 'MEMORY']
      }

      @cloud_provider = OpenNebulaClient.new options
      Utils::setup_database

      @monitor = ContainerMonitor.new @cloud_provider

      @container = Container.create(
          :correlation_id => 450,
          :ip => '192.168.0.10'
      )
    end


    def test_shall_grab_data_container
      10.times do
        actual = @monitor.monitor @container
        sleep 30
      end

    end

  end

end
