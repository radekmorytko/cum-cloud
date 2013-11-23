require 'rubygems'
require 'logger'
require 'set'

require 'models/models'

module AutoScaling
  class ContainerMonitor

    @@logger = Logger.new(STDOUT)

    def initialize(cloud_provider)
      @cloud_provider = cloud_provider
    end

    def monitor(container)
      @@logger.debug "Monitoring a container #{container}"
      probes = monitor_container(container)
      collect_values(probes)
    end

  end
end
