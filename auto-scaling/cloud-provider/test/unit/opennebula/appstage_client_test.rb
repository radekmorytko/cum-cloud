require 'rubygems'
require "test/unit"

require 'opennebula/appstage_client'
require 'opennebula_generator'

module AutoScaling

  class AppstageClientTest < Test::Unit::TestCase

    def test_shall_extract_ip
      appstage = AppstageClient.new({})

      expected = '192.168.122.104'
      configuration = OpenNebulaGenerator.show_vm(ShowVm.new(100, expected))
      actual = appstage.send(:extract_ip, configuration)

      assert_equal expected, actual
    end
  end
end