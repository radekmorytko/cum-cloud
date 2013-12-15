require 'opennebula/appflow_client'
require 'opennebula/opennebula_frontend'
require 'opennebula/opennebula_supervisor'
require 'opennebula/service_renderer'

module AutoScaling

  # Facade that provides access to opennebula resources (both frontend and appflow)
  class OpenNebulaClient

    attr_reader :appflow
    attr_reader :frontend
    attr_reader :monitor

    #
    # * options - connectivity parameters, ex:
    #
    # options = {
    #   'username'   => 'username',        <- opennebula username (also a linux user)
    #   'password'   => 'password',        <- opennebula username password (also a password of a linux user)
    #   'host_password' => 'password'      <- opennebula compute node password (plaintext)
    #   'endpoints'  => {                  <- hashmap of endpoints that are used by this client (all of them have to support the same credential)
    #     'opennebula' => 'http://redtube.com:69/XMLRPC2'
    #     'appflow' => 'http://pudelek.pl:4567'
    #   },
    #   'monitoring_keys' => ['CPU', 'MEMORY']
    # }
    def initialize(options)
      @appflow = AppflowClient.new options
      @frontend = OpenNebulaFrontend.new options
      @monitor = OpenNebulaSupervisor.new options
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

    def delete_container(container_id)
      @frontend.delete_container container_id
    end

    def host_by_container(container_id)
      @frontend.host_by_container(container_id)
    end

    # Creates an instance of a container with a predefined template in mappings
    def instantiate_container(stack_type, container_role, mappings)
      @frontend.instantiate_container(stack_type, container_role, mappings)
    end

    def monitor_container(container_id)
      @frontend.monitor(container_id)
    end

    def monitor_host(host_name)
      @monitor.monitor_host(host_name)
    end

    def image_name(image_id)
      @frontend.image_name(image_id)
    end

    def render(service, bindings)
      ServiceRenderer::render(service, bindings)
    end

    def capacity()
      @frontend.capacity
    end

  end

end