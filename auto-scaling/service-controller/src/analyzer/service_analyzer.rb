require 'rubygems'
require 'logger'
require 'models/models'

module AutoScaling
  class ServiceAnalyzer

    attr_reader :conclusions

    CONCLUSIONS = [
      :insufficient_slaves,
      :overloaded_master,
      :healthy
    ]

    def analyze(service, data)
      conclusions = {}

      data.each do |container_id, metrics|
        metrics.each do |key, probes|
          conclusions[container_id] = analyze_probes(container_id, key, probes)
        end
      end

      conclusions
    end

    private
    def analyze_probes(container_id, key, probes)
      healthy = probes.all? {|probe| probe[1].to_i < 50}
      return :healthy if healthy

      # master?
      container = Container.get(container_id)
      return :overloaded_master if container.master?

      # if not then slave suck
      :insufficient_slaves
    end


  end
end
