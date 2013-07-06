require "test/unit"
require "one_chef"

class ChefTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_chef_creates_conf
    chef = OneChef.new
    #chef.create_config_file( :path => '/home/radek', :filename => 'chef.conf')
    #chef.create_node_object_file(:data => )
    #chef.run(
    #    :config => {
    #        :template_filename => 'chef.conf.erb',
    #        :filename => 'chef.conf',
    #        :path => '/tmp'
    #    },
    #    :node_object => {
    #        :file => '/tmp/node.json',
    #        :data => '{ "run_list" : [ "recipe[apache2]" ]}'
    #    }
    #)
  end

end