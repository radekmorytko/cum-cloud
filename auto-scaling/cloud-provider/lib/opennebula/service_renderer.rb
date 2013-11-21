require 'rubygems'
require 'logger'
require 'erb'

module AutoScaling

  class ServiceRenderer

    @logger = Logger.new(STDOUT)

    #
    # * service - AutoScaling::Service
    # * mappings - additonal information, needed to render template
    def self.render(stack, mappings)

      result = ServiceTemplate.new(
          stack['name'],
          mappings['stacks'][stack['type']]['master'],
          mappings['stacks'][stack['type']]['slave'],
          stack['instances']
      )

      render = result.render
      @logger.debug "Created service template: #{render}"
      render
    end

    ServiceTemplate = Struct.new(
        :name,
        :master_template_id,
        :worker_template_id,
        :worker_instances) do

      def render
        template_path = File.join(File.dirname(File.expand_path(__FILE__)), 'templates', 'stack_definition.erb')
        template = File.read(template_path)

        ERB.new(template).result(binding)
      end
    end

  end

end