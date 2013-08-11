require 'opennebula/appflow_client'
require 'opennebula/appstage_client'
require 'opennebula/opennebula_frontend'
require 'opennebula/service_renderer'

module AutoScaling

  # facade that provide access to opennebula resources (both frontend and appflow)
  class OpenNebulaClient

    attr_reader :appflow
    attr_reader :appstage

    #
    # * options - connectivity parameters, ex:
    #
    # options = {
    #   'username'   => 'username',        <- opennebula username (also a linux user)
    #   'password'   => 'password',        <- opennebula username password (also a password of a linux user)
    #   'endpoints'  => {                  <- hashmap of endpoints that are used by this client (all of them have to support the same credential)
    #     'opennebula' => 'http://redtube.com:69/XMLRPC2'
    #     'appflow' => 'http://pudelek.pl:4567'
    #   },
    #   'monitoring_keys' => ['CPU', 'MEMORY']
    # }
    def initialize(options)
      @appflow = AppflowClient.new options
      @appstage = AppstageClient.new options
      @frontend = OpenNebulaFrontend.new options
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

    def create_stack(definition)
      @appstage.create_template(definition)
    end



    def delete_container(container_id)
      @frontend.delete_container container_id
    end

    def instantiate_container(stack_type, container_role, service_id, mappings)
      @frontend.instantiate_container(stack_type, container_role, service_id, mappings)
    end

    def monitor_container(container_id)
      @frontend.monitor(container_id)
    end

    def save_container(container_id)
      @frontend.save_container(container_id)
    end

    def shutdown_container(container_id)
      @frontend.shutdown_container(container_id)
    end

    def image_name(image_id)
      @frontend.image_name(image_id)
    end

    def render(service, bindings)
      ServiceRenderer::render(service, bindings)
    end

  end

end