require 'rubygems'
require 'logger'

require 'cloud-provider/cloud_provider'
require 'domain/domain'

module AutoScaling
  class StackMonitor

    @@logger = Logger.new(STDOUT)

    def initialize(cloud_provider)
      @cloud_provider = cloud_provider
    end

    # Monitors given service by grabbing data from specified cloud provider
    #
    # * *Args* :
    # - +service+ -> reference to a service. An instance of AutoScaling::Service class
    def monitor(stack)
      @@logger.debug "Monitoring a service #{stack}"

      # check all vms that forms a service
      data = {}

      data
    end

  end
end
