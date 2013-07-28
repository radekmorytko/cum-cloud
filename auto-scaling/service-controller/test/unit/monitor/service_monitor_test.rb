require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'fakeweb'

require 'opennebula/opennebula_frontend'

module AutoScaling

  class OpenNebulaFrontendTest < Test::Unit::TestCase

    OPTIONS = {
        :username => 'oneadmin',
        :password => 'password',
        :endpoint => 'http://host:2633/RPC2',
        :monitoring_keys => ['CPU', 'MEMORY']
    }

    def setup
      @client = OpenNebulaFrontend.new OPTIONS
    end

    def test_shall_return_data_from_last_timestamp
      set_1 = [["1374678040", "524288"], ["1374678083", "524288"], ["1374678113", "524288"], ["1374678155", "524288"]]
      set_2 = [["1374678040", "524288"], ["1374678083", "524288"], ["1374678113", "524288"], ["1374678155", "524288"], ["1374678198", "524288"], ["1374678241", "524288"], ["1374678284", "524288"], ["1374678327", "524288"], ["1374678370", "524288"], ["1374678413", "524288"]]


      assert_equal set_1, @client.send(:monitor_container, set_1)
      assert_equal set_2, @client.send(:monitor_container, set_2)
    end

  end

end
