require 'rubygems'
require 'logger'
require 'set'

require 'models/models'

module AutoScaling
  class ContainerAnalyzer

    @@logger = Logger.new(STDOUT)

    def analyze(data)
      @@logger.debug "Analyzing data #{data}"

      conclusions = {}
      conclusions
    end

  end
end
