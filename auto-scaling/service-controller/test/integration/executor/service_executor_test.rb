require 'rubygems'
require 'test/unit'
require 'mocha/setup'

require 'executor/service_executor'
require 'cloud-provider/cloud_provider'

module AutoScaling
  class ServiceExecutorTest < Test::Unit::TestCase

    def setup
      options = {
          'username' => 'oneadmin',
          'password' => 'password',
          'endpoints' =>  {
              'opennebula' => 'http://one:2633/RPC2',
              'appflow' => 'http://one:2474'
          },
          'monitoring_keys' => ['CPU', 'MEMORY']
      }

      mappings = {
          'onetemplate_id' => 7,

          # supported stacks
          'appstage' => {
              'java' => {
                  'master' => 39,
                  'slave' => 25
              }
          }
      }


      @provider = OpenNebulaClient.new options
      @executor = ServiceExecutor.new(@provider, mappings)
    end

    def test_shall_bootstrap_configuration
      definition = <<-eos
{
  "name": "tomcat-stack",
  "run_list": [
    "recipe[tomcat]"
  ]
}
      eos

      image_id = @executor.bootstrap(definition)
      assert_not_nil @provider.image_name(image_id)
    end

  end
end
