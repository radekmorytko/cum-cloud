require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'set'

require 'utils'
require 'analyzer/stack_analyzer'

module AutoScaling
  class StackAnalyzerTest < Test::Unit::TestCase

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
      @analyzer = StackAnalyzer.new @evaluator

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

      @policy_set = PolicySet.create(:min_vms => 0, :max_vms => 10)

      @stack = Stack.create(
          :type => 'java',
          :containers => @containers,
          :policy_set => @policy_set,
          :correlation_id => instance_id
      )
    end

    def test_shall_analyze_data
      # let say that model is represented by [min,max] =  [10,50]
      data = {
        @stack => {
          @containers[0] => {
            "CPU" => ["50", "75", "20"],
          },
          @containers[1] => {
              "CPU" => ["50", "95", "99"],
          },
          @containers[2] => {
              "CPU" => ["20", "30", "40"],
          },
          @containers[3] => {
              "CPU" => ["70", "95", "10"],
          }
        }
      }

      policy = Policy.create( :name => 'name' )
      @policy_set.expects(:policies).returns([policy])

      responses = {@containers[0] => :insufficient_slaves, @containers[1] => :insufficient_slaves, @containers[2] => :insufficient_slaves, @containers[3] => :overloaded_master}
      data[@stack].each do |container, metrics|
        @evaluator.expects(:evaluate).with(policy, container, data[@stack][container]["CPU"], @@mappings).returns(responses[container])
      end

      conclusion = @analyzer.analyze(data)
      expected = { @stack => [:insufficient_slaves, :overloaded_master].to_set }

      assert_equal expected, conclusion
    end

  end
end
