require 'rubygems'
require 'logger'

require 'cloud_provider'
require 'models/models'

module AutoScaling
  class ServiceMonitor

    @@logger = Logger.new(STDOUT)

    def initialize(cloud_provider)
      @cloud_provider = cloud_provider
    end

    def monitor(service_id)
      # check all vms that forms a service
      service = Service.get(service_id)

      data = {}
      service.stacks.each do |stack|
        stack.containers.each do |container|
          data[container.id] = monitor_container(container)
        end
      end

      data
    end

    def monitor_container(container)
      data = @cloud_provider.monitor_container container.id
      data.merge(data){ |k, probes| last(probes, container) }
    end

    private
    # example data
    # [["1374678040", "524288"], ["1374678083", "524288"], ["1374678113", "524288"], ["1374678155", "524288"]]
    def last(data, container)
      selection = data.select {|item| item[0].to_i > container.probed.to_i }
      container.probed = selection.last[0] if selection.last != nil
      container.save

      selection
    end

  end
end
