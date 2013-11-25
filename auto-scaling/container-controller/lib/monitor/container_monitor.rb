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

    def monitor_container(container)
      data = @cloud_provider.monitor_container container.id
      @@logger.debug "Grabbed data about container: #{container}, #{data}"

      # filter out historical data
      result = {}
      selection = []
      data.each do |key, probes|
        selection = last(probes, container)
        result[key] = selection
      end
      container.probed = selection.last[0] if selection.last != nil
      container.save

      result
    end

    def collect_values(data)
      template = {}
      data.each do |key, probes|
        template[key] = probes.collect {|x| x[1]}
      end

      template
    end

  end
end
