require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'utils'
require 'monitor/container_monitor'

module AutoScaling

  class ContainerMonitorTest < Test::Unit::TestCase

    def setup
      @cloud_provider = mock()
      Utils::setup_database

      @monitor = ContainerMonitor.new @cloud_provider

      @container = Container.create(
          :correlation_id => 100,
          :ip => '192.168.122.1'
      )
    end

    def test_shall_return_data_from_last_timestamp
      set_1 = [["1374678040", "524288"], ["1374678083", "524288"], ["1374678113", "524288"], ["1374678155", "524288"]]
      set_2 = [["1374678040", "524288"], ["1374678083", "524288"], ["1374678113", "524288"], ["1374678155", "524288"], ["1374678198", "524288"], ["1374678241", "524288"], ["1374678284", "524288"], ["1374678327", "524288"], ["1374678370", "524288"], ["1374678413", "524288"]]


      assert_equal set_1, @monitor.send(:last, set_1, @container )
      @container.probed = "1374678155"
      @container.save

      assert_equal set_2 - set_1, @monitor.send(:last, set_2, @container )
    end

    def test_shall_grab_data_container
      data = { "CPU" => [["1", "100"], ["5", "105"]] }
      @cloud_provider.expects(:monitor_container).with(@container.correlation_id).returns(data)

      expected = { "CPU" => [], "MEMORY" => [] }

      actual = @monitor.monitor @container
      assert_equal expected, actual


      # increment
      data = { "CPU" => [["1", "100"], ["5", "105"], ["10", "200"]] }
      @cloud_provider.expects(:monitor_container).with(@container.correlation_id).returns(data)

      expected = { "CPU" => ["200"] }

      actual = @monitor.monitor @container
      assert_equal expected, actual
    end

    def test_shall_properly_collect_values
      data = {
          "CPU" => [["1", "100"], ["5", "105"], ["10", "200"]],
          "MEMORY" => [["1", "70"], ["5", "7345"], ["10", "3213"]],
      }
      expected = {
          "CPU" => ["100", "105", "200"],
          "MEMORY" => ["70", "7345", "3213"],
      }

      actual = @monitor.send(:collect_values, data)
      assert_equal expected, actual
      assert_equal expected, actual
    end

  end

end
