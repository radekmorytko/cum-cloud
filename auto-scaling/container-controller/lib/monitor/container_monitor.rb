require 'rubygems'
require 'logger'
require 'set'

require 'domain/domain'

module AutoScaling
  class ContainerMonitor

    @@logger = Logger.new(STDOUT)

    def initialize(cloud_provider)
      @cloud_provider = cloud_provider
    end

    # Monitors a given container
    #
    # * *Args* :
    # - +container+ -> reference to a container. An instance of AutoScaling::Container class
    #
    # Returns hashmap that consists mapping containers => metrics, ex:
    # {
    #   "CPU" => ["100", "105", "200"],
    #   "MEMORY" => ["70", "7345", "3213"],
    # }
    def monitor(container)
      @@logger.debug "Monitoring a container #{container}"

      data = @cloud_provider.monitor_container container.correlation_id
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

      collect_values(result)
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
      data.select {|item| item[0].to_i > container.probed.to_i }
    end

  end
end
