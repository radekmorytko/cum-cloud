require 'opennebula/appflow_client'
require 'opennebula/service_renderer'

module AutoScaling

  # facade that provide access to opennebula resources (both frontend and appflow)
  class OpenNebulaClient

    attr_reader :appflow

    #
    # * options - connectivity parameters, ex:
    #
    # options = {
    #   :username   => 'username',
    #   :password   => 'password',
    #   :url        => 'http://redtube.com/cum-cloud:69'
    # }
    def initialize(options)
      @appflow = AppflowClient.new options
    end

    def create_template(service_template)
      @appflow.create_template service_template
    end

    def instantiate_template(template_id)
      @appflow.instantiate_template template_id
    end

    def configuration(service_id)
      @appflow.configuration service_id
    end

    def render(service, bindings)
      ServiceRenderer::render(service, bindings)
    end

  end

end