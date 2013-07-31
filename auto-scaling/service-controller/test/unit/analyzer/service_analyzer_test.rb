require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'set'

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
            :ip => '192.168.122.3'
        ),
        Container.create(
          :id => 13,
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

    def test_shall_analyze_data
      # let say that model is represented by [min,max] =  [10,50]
      data = {
        @stack => {
          @containers[0] => {
            "CPU" => ["50", "75", "20"],
#            "MEMORY" => ["70", "7345", "3213"],
          },
          @containers[1] => {
              "CPU" => ["50", "95", "99"],
#              "MEMORY" => ["70", "7345", "5431"],
          },
          @containers[2] => {
              "CPU" => ["20", "30", "40"],
              #              "MEMORY" => ["70", "345", "41"],
          },
          @containers[3] => {
              "CPU" => ["70", "95", "10"],
              #              "MEMORY" => ["70", "345", "41"],
          }
        }
      }

      responses = {@containers[0] => :greater, @containers[1] => :greater, @containers[2] => :fits, @containers[3] => :greater}
      data[@stack].each {|container, metrics| @model.expects(:analyze).with(data[@stack][container]["CPU"]).returns(responses[container])}

      conclusion = @analyzer.analyze(data)
      expected = { @stack => [:insufficient_slaves, :overloaded_master].to_set }

      assert_equal expected, conclusion
    end

  end
end
