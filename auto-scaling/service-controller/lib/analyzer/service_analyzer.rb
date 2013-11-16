require 'rubygems'
require 'logger'
require 'set'

require 'models/models'
require 'analyzer/threshold_model'

module AutoScaling
  class ServiceAnalyzer

    @@logger = Logger.new(STDOUT)

    def initialize(policy_evaluator)
      @policy_evaluator = policy_evaluator
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

        stack.policy_set.policies.each do |policy|
          containers.each do |container, metrics|

            metrics.each do |key, values|
              conclusion = @policy_evaluator.evaluate(policy, values)
              @@logger.debug "Concluded that currently #{container} is #{conclusion} (by key: #{key})"

              conclusions[stack] << conclusion
            end

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

  end
end
