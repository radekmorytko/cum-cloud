require 'rubygems'
require 'logger'

require 'OpenNebula'

include OpenNebula

module AutoScaling
  class OpenNebulaFrontend

    @@logger = Logger.new(STDOUT)

    def initialize(options)
      @@logger.debug "Using credentials: #{options}"

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
    def instantiate_container(stack_type, container_role, mappings)
      @@logger.debug "Instantiating container: #{stack_type}, #{container_role}"

      # get template
      template_id = mappings['stacks'][stack_type][container_role]
      xml = OpenNebula::Template.build_xml(template_id)
      template = OpenNebula::Template.new(xml, @client)
      res = template.info

      # add required variables
      raise(RuntimeError, res.message) if OpenNebula.is_error?(res)
      t = add_required_variables(template, container_variables())

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

    def image_name(image_id)
      image = ::OpenNebula::Image.new(Image.build_xml(image_id), @client)
      image.info
      data = image.name

      raise(RuntimeError, data.message) if OpenNebula.is_error?(data)
      data
    end

    # Returns capacity of an opennebula
    def capacity
      host_pool = ::OpenNebula::HostPool.new(@client)
      data = host_pool.monitoring( ['HOST_SHARE/FREE_CPU', 'HOST_SHARE/FREE_MEM'] )
      raise(RuntimeError, data.message) if OpenNebula.is_error?(data)

      capacity = {:cpu => 0, :memory => 0}
      key_mapping = {'HOST_SHARE/FREE_CPU' => :cpu, 'HOST_SHARE/FREE_MEM' => :memory}
      data.each do |host_id, host|
        host.each do |probe_key, probes|
          key = key_mapping[probe_key]
          capacity[key] += probes.last[1].to_i
        end
      end

      # maps resources to cpu percentage, memory to MB
      factors = {:cpu => 100.0, :memory => 1024.0}
      factors.each do |key, factor|
        capacity[key] /= factor
      end

      @@logger.debug "Got capacity aggregated into #{capacity}"

      capacity
    end

    private
    # Extra variables that needs to be added to handle base image initialization
    def container_variables()
      { 'VM_ID' => '$VMID' }
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
