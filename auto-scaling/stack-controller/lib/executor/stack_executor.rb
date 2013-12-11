require 'rubygems'
require 'logger'
require 'rest_client'
require 'base64'

require 'executor/chef_renderer'
require 'domain/domain'

module AutoScaling

  class StackExecutor

    @@logger = Logger.new(STDOUT)

    def initialize(cloud_provider, mappings)
      raise ArgumentError, "Mappings cannot be nil nor empty" if mappings == nil or mappings.empty?

      @cloud_provider = cloud_provider
      @mappings = mappings
    end

    # * *Args* :
    # - +stack+ -> description of a stack. An instance of HashMap, ex:
    #   stack =
    #   {
    #     'stack' => 'tomcat',
    #     'instances' => 2,
    #     'name' => 'enterprise-app'
    #     'policy_set' =>
    #        :min_vms =>  0
    #        :max_vms =>  2
    #        :polices => [{'name' => 'threshold_model', :parameters => {'min' => '5', 'max' => '50'}}]
    #   }
    #
    def deploy_stack(stack_data)
      @@logger.debug "Deploying stack #{stack_data} with mappings: #{@mappings}"

      stack = create_stack(stack_data)
      update(stack)

      stack
    end

    def deploy_container(stack)
      @@logger.debug "Deploying container at #{stack} with mappings: #{@mappings}"
      container_info = @cloud_provider.instantiate_container(stack.type.to_s, 'slave', @mappings)

      # persist data
      container = Container.create(
          :correlation_id => container_info[:id],
          :ip => container_info[:ip]
      )
      stack.containers << container

      stack.save

      # reconfigure master
      configure(Container.master(stack))
    end

    def delete_container(stack)
      @@logger.debug "Deleting container from #{stack}"
      slaves = Container.slaves(stack)
      raise RuntimeError, "Can't delete slave from stack: #{stack.id}, there aren't any left" if slaves.size == 0

      slave = slaves.pop
      @cloud_provider.delete_container slave.correlation_id
      slave.destroy
      stack.save

      # reconfigure master
      configure(Container.master(stack))
    end

    def converge(container_id)
      container = ::AutoScaling::Container.get(container_id)
      configure(container) if container.master?
    end

    private
    # Updates model, so it reflects actual configuration
    #
    # * *Args* :
    # - +stack+ -> instance of stack
    def update(stack)
      # note method blocks until i get a full configuration (inc ids and ips)
      conf = @cloud_provider.configuration(stack.correlation_id)
      @@logger.debug("Got configuration for a stack #{stack.correlation_id}: #{conf}")

      stack.containers = [Container.create(
                              :correlation_id => conf['master'][0][:id].to_i,
                              :ip => conf['master'][0][:ip],
                              :type => :master
                          )]

      conf['slave'].each do |vm|
        stack.containers << Container.create(
            :correlation_id => vm[:id].to_i,
            :ip => vm[:ip]
        )
      end

      stack.state = :deployed
      stack.save
    end

    def configure(container)
      chef = ChefRenderer.render container.stack
      url = "http://#{container.ip}:4567/chef"

      @@logger.debug "Sending configuration #{chef} to #{url}"

      RestClient.post(url, :node_object_data => Base64::encode64(chef)) { |response, request, result, &block|
        case response.code
          when 200
            @@logger.debug "Successfully sent configuration #{response}"
            # this is simplification - master not necessarily is the last deployed container
            container.stack.state = :converged
            response
          else
            raise RuntimeError, "An error occurred during sending configuration, status: #{response.code}"
        end
      }
    end

    def create_stack(stack)
      # create appflow template
      # but first we need to have appflow stack-representation
      stack_definition = @cloud_provider.render stack, @mappings
      template_id = @cloud_provider.create_template stack_definition

      # instantiate
      instance_id = @cloud_provider.instantiate_template template_id

      policies = []
      stack['policy_set']['policies'].each do |policy|
        policies << Policy.create(
            :name => policy['name'],
            :arguments => policy['arguments']
        )
      end

      policy_set = PolicySet.create(
          :min_vms => stack['policy_set']['min_vms'],
          :max_vms => stack['policy_set']['max_vms'],
          :policies => policies
      )

      Stack.create(
          :type => stack['type'],
          :correlation_id => instance_id,
          :policy_set => policy_set
      )
    end

  end

end