require 'rubygems'
require 'logger'
require 'set'

require 'models/models'
require 'analyzer/threshold_model'

module AutoScaling
  class ServiceAnalyzer

    @@logger = Logger.new(STDOUT)

    def initialize(model)
      @model = model
    end

    # Analyzes data using supplied model
    #
    # * *Args* :
    # - +data+ -> hashmap that contains monitoring data in form:
    # stack => {
    #    container => {
    #        "CPU" => ["100", "105", "200"],
    #        "MEMORY" => ["70", "7345", "3213"],
    #    }
    # }
    #
    # Returns hashmap that contains conclusions about supplied data, correlated with
    # appropriate stack, ex:
    #
    # stack => [:insufficient_slaves, :overloaded_master]
    #
    def analyze(data)
      @@logger.debug "Analyzing data #{data}"

      conclusions = {}

      # analyze all stacks
      data.each do |stack, containers|
        # we are interested only in unique problems
        conclusions[stack] = Set.new
        containers.each do |container, metrics|

          metrics.each do |key, values|
            conclusion = analyze_values(container, values)
            @@logger.debug "Concluded that currently #{container} is #{conclusion} (by key: #{key})"

            conclusions[stack] << conclusion
          end

        end
      end

      # filter out healthy conclusions if there were some issues
      # TODO analyze here global problems
      conclusions.each do |stack, issues|
        issues.delete(:healthy) if issues.size > 1
      end

      conclusions
    end

    private
    def analyze_values(container, probes)
      result = @model.analyze(probes)

      @@logger.debug "Model claims that: #{result} (container: #{container}, probes: #{probes}"

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

      role = container.master? ? :master : :slave
      conclusion = mappings[role][result]

      return conclusion
    end


  end
end
