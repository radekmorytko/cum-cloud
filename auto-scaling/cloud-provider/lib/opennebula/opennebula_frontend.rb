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

      raise(RuntimeError, data.message) if OpenNebula.is_error?(data)
      data
    end

    # Instantiates container with given type and role, which are used
    # to determine its template id
    def instantiate_container(stack_type, container_role, service_id, mappings)
      @@logger.debug "Instantiating container: #{stack_type}, #{container_role}"

      # get template
      template_id = mappings['stacks'][stack_type][container_role]
      xml = OpenNebula::Template.build_xml(template_id)
      template = OpenNebula::Template.new(xml, @client)
      res = template.info

      # add required variables
      raise(RuntimeError, template.message) if OpenNebula.is_error?(res)
      t = add_required_variables(template, container_variables(service_id))

      # instantiate it
      xml = OpenNebula::VirtualMachine.build_xml()
      vm = OpenNebula::VirtualMachine.new(xml, @client)
      res = vm.allocate(t)
      raise(RuntimeError, res.message) if OpenNebula.is_error?(res)

      # get its configuration
      raise(RuntimeError, res.message) if OpenNebula.is_error?(vm.info)
      configuration = {}
      configuration[:id] = vm.id
      configuration[:ip] = extract_ip(vm.template_xml)

      @@logger.debug "Instantiated container: #{configuration}"

      configuration
    end

    def delete_container(container_id)
      vm = ::OpenNebula::VirtualMachine.new(VirtualMachine.build_xml(container_id), @client)
      data = vm.finalize

      raise(RuntimeError, data.message) if OpenNebula.is_error?(data)
      @@logger.debug "Deleted container: #{container_id}"
      data
    end

    def save_container(container_id, disk_id, image_name)
      vm = ::OpenNebula::VirtualMachine.new(VirtualMachine.build_xml(container_id), @client)
      data = vm.save_as(disk_id, image_name)

      raise(RuntimeError, data.message) if OpenNebula.is_error?(data)
      @@logger.debug "Saved container: #{container_id} as #{image_name}, id: #{data}"
      data
    end

    def shutdown_container(container_id)
      vm = ::OpenNebula::VirtualMachine.new(VirtualMachine.build_xml(container_id), @client)
      data = vm.shutdown

      raise(RuntimeError, data.message) if OpenNebula.is_error?(data)
      @@logger.debug "Shutdown container: #{container_id}"
      data
    end

    def image_name(image_id)
      image = ::OpenNebula::Image.new(Image.build_xml(image_id), @client)
      image.info
      data = image.name

      raise(RuntimeError, data.message) if OpenNebula.is_error?(data)
      data
    end

    def delete_image(image_id)
      image = ::OpenNebula::Image.new(Image.build_xml(image_id), @client)
      image.delete

      raise(RuntimeError, data.message) if OpenNebula.is_error?(data)
      @@logger.debug "Deleted image: #{image_id}"
      data
    end


    private
    # Extra variables that needs to be added to handle base image initialization
    def container_variables(service_id)
      { 'SERVICE_ID' => service_id, 'VM_ID' => '$VMID' }
    end

    # Modifies a template to add new variables
    def add_required_variables(template, variables)
      template_xpath = '/VMTEMPLATE/TEMPLATE'
      context_xpath = '/VMTEMPLATE/TEMPLATE/CONTEXT'
      template.add_element(template_xpath, 'CONTEXT' => nil) unless template.has_elements?(context_xpath)
      template.add_element(context_xpath, variables)

      template.element_xml(template_xpath)
    end

    def extract_ip(xml)
      doc = Nokogiri::XML(xml)
      cdata = doc.xpath("//IP").children[0]

      if cdata == nil
        nil
      else
        cdata.content
      end
    end

  end
end
