require 'rubygems'
require 'logger'

load 'config/auto_scaling.conf'
require 'models/service'

module AutoScaling

  class ServiceExecutor

    attr_accessor :services

    def initialize(appflow_client, one_client)
      @appflow_client = appflow_client
      @one_client = one_client
      @services = {}
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

      bindings = {
          :loadbalancer_template_id => mappings[:onetemplate_id],
          :loadbalancer_appstage_id => mappings[:appstage][:loadbalancer],
          :worker_template_id => mappings[:onetemplate_id],
          :worker_appstage_id => mappings[:appstage][:java]
      }

      service_definition = Service::instantiate service, bindings
      template_id = @appflow_client.create_template service_definition

      # instantiate
      instance_id = @appflow_client.instantiate_template template_id

      service = AutoScaling::Service.new instance_id
      @services[instance_id] = service
    end

    # returns list of ips of an environment in form:
    # {
    #   :loadbalancer => '192.168.122.1'
    #   :worker => ['192.168.122.10', '192.168.122.11']
    # }
    def ips(service_id)
      ips = {}

      # vm_ids = {:loadbalancer => 0, :worker => [1, 2, 3]}
      vm_ids = @appflow_client.vm_ids service_id

      ips[:loadbalancer] = @one_client.vm_ip(vm_ids[:loadbalancer])
      ips[:worker] = []

      vm_ids[:worker].each do |id|
        ips[:worker] << @one_client.vm_ip(id)
      end

      ips
    end

  end

end