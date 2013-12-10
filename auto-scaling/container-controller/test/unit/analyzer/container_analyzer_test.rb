require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'set'

require 'utils'
require 'analyzer/container_analyzer'

module AutoScaling
  class ContainerAnalyzerTest < Test::Unit::TestCase

    @@mappings = {
        :threshold_model => {
            :master => {
                :greater => :overloaded_master,
                :lesser => :healthy,
                :fits => :healthy
            },

            :slave => {
                :greater => :insufficient_slaves,
                :lesser => :redundant,
                :fits => :healthy
            }
        }
    }

    def setup
      Utils::setup_database
      @evaluator = mock()
      @analyzer = ContainerAnalyzer.new @evaluator

      @container = Container.create(
          :ip => '192.168.122.1'
        )

      @policy_set = PolicySet.create()

      @stack = Stack.create(
          :type => 'java',
          :containers => [@container],
          :policy_set => @policy_set
      )

    end

    def test_shall_analyze_data
      # let say that model is represented by [min,max] =  [10,50]
      data = { :container => @container, :metrics => {"CPU" => ["50", "75", "40"], "MEMORY" => ["80", "60", "50"]} }

      policy = Policy.create( :name => 'name' )
      @policy_set.expects(:policies).returns([policy])

      @evaluator.expects(:evaluate).with(policy, @container, data[:metrics]["CPU"], @analyzer.mappings).returns(:insufficient)
      @evaluator.expects(:evaluate).with(policy, @container, data[:metrics]["MEMORY"], @analyzer.mappings).returns(:insufficient)

      conclusion = @analyzer.analyze(data)
      expected = [:insufficient_cpu, :insufficient_memory].to_set

      assert_equal expected, conclusion
    end

  end
end
