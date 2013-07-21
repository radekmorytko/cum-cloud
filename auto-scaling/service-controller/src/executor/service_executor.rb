require 'rubygems'
require 'logger'
require 'rest_client'

load 'config/auto_scaling.conf'
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
    def deploy_service(service, mappings = {})
      # create appflow template
      # but first we need to have appflow service-representation
      mappings ||= {}
      mappings = MAPPINGS.merge(mappings)

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

      # TODO support only for one stack
      stack = service.stacks[0]
      stack.master = Container.create(
          :id => conf['master'][0][:id].to_i,
          :ip => conf['master'][0][:ip]
      )
      stack.slaves = []

      conf['slave'].each do |vm|
        stack.slaves << Container.create(
            :id => vm[:id].to_i,
            :ip => vm[:ip]
        )
      end

      # TODO add synchronization
      service.status = :converged
      service.save
    end

    def converge(service, container)
      update(service) if(service.status != :converged)

      if(container.master?)
        chef = ChefRenderer.render container.stack
        url = "http://#{container.ip}:4567/chef"

        @@logger.debug "Sending configuration #{chef} to #{url}"

        RestClient.post(url, :node_object_data => chef) { |response, request, result, &block|
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

end