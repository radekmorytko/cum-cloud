require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'utils'
require 'monitor/service_monitor'

module AutoScaling

  class ServiceMonitorTest < Test::Unit::TestCase

    def setup
      @cloud_provider = mock()
      Utils::setup_database

      @monitor = ServiceMonitor.new @cloud_provider


    end

    def test_shall_return_data_from_last_timestamp
      set_1 = [["1374678040", "524288"], ["1374678083", "524288"], ["1374678113", "524288"], ["1374678155", "524288"]]
      set_2 = [["1374678040", "524288"], ["1374678083", "524288"], ["1374678113", "524288"], ["1374678155", "524288"], ["1374678198", "524288"], ["1374678241", "524288"], ["1374678284", "524288"], ["1374678327", "524288"], ["1374678370", "524288"], ["1374678413", "524288"]]

      container = Container.create(
          :id => 100,
          :ip => '192.168.122.1'
      )

      assert_equal set_1, @monitor.send(:last, set_1, container )
      assert_equal set_2 - set_1, @monitor.send(:last, set_2, container )
    end

    def test_shall_grab_data_about_all_containers
      instance_id = 69

      containers = [
        Container.create(
            :id => 10,
            :ip => '192.168.122.1'
        ),
        Container.create(
            :id => 11,
            :ip => '192.168.122.2'
        ),
        Container.create(
            :id => 12,
            :ip => '192.168.122.200',
            :type => :master
        )
      ]

      stack = Stack.create(
          :type => 'java',
          :containers => containers
      )

      service = Service.create(
          :id => instance_id,
          :name => 'service-name',
          :stacks => [stack],
          :status => :converged
      )

      data = { "CPU" => [["1", "100"], ["5", "105"]] }
      containers.each {|c| @cloud_provider.expects(:monitor_container).with(c.id).returns(data)}
      actual = @monitor.monitor service.id

      expected = {10 => data, 11 => data, 12 => data}
      assert_equal expected, actual

      data = { "CPU" => [["1", "100"], ["5", "105"], ["10", "200"]] }
      inc = { "CPU" =>  [["10", "200"]]}
      containers.each {|c| @cloud_provider.expects(:monitor_container).with(c.id).returns(data)}
      actual = @monitor.monitor service.id
      expected = {10 => inc, 11 => inc, 12 => inc}

      assert_equal expected, actual
    end

  end

end
