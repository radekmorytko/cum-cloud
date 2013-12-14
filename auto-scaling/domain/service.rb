require 'rubygems'
require 'json'
require 'data_mapper'

require 'common/configurable'

module AutoScaling
  class Service
    @@logger       = Logger.new(STDOUT)
    @@logger.level = Logger::DEBUG

    include DataMapper::Resource
    include Configurable

    property :name, String, :key => true, :unique => true
    property :autoscaling_queue_name, String, :required => true

    after :save, :notify_observer_process

    has n, :stacks

    def to_s
      JSON.pretty_generate(self)
    end

    def deployed?
      return false if stacks.empty?
      stacks.reduce(true) { |acc, s| acc and s.state == :deployed }
    end

    # This method is used in an integration test where it
    # sends USR1 signal to the test-runner process
    def notify_observer_process
      return if not deployed? or
                not (config.has_key?('test-cases') and
                     config['test-cases'].has_key?(['runner-pid']) and
                     not config['test-cases']['runner-pid'].nil?)

      pid_to_notify = config['test-cases']['runner-pid']

      @@logger.debug("Notifying process #{pid_to_notify} about the deployed service")

      Process.kill('USR1', pid_to_notify)
    end

  end
end
