require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'utils'
require 'analyzer/threshold_model'

module AutoScaling
  class ThresholdModelTest < Test::Unit::TestCase

    MIN = 10
    MAX = 50

    def setup
      @model = ThresholdModel.new(MIN, MAX)
    end

    def test_shall_validate_arguments
      assert_raise ArgumentError do
        ThresholdModel.new(10, 1)
      end
    end

    def test_shall_analyse_by_count
      # list of values in form: [[timestamp, value], [timestamp, value], [timestamp, value]]
      data = [["10", "5" , "8", "60"], ["10", "50" , "80"], ["11", "15" , "50"]]
      expected = [:lesser, :greater, :fits]

      (0..data.size - 1 ).each do |i|
        actual = @model.analyze(data[i])
        assert_equal expected[i], actual
      end
    end

    def test_shall_aggregate_data
      data = ["10", "5" , "7", "60"]

      assert_equal :greater, @model.analyze(data.max {|x,y | x.to_i <=> y.to_i })
      assert_equal :greater, @model.analyze( data.last )
      assert_equal :lesser, @model.analyze( data.min {|x,y | x.to_i <=> y.to_i } )
      assert_equal :fits, @model.analyze((data.inject{ |sum, el| sum.to_i + el.to_i }.to_f / data.size).to_s)
    end

  end
end