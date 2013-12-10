require 'rubygems'
require 'logger'
require 'set'

require 'domain/domain'

module AutoScaling
  class ContainerAnalyzer

    @@logger = Logger.new(STDOUT)

    @@mappings = {
      :threshold_model => {
        :master => {
            :greater => :insufficient,
            :lesser => :redundant,
            :fits => :healthy
        },

        :slave => {
            :greater => :insufficient,
            :lesser => :redundant,
            :fits => :healthy
        }
      }
    }

    def initialize(policy_evaluator)
      @policy_evaluator = policy_evaluator
    end

    # Analyzes data using supplied model
    #
    # * *Args* :
    # - +data+ -> hashmap that contains monitoring data in form:
    #  {
    #    :container => container,
    #    :metrics => {
    #       "CPU" => ["100", "105", "200"],
    #       "MEMORY" => ["70", "80", "90"],
    #    }
    #  }
    #
    # Returns hashmap that contains conclusions about supplied data
    #
    # [:insufficient_cpu, :insufficient_memory]
    #
    def analyze(data)
      @@logger.debug "Analyzing data #{data}"

      conclusions = Set.new
      container = data[:container]
      policies = container.stack.policy_set.policies

      policies.each do |policy|
        data[:metrics].each do |key, values|
          conclusion = @policy_evaluator.evaluate(policy, container, values, @@mappings)
          @@logger.debug "Concluded that currently #{container} is #{conclusion} (by key: #{key})"

          next if conclusion == :healthy

          conclusions << (conclusion.to_s + '_' + key.downcase).to_sym
        end
      end

      conclusions
    end

    def mappings
      @@mappings
    end

  end
end
