require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'utils'
require 'analyzer/service_analyzer'

module AutoScaling
  class ServiceAnalyzerTest < Test::Unit::TestCase

    def setup
      Utils::setup_database
      @analyzer = ServiceAnalyzer.new

      instance_id = 69

      @containers = [
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

      @stack = Stack.create(
          :type => 'java',
          :containers => @containers
      )

      @service = Service.create(
          :id => instance_id,
          :name => 'service-name',
          :stacks => [@stack],
          :status => :converged
      )
    end

    def teardown

    end

    def test_shall_conclude_insufficient_hosts
      data = {
          10 => {"CPU" => [["1", "10"], ["2", "60"]]},
          11 => {"CPU" => [["1", "90"], ["2", "10"]]},
          12 => {"CPU" => [["1", "40"], ["2", "20"]]}
      }

      conclusion = @analyzer.analyze(@service, data)
      expected = {10 => :insufficient_slaves, 11 => :insufficient_slaves, 12 => :healthy}

      assert_equal expected, conclusion
    end

    def test_shall_conclude_healthy_system
      data = {
          10 => {"CPU" => [["1", "10"], ["2", "10"]]},
          11 => {"CPU" => [["1", "10"], ["2", "10"]]},
          12 => {"CPU" => [["1", "10"], ["2", "10"]]}
      }

      conclusion = @analyzer.analyze(@service, data)
      expected = {10 => :healthy, 11 => :healthy, 12 => :healthy}

      assert_equal expected, conclusion
    end

    def test_shall_conclude_overloaded_master
      data = {
          10 => {"CPU" => [["1", "10"], ["2", "10"]]},
          11 => {"CPU" => [["1", "10"], ["2", "10"]]},
          12 => {"CPU" => [["1", "60"], ["2", "10"]]}
      }

      conclusion = @analyzer.analyze(@service, data)
      expected = {10 => :healthy, 11 => :healthy, 12 => :overloaded_master}

      assert_equal expected, conclusion
    end
  end
end