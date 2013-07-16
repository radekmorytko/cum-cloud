require 'rubygems'
require 'logger'

require 'executor/service'

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
    def deploy_service(service)
      # create appflow template
      # but first we need to have appflow service-representation
      bindings = {
          :loadbalancer_template_id => 6,
          :loadbalancer_appstage_id => 9,
          :worker_template_id => 2,
          :worker_appstage_id => 20
      }

      service_definition = Service::instantiate service, bindings
      template_id = @appflow_client.create_service_template service_definition

      # instantiate
      @appflow_client.instantiate_service template_id
    end

  end

end