require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'vm_coordinator'
require 'json'

class OneChefTest < Test::Unit::TestCase

  def test_run_chef
    node_object = JSON.generate( { :params => { :name => 'ala', :age => 12 }, :list => [1, 2, 3]})
    chef = mock()
    chef.expects(:run).with({ :node_object => node_object, :config => { :sth => 1 } })
    vm_coordinator = OneChef.new(
        :chef => chef
    )
    vm_coordinator.run_chef({ :node_object => node_object, :config => { :sth => 1 } })
  end

  def test_run_chef_with_empty_or_nil_node_list
    vm_coordinator = OneChef.new

    assert_raise ArgumentError do
      vm_coordinator.run_chef(nil)
    end

    assert_raise ArgumentError do
      vm_coordinator.run_chef(:node_object => {})
    end

  end

end