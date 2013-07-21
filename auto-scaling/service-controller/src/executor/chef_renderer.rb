require 'rubygems'
require 'json'

module AutoScaling

  # Class responsbile for rendering a chef configuration
  # that corresponds to internal model
  class ChefRenderer

    class JavaStack
      def self.render(stack)
        template = {
            :haproxy => {
              :members => [],
            },
            :run_list => ["recipe[haproxy]"]
        }

        stack.slaves.each do |container|
          template[:haproxy][:members] << {
              "hostname" => container.ip,
              "ipaddress" => container.ip
          }
        end

        template.to_json
      end
    end

    # Renders configuration
    def render(stack)
      # select appropriate renderer, depending on the type of a stack
      JavaStack.render(stack)
    end

  end
end
