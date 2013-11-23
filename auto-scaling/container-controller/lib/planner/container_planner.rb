require 'rubygems'
require 'logger'
require 'set'

require 'models/models'

module AutoScaling
  class ContainerMonitor

    @@logger = Logger.new(STDOUT)

    def monitor(container)
      @@logger.debug "Monitoring a container #{container}"

      data = {}
      data
    end

  end
end
