require 'rubygems'
require 'logger'

load 'models/executor/executor.conf'
require 'models/executor/service'

module AutoScaling

  class ServiceExecutor

    def initialize(appflow_client)
      @appflow_client = appflow_client
    end

    # * *Args* :
    # - +service+ -> description of a service. An instance of HashMap, ex:
    #   service = {
    #     :stack => :tomcat,
    #     :instances => 2,
    #     :name => 'enterprise-app'
    #   }
    #
    def deploy_service(service, mappings = {})
      # create appflow template
      # but first we need to have appflow service-representation
      mappings ||= {}
      mappings = ONE_MAPPINGS.merge(mappings)

      bindings = {
          :loadbalancer_template_id => mappings[:onetemplate_id],
          :loadbalancer_appstage_id => mappings[:appstage][:loadbalancer],
          :worker_template_id => mappings[:onetemplate_id],
          :worker_appstage_id => mappings[:appstage][:java]
      }

      service_definition = Service::instantiate service, bindings
      template_id = @appflow_client.create_template service_definition

      # instantiate
      @appflow_client.instantiate_template template_id
    end

  end

end