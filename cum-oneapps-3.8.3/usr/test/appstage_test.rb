require File.dirname(__FILE__) + '/../lib/cum-oneapps.rb'
require "test/unit"

class AppStageTest < Test::Unit::TestCase

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

  # Fake test
  def test_fail

    ## stage
    client = OpenNebula::Client.new 'oneadmin:oneadmin', 'http://192.168.122.221:2633'

    chef_doc=OpenNebula::ChefDoc.new(OpenNebula::ChefDoc.build_xml(16), client)
    chef_doc.info

    puts OpenNebula::ChefDoc.build_xml(16)
    puts chef_doc.to_json
    #chef_doc.instantiate(1)


    #chef_conf = OpenNebula::ChefConf.new
    #chef_conf['node'] = 'dziffka'

    ## flow

    service_template = OpenNebula::ServiceTemplate.new_with_id(18, client)
    service_template.info
    #puts service_template.to_json
    #service = OpenNebula::Service.new(OpenNebula::Service.build_xml, client)

    puts "service_template.template: #{service_template.template}"

    #service.allocate(service_template.template)


    # To change this template use File | Settings | File Templates.
    #fail("Not implemented")
  end
end