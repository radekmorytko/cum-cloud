require 'rubygems'
require 'logger'
require 'erb'
require 'htmlentities'
require 'nokogiri'
require 'ostruct'

module AutoScaling

  MonitorVmData = Struct.new(:vm_id)
  MonitorVm = Struct.new(:data)
  Template = Struct.new(:name)

  ListHostsData = Struct.new(:free_cpu, :free_memory)

  # Helper that is used to generate opennebula-like response
  class OpenNebulaGenerator

    def self.show_service(service)
      self.render(service, 'show_service.erb')
    end

    def self.show_vm(vm_template)
      self.render(vm_template, 'show_vm.erb')
    end

    def self.monitor_vm(monitor_vm_data)
      vm_data = self.render(monitor_vm_data, 'monitor_vm_data.erb')

      encoded_data = HTMLEntities.new.encode(vm_data)
      self.render(MonitorVm.new(encoded_data), 'monitor_vm.erb')
    end

    def self.template_info(template)
      self.render(template, 'template_info.erb')
    end

    def self.list_hosts(template)
      data = self.render(template, 'list_hosts_data.erb')

      encoded_data = HTMLEntities.new.encode(data)
      self.render(encoded_data, 'list_hosts.erb')
    end

    private
    def self.render(data, file_name)
      template_path = File.join(File.dirname(File.expand_path(__FILE__)), 'templates', file_name)
      template_erb = File.read(template_path)

      ERB.new(template_erb).result(OpenStruct.new(data).instance_eval { binding })
    end

  end
end
