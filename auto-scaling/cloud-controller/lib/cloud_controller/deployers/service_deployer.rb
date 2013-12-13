require 'domain/domain'
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
      #  :name                   => service_data[:name],
        :autoscaling_queue_name => service_data[:autoscaling_queue_name]
      }
      service = Service.new(service_attributes)
      service.name = service_data[:name]
      raise 'There is already a service with the given name!' unless service.save

      service_data[:stacks].each do |stack_data|
        service.stacks << @stack_deployer.deploy(stack_data)
      end

      service.save
    end
  end
end
