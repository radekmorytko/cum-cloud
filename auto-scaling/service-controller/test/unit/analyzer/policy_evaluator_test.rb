require 'rubygems'
require 'test/unit'
require 'data_mapper'
require 'mocha/setup'
require 'models/models'
require 'utils'
require 'analyzer/policy_evaluator'

module AutoScaling
  class PolicyEvaluatorTest < Test::Unit::TestCase

    def setup
      Utils::setup_database
      @evaluator = PolicyEvaluator.new()
    end

    def test_shall_correctly_map_model_name
      ["threshold_model" => "ThresholdModel", "custom_name_nie_wazne" => "CustomNameNieWazne"].each do |pair|
        pair.each do |actual, expected|
          assert_equal expected, @evaluator.send(:get_model_name, actual)
        end
      end
    end

    def test_shall_correctly_evaluate_policy
      expected = :insufficient_slaves

      container = Container.create(
        :id => 10,
        :ip => '192.168.122.1'
      )
      policy = Policy.create(
        :name => 'threshold_model',
        :parameters => {:min => 10, :max => 50}
      )
      values = ["90", "95" , "98", "60"]

      actual = @evaluator.evaluate(policy, container, values)
      assert_equal(expected, actual)
    end

  end
end