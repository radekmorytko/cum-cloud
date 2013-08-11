require 'rubygems'
require 'logger'
require 'erb'
require 'htmlentities'
require 'nokogiri'

module AutoScaling

  ShowService = Struct.new(:service_id, :state, :master_id, :master_ip, :slave_id, :slave_ip)
  ShowVm = Struct.new(:vm_id, :ip)

  MonitorVmData = Struct.new(:vm_id)
  MonitorVm = Struct.new(:data)
  Template = Struct.new(:name)

  # Helper that is used to generate opennebula-like response
  class OpenNebulaGenerator

    def self.show_service(service_template)
      self.render(service_template, 'show_service.erb')
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

    private
    def self.render(template, file_name)
      template_path = File.join(File.dirname(File.expand_path(__FILE__)), 'templates', file_name)
      template_erb = File.read(template_path)

      ERB.new(template_erb).result(template.send(:binding))
    end

  end
end
