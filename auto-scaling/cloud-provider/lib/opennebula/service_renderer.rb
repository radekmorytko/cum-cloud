require 'rubygems'
require 'logger'
require 'erb'

module AutoScaling

  class ServiceRenderer

    @logger = Logger.new(STDOUT)

    #
    # * service - AutoScaling::Service
    # * mappings - additonal information, needed to render template
    def self.render(service, mappings)

      result = ServiceTemplate.new(
          service['name'],

          mappings[:onetemplate_id],
          mappings[:appstage][service['stack'].to_sym][:master],

          mappings[:onetemplate_id],
          mappings[:appstage][service['stack'].to_sym][:slave],
          service['instances']
      )

      render = result.render
      @logger.debug "Created service template: #{render}"
      render
    end

    ServiceTemplate = Struct.new(
        :name,
        :master_template_id,
        :master_appstage_id,
        :worker_template_id,
        :worker_appstage_id,
        :worker_instances) do

      def render
        template_path = File.join(File.dirname(File.expand_path(__FILE__)), 'templates', 'service_definition.erb')
        template = File.read(template_path)

        ERB.new(template).result(binding)
      end
    end

  end

end