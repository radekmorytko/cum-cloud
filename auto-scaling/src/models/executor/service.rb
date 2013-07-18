require 'rubygems'
require 'logger'
require 'erb'

module AutoScaling

  class Service

    @logger = Logger.new(STDOUT)

    def initialize

    end

    def to_json

    end

    def self.instantiate(service, bindings)
      result = ServiceTemplate.new(
          service['name'],

          bindings[:loadbalancer_template_id],
          bindings[:loadbalancer_appstage_id],

          service['stack'],
          bindings[:worker_template_id],
          bindings[:worker_appstage_id],
          service['instances']
      )

      render = result.render

      @logger.debug "Created service template: #{render}"
      render
    end

    ServiceTemplate = Struct.new(
        :name,
        :loadbalancer_template_id,
        :loadbalancer_appstage_id,
        :stack,
        :worker_template_id,
        :worker_appstage_id,
        :worker_instances) do

      def render
        template_path = File.join(File.dirname(File.expand_path(__FILE__)), 'service_definition.erb')
        template = File.read(template_path)

        ERB.new(template).result(binding)
      end
    end

  end

end