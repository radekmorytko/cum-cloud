require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'opennebula/opennebula_frontend'

module AutoScaling

  class OpenNebulaFrontendTest < Test::Unit::TestCase

    OPTIONS = {
        'username' => 'oneadmin',
        'password' => 'password',
        'endpoint' => 'http://one:2633/RPC2',
        'monitoring_keys' => ['CPU', 'MEMORY']
    }

    def setup
      @client = OpenNebulaFrontend.new OPTIONS
    end

    def test_shall_return_monitoring_data
      vm_id = 190
      data = @client.monitor vm_id
      assert_equal 2, data.size
    end
  end

end
