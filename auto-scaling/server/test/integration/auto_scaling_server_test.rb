require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'rack/test'
require 'json'
require 'fakeweb'

ENV['RACK_ENV'] = 'test'

require 'auto_scaling_server'

module AutoScaling
  class AutoScalingServerTest < Test::Unit::TestCase

    include Rack::Test::Methods

    def app
      AutoScalingServer
    end

    def setup
      config = YAML.load_file('config/config.yaml')
    end

    def url
      username = "bolek"
      password = "lolek"
      endpoint = "cloud.com:6969"

      "http://#{username}:#{password}@#{endpoint}"
    end

    def test_shall_deploy_a_service

      msg = {
          "name" => "myapp",
          "instances" => 1,
          "stack" => "java"
      }

      template_id = 120
      FakeWeb.register_uri(:post, "#{url}/service_template", :body => '{ "DOCUMENT": { "ID": "120" } }')
      FakeWeb.register_uri(:post, "#{url}/service_template/#{template_id}/action", :body => '{ "DOCUMENT": { "ID": "144" } }')

      post '/service', msg.to_json

      assert last_response.ok?
    end

  end
end
