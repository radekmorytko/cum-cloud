require 'rubygems'
require 'logger'

require 'OpenNebula'

include OpenNebula

module AutoScaling
  class OpenNebulaFrontend

    @@logger = Logger.new(STDOUT)

    def initialize(options)
      @client = ::OpenNebula::Client.new("#{options['username']}:#{options['password']}", options['endpoints']['opennebula'])
      @data = options['monitoring_keys']
    end

    def monitor(vm_id)
      vm = ::OpenNebula::VirtualMachine.new(VirtualMachine.build_xml(vm_id), @client)
      data = vm.monitoring(@data)

      raise RuntimeError(data.message) if OpenNebula.is_error?(data)
      data
    end

  end
end
