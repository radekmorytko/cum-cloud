require 'rubygems'
require 'bundler/setup'

require 'trollop'

COMMANDS = %w(deploy)

module Intercloud
  class CommandLineParser
    def self.parse
      Trollop::options do
        banner "Deploy an environment using `deploy`"
        stop_on COMMANDS
      end

      action = ARGV.shift
      arguments = nil
      case action
        when "deploy"
          o = Trollop::options do
            opt :environment, "Specification of an environment", :type => :string, :short => '-e'
          end
          arguments = o[:environment]
        else
          Trollop::die "Unknown command #{action.inspect}"
      end
      return  {:command => action.inspect.gsub('"', ''), :arguments => arguments }
    end
  end
end