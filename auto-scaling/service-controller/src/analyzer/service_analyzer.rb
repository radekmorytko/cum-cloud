require 'rubygems'
require 'logger'

require 'models/models'
require 'analyzer/threshold_model'

module AutoScaling
  class ServiceAnalyzer

    @@logger = Logger.new(STDOUT)

    attr_reader :conclusions

    CONCLUSIONS = [
      # efficiency problems
      :insufficient_slaves,
      :overloaded_master,

      # underutilized
      :redundant,

      # normal
      :healthy
    ]

    def initialize(model)
      @model = model
    end

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
      result = @model.analyze(probes)

      # TODO move mappings to model?
      mappings = {
          :master => {
              :greater => :overloaded_master,
              :lesser => :healthy,
              :fits => :healthy
          },

          :slave => {
              :greater => :insufficient_slaves,
              :lesser => :redundant,
              :fits => :healthy
          }
      }

      role = Container.get(container_id).master? ? :master : :slave
      conclusion = mappings[role][result]

      @@logger.debug "Concluded that currently #{container_id} is #{conclusion} (by key: #{key}"
      return conclusion
    end


  end
end
