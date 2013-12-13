require 'common/configurable'
require 'domain/domain'
require 'logger'

module AutoScaling
  class StackDeployer
    include Configurable

    @@logger       = Logger.new(STDOUT)
    @@logger.level = Logger::DEBUG

    def initialize(stack_controller, container_controller)
      @stack_controller     = stack_controller
      @container_controller = container_controller
    end

    def deploy(stack_data)
        @@logger.debug "Planning deployment of: #{stack_data}"
        stack = @stack_controller.plan_deployment(stack_data)
        @@logger.debug "Deployed stack #{stack.to_json}"

        @stack_controller.converge(stack)

        stack.containers.each do |container|
          @container_controller.schedule(container, config['scheduler']['interval'])
        end

        stack
    rescue RuntimeError => e
      @@logger.error e
      raise e
    end
  end
end
