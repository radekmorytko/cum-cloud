require 'logger'
require 'analyzer/threshold_model'

module AutoScaling
  class PolicyEvaluator

    @@logger = Logger.new(STDOUT)

    def evaluate(policy, container, values)
      # instantiate model that corresponds to policy
      model_name = get_model_name(policy.name)
      clazz = "AutoScaling::#{model_name}".split('::').inject(Object) {|o,c| o.const_get c}
      model = clazz.new(policy.parameters)

      # evaluate results
      result = model.analyze(values)
      @@logger.debug "Model #{model_name} claims that: #{result} (container: #{container}, probes: #{values}"

      # map model results
      mappings = @@mappings[policy.name.to_sym]
      role = container.master? ? :master : :slave
      mappings[role][result]
    end

    private
    @@mappings = {
      :threshold_model => {
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
    }

    # Coverts a model_name, written in 'C' notation to a camelcase one
    def get_model_name(model_name)
      model_name.split('_').map(){|it| it[0].upcase + it[1, it.length]}.join()
    end

  end
end
