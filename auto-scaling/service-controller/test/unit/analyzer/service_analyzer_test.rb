require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'utils'
require 'analyzer/service_analyzer'

module AutoScaling
  class ServiceAnalyzerTest < Test::Unit::TestCase

    def setup
      Utils::setup_database
      @model = mock()
      @analyzer = ServiceAnalyzer.new @model

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

    def test_shall_analyze_data
      # let say that model is represented by [min,max] =  [10,50]
      data = {
          10 => {"CPU" => [["1", "10"], ["2", "60"]]},
          11 => {"CPU" => [["1", "5"], ["2", "10"]]},
          12 => {"CPU" => [["1", "40"], ["2", "20"]]}
      }

      responses = {10 => :greater, 11 => :lesser, 12 => :fits}
      data.each {|id, probes| @model.expects(:analyze).with(data[id]["CPU"]).returns(responses[id])}

      conclusion = @analyzer.analyze(@service, data)
      expected = {10 => :insufficient_slaves, 11 => :redundant, 12 => :healthy}

      assert_equal expected, conclusion
    end

  end
end