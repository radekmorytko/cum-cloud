require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'utils'
require 'planner/reservation_manager'

module AutoScaling
  class ReservationManagerTest < Test::Unit::TestCase

    def setup
      requirements = {
        'stacks' => {
          'boot' => {
            'requirements' => {
              'cpu' => '0.3',
              'memory' => '256'
            }
          }
        }
      }
      @reservation_manager = ReservationManager.new(@cloud_provider, {:cpu => 5, :memory => 5}, requirements['stacks'])
    end

    def test_shall_reserve_resources
      @reservation_manager.reserve({:cpu => 5, :memory => 2})
      @reservation_manager.free(:memory => 2)
      @reservation_manager.reserve(:memory => 5)
    end

    def test_shall_return_resource_requirements
      expected = {:cpu => 0.3, :memory => 256.0}
      actual = @reservation_manager.resources('boot')

      assert_equal expected, actual
    end

    def test_shall_raise_insufficient_resources
      assert_raise InsufficientResources do
        @reservation_manager.reserve(:cpu => 6)
      end
    end

  end
end
