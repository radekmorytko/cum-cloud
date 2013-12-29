require 'logger'
require 'common/configurable'

module AutoScaling
  class ServiceDeployer
    include Configurable

    @@logger       = Logger.new(STDOUT)
    @@logger.level = Logger::DEBUG

    def initialize(stack_deployer)
      @stack_deployer = stack_deployer
    end

    def deploy(service_data)
      service_attributes = {
        :name                   => service_data['name'],
        :autoscaling_queue_name => service_data['autoscaling_queue_name']
      }
      service = Service.new(service_attributes)
      raise 'There is already a service with the given name!' unless service.save

      service_data['stacks'].each do |stack_data|
        begin
          service.stacks << @stack_deployer.deploy(stack_data)
        rescue RuntimeError => ex
          @@logger.warn "Error while deploying a stack #{stack_data} #{ex}"
        end
      end

      service.save

      # For integration tests only
      notify_observer_process(service)
      service
    end

    private

    # This method is used in an integration test where it
    # sends USR1 signal to the test-runner process
    def notify_observer_process(service)
      return if (not service.deployed?) or 
                (not config.has_key?('test-cases')) or
                (not config['test-cases'].has_key?('runner-pid'))

      pid_to_notify = config['test-cases']['runner-pid']

      @@logger.debug("Notifying process #{pid_to_notify} about the deployed service")

      Process.kill('USR1', pid_to_notify)
    end
  end
end
