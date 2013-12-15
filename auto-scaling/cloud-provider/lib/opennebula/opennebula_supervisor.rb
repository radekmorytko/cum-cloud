require 'rubygems'
require 'logger'

require 'net/ssh'

module AutoScaling
  class OpenNebulaSupervisor

    def initialize(options)
      @options = options
    end

    def monitor_host(host_name)
      Net::SSH.start(host_name, @options['username'], :password => @options['host_password']) do |ssh|
        output = ssh.exec!("/var/tmp/one/im/run_probes ovz")
        output = output.split(" ").inject({}) {|hsh, val| hsh[val.split("=")[0]] = val.split("=")[1]; hsh}

        # normalize data
        capacity = {}
        key_mapping = {'FREECPU' => :cpu, 'FREEMEMORY' => :memory}
        output.each do |probe_key, value|
          key = key_mapping[probe_key]
          next if key == nil
          capacity[key] = value.to_f
        end

        # maps resources to cpu percentage, memory to MB
        factors = {:cpu => 100.0, :memory => 1024.0}
        factors.each do |key, factor|
          capacity[key] /= factor
        end

        capacity
      end
    end

  end
end
