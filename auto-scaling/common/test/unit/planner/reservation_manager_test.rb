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
      @cloud_provider = mock()
      @reservation_manager = ReservationManager.new(@cloud_provider, {:cpu => 5, :memory => 1024}, requirements['stacks'])
    end

    def test_shall_check_if_deployment_is_possible
      stack_data = {
        'type' => 'boot',
        'instances' => 2
      }
      assert @reservation_manager.reserve?(stack_data)

      stack_data = {
          'type' => 'boot',
          'instances' => 20
      }
      assert !@reservation_manager.reserve?(stack_data)
    end

    def test_shall_reserve_resources
      @reservation_manager.reserve({:cpu => 5, :memory => 1024})
      @reservation_manager.free(:memory => 1024)
      @reservation_manager.reserve(:memory => 1024)
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

    def test_shall_scale_up
      host_name = 'node'
      container = Container.create(

      )

      @cloud_provider.expects(:monitor_host).with(host_name).returns({:cpu => 10})
      @cloud_provider.expects(:host_by_container).with(100).returns(host_name)

      @reservation_manager.scale_up(container, :cpu, 10)
    end

    def test_shall_raise_insufficient_resources_when_scaling_up
      host_name = 'node'

      @cloud_provider.expects(:monitor_host).with(host_name).returns({:cpu => 9})
      @cloud_provider.expects(:host_by_container).with(100).returns(host_name)

      assert_raise InsufficientResources do
        @reservation_manager.scale_up(container, :cpu, 10)
      end
    end

  end
end
