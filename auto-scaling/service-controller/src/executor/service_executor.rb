require 'rubygems'
require 'logger'

load 'config/auto_scaling.conf'
require 'models/models'

module AutoScaling

  class ServiceExecutor

    attr_accessor :services

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
      mappings = ONE_MAPPINGS.merge(mappings)

      service_definition = @cloud_provider.render service, mappings
      template_id = @cloud_provider.create_template service_definition

      # instantiate
      instance_id = @cloud_provider.instantiate_template template_id

      # update data model
      stacks = [Stack.create(
          :type => service['stack']
      )]

      Service.create(
          :id => instance_id.to_i,
          :name => service['name'],
          :stacks => stacks
      )
    end

  end

end