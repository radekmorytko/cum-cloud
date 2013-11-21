require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'rack/test'
require 'json'
require 'fakeweb'
require 'uri'
require 'rest-client'

ENV['RACK_ENV'] = 'test'

require 'auto_scaling_server'
# helper for generating opennebula responses
require 'cloud-provider/test/opennebula_generator'


module AutoScaling
  class AutoScalingServerTest < Test::Unit::TestCase

    include Rack::Test::Methods

    def app
      AutoScalingServer
    end

    def setup
      ENV['RACK_ENV'] = 'test'

      config = YAML.load_file('config/config.yaml')
      @settings = config['endpoints'][ENV['RACK_ENV']]['opennebula']
    end

    def url
      username = @settings['username']
      password = @settings['password']
      uri = URI(@settings['endpoints']['appflow'])

      "#{uri.scheme}://#{username}:#{password}@#{uri.host}:#{uri.port}#{uri.path}"
    end

    def test_shall_deploy_a_service

      msg = {
        'name' => 'kwejk.pl',
        'stacks' => [
          {
            'type' => 'java',
            'instances' => 2,
            'name' => 'stack-name',
            'policy_set' => {
                'min_vms' => 0,
                'max_vms' => 2,
                'policies' => [{'name' => 'threshold_model', 'parameters' => {'min' => '5', 'max' => '50'} }]
            }
          }
        ]
      }

      instance_id = 144
      master = {:id => 200, :ip => '192.168.122.100'}
      slave = {:id => 201, :ip => '192.168.122.101'}
      response = OpenNebulaGenerator.show_service(
          :service_id => instance_id,
          :state => 2,
          :master_id => master[:id],
          :master_ip => master[:ip],
          :slave_id => slave[:id],
          :slave_ip => slave[:ip]
      )

      template_id = 120

      puts "Using url: #{url}"
      FakeWeb.register_uri(:get, "#{url}/service/#{instance_id}", {:body => response, :times => 5})
      FakeWeb.register_uri(:post, "#{url}/service_template", :body => '{ "DOCUMENT": { "ID": "120" } }')
      FakeWeb.register_uri(:post, "#{url}/service_template/#{template_id}/action", :body => '{ "DOCUMENT": { "ID": "144" } }')

      # convergence
      FakeWeb.register_uri(:post, "http://#{master[:ip]}:4567/chef", :status => ["200", "OK"])
      FakeWeb.register_uri(:post, "http://#{slave[:ip]}:4567/chef", :status => ["200", "OK"])

      post '/service', msg.to_json
      assert last_response.ok?
      service_id = JSON.parse(last_response.body)['id']
      service = Service.get(service_id)
      assert_equal :converged, service.status

      # monitoring data
      # note that it is quite hard to mock xmlrpc (one endpoint is common to all request)
      # hence, i use rotating response and assume that master is probed first
      master[:response] = OpenNebulaGenerator.monitor_vm(:master_id => master[:id])
      slave[:response] = OpenNebulaGenerator.monitor_vm(:slave_id => slave[:id])
      response = OpenNebulaGenerator.template_info(::AutoScaling::Template.new('ubuntu'))
      FakeWeb.register_uri(:post,
                           "#{@settings['endpoints']['opennebula']}",
                           [{:status => ["200", "OK"], :body => master[:response], :content_type => "text/xml"},
                            {:status => ["200", "OK"], :body => slave[:response], :content_type => "text/xml"},
                            {:status => ["200", "OK"], :body => response, :content_type => "text/xml"},
                            {:status => ["200", "OK"], :body => master[:response], :content_type => "text/xml"},
                            {:status => ["200", "OK"], :body => slave[:response], :content_type => "text/xml"}])

      sleep 10
    end

  end
end
