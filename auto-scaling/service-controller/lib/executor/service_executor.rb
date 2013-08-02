require 'rubygems'
require 'logger'
require 'rest_client'
require 'base64'

require 'executor/chef_renderer'
require 'models/models'

module AutoScaling

  class ServiceExecutor

    @@logger = Logger.new(STDOUT)

    def initialize(cloud_provider)
      @cloud_provider = cloud_provider
    end

    # * *Args* :
    # - +service+ -> description of a service. An instance of HashMap, ex:
    #   service = {
    #     'stack' => 'tomcat',
    #     'instances' => 2,
    #     'name' => 'enterprise-app'
    #   }
    #
    def deploy_service(service, mappings)
      # create appflow template
      # but first we need to have appflow service-representation
      raise ArgumentError, "Mappings cannot be nil nor empty" if mappings == nil or mappings.empty?

      service_definition = @cloud_provider.render service, mappings
      template_id = @cloud_provider.create_template service_definition

      # instantiate
      instance_id = @cloud_provider.instantiate_template template_id

      # update data model
      # TODO support for more than one stack
      stacks = [Stack.create(
        :type => service['stack']
      )]

      Service.create(
        :id => instance_id.to_i,
        :name => service['name'],
        :stacks => stacks
      )
    end

    def deploy_container(stack, mappings = {})
      raise ArgumentError, "Mappings cannot be nil nor empty" if mappings == nil or mappings.empty?

      appstage_id = mappings[:appstage][stack.type.to_sym][:slave]
      template_id = mappings[:onetemplate_id]

      container_info = @cloud_provider.instantiate_container(appstage_id, template_id, stack.service.id)

      # persist data
      container = Container.create(
          :id => container_info[:id],
          :ip => container_info[:ip]
      )
      stack.containers << container

      stack.save

      # reconfigure master
      configure(Container.master(stack))
    end

    def delete_container(stack, mappings = {})
      slaves = Container.slaves(stack)
      raise RuntimeError, "Can't delete slave from stack: #{stack.id}, there aren't any left" if slaves.size == 0

      slave = slaves.pop
      @cloud_provider.delete_container slave.id
      slave.destroy
      stack.save

      # reconfigure master
      configure(Container.master(stack))
    end

    def converge(service, container_id)
      update(service) if(service.status != :converged)
      container = ::AutoScaling::Container.get(container_id)

      configure(container) if container.type == :master
    end

    private
    # Updates model, so it reflects actual configuration
    #
    # * *Args* :
    # - +service+ -> instance of models/service
    def update(service)
      # {
      #   "loadbalancer" => [{:ip=>"192.168.122.100", :id=>"138"}],
      #   "worker" => [{:ip=>"192.168.122.101", :id=>"139"}]
      # }
      conf = @cloud_provider.configuration(service.id)
      @@logger.debug("Got configuration for a service #{service.id}: #{conf}")

      # TODO support for more than one stack
      stack = service.stacks[0]
      stack.containers = [Container.create(
                              :id => conf['master'][0][:id].to_i,
                              :ip => conf['master'][0][:ip],
                              :type => :master
                          )]

      conf['slave'].each do |vm|
        stack.containers << Container.create(
            :id => vm[:id].to_i,
            :ip => vm[:ip]
        )
      end

      # TODO add synchronization
      service.status = :converged
      service.save
    end

    def configure(container)
      chef = ChefRenderer.render container.stack
      url = "http://#{container.ip}:4567/chef"

      @@logger.debug "Sending configuration #{chef} to #{url}"

      RestClient.post(url, :node_object_data => Base64::encode64(chef)) { |response, request, result, &block|
        case response.code
          when 200
            @@logger.debug "Successfully sent configuration #{response}"
            response
          else
            raise RuntimeError, "An error occurred during sending configuration, status: #{response.code}"
        end
      }
    end

  end

end