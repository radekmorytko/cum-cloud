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

    # Monitors given service by grabbing data from specified cloud provider
    #
    # * *Args* :
    # - +service+ -> reference to a service. An instance of AutoScaling::Service class
    #
    # Returns hashmap that consists mapping stacks => containers => metrics, ex:
    # stack => {
    #    container => {
    #        "CPU" => ["100", "105", "200"],
    #        "MEMORY" => ["70", "7345", "3213"],
    #    }
    # }
    def monitor(service)
      # check all vms that forms a service

      data = {}
      service.stacks.each do |stack|
        data[stack] = {}

        stack.containers.each do |container|
          probes = monitor_container(container)
          data[stack][container] = collect_values(probes)
        end
      end

      data
    end

    def monitor_container(container)
      data = @cloud_provider.monitor_container container.id

      # filter out historical data
      # TODO normalize?
      data.merge(data){ |k, probes| last(probes, container) }
    end

    private
    # Maps container monitoring data to a form that doesn't have timestamps
    #
    # * *Args* :
    # - +data+ -> hashmap that contains monitoring data in form:
    # {
    #   "CPU" => [["1", "100"], ["5", "105"], ["10", "200"]],
    #   "MEMORY" => [["1", "70"], ["5", "7345"], ["10", "3213"]],
    # }
    #
    # Returns hashmap that consists values instead of pairs: []time_stamp, value]
    # {
    #   "CPU" => ["100", "105", "200"],
    #   "MEMORY" => ["70", "7345", "3213"],
    # }
    def collect_values(data)
      template = {}
      data.each do |key, probes|
        template[key] = probes.collect {|x| x[1]}
      end

      template
    end

    # Selects data from last time_stamp
    #
    # * *Args* :
    # - +data+ -> hashmap that contains monitoring data in form
    #   [["1374678040", "524288"], ["1374678083", "524288"], ["1374678113", "524288"], ["1374678155", "524288"]]
    # - +container+ -> container to which data corresponds (used to determine timestamp)
    def last(data, container)
      selection = data.select {|item| item[0].to_i > container.probed.to_i }
      container.probed = selection.last[0] if selection.last != nil
      container.save

      selection
    end

  end
end
