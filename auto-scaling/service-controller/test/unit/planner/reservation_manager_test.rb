require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'utils'
require 'planner/reservation_manager'

module AutoScaling
  class ReservationManagerTest < Test::Unit::TestCase

    def setup
      @cloud_provider = mock()
      @cloud_provider.expects(:capacity).returns({:cpu => 5, :memory => 5})

      @reservation_manager = ReservationManager.new(@cloud_provider)
    end

    def test_shall_reserve_resources
      @reservation_manager.reserve({:cpu => 5, :memory => 2})
      @reservation_manager.free(:memory => 2)
      @reservation_manager.reserve(:memory => 5)
    end

    def test_shall_raise_insufficient_resources
      assert_raise InsufficientResources do
        @reservation_manager.reserve(:cpu => 6)
      end
    end

  end
end
