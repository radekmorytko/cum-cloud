$: << '../../lib'

require 'rubygems'
require 'logger'

require 'OpenNebula'

include OpenNebula

module AutoScaling
  class OpenNebulaFrontend

    @@logger = Logger.new(STDOUT)

    def initialize(options)
      @client = ::OpenNebula::Client.new("#{options[:username]}:#{options[:password]}", options[:endpoint])
      @data = options[:monitoring_keys]
      @time_stamp = 0
    end

    def monitor(vm_id)
      vm = ::OpenNebula::VirtualMachine.new(VirtualMachine.build_xml(vm_id), @client)
      data = vm.monitoring(@data)

      raise RuntimeError(data.message) if OpenNebula.is_error?(data)
      data
    end

    private
    # example data
    # [["1374678040", "524288"], ["1374678083", "524288"], ["1374678113", "524288"], ["1374678155", "524288"]]
    def last(data)
      selection = data.select {|item| item[0].to_i > @time_stamp }
      @time_stamp = selection.last[0].to_i
      selection
    end

  end
end
