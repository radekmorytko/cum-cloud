require 'rubygems'
require 'bundler/setup'

require 'trollop'

COMMANDS = %w(deploy info)

module Intercloud
  class CommandLineParser
    def self.parse
      Trollop::options do
        banner "Deploy an environment using `deploy -e <env spec>` or show env info using `info -s <service id>`"
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
        when "info"
          o = Trollop::options do
            opt :'service-id', "Service ID", :type => :string, :short => '-s'
          end
          arguments = o[:'service-id']
        else
          Trollop::die "Unknown command #{action.inspect}"
      end
      return  {:command => action.inspect.gsub('"', ''), :arguments => arguments }
    end
  end
end