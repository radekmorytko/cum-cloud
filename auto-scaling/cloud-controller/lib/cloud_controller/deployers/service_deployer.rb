require 'logger'

module AutoScaling
  class ServiceDeployer
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
      service.notify_observer_process

      service
    end
  end
end
