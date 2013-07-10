$LOAD_PATH.unshift(File.dirname(File.expand_path('..', __FILE__)))

require 'erb'
require 'logger'
require 'fileutils'
require 'open-uri'
require 'base64'

load 'config/vm_coordinator.conf'

class ChefExecutor

  class Executor
    @@logger = Logger.new("#{VM_COORDINATOR_LOG}/chef_executor.log")

    def execute(command)
      @@logger.debug("Running command: #{command}")
      returned_val = system(command)
      @@logger.debug("Returned value: #{returned_val}, status #{$?}")

      returned_val
    end
  end

  # config: path to chef configuration
  # chef_solo: path to executable chef-solo
  def initialize(config, chef_solo)
    @config = config
    @executable = chef_solo
  end

  def run(node_object = {}, executor = nil)
    raise ArgumentError if node_object.nil? or !node_object.has_key?(:data) or !node_object.has_key?(:file)

    node_object = DEFAULT_TEMPLATE_CONFIG.merge(node_object)
    executor ||= Executor.new

    node_object_file = node_object[:file]
    node_object_contents = Base64::decode64(node_object[:data])
    create_node_object_file(node_object_file, node_object_contents)

    command = "#{@executable} -c #{@config} -j #{node_object_file} >> #{VM_COORDINATOR_LOG}/chef_executor.log 2>&1"

    executor.execute(command)
  end

  private

  def create_node_object_file(file, data)
    File.open(file, 'w') do |f|
      f.write(data)
    end
  end

end