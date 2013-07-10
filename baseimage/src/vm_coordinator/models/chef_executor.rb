$LOAD_PATH.unshift(File.dirname(File.expand_path('..', __FILE__)))

require 'erb'
require 'logger'
require 'fileutils'
require 'open-uri'
require 'base64'

load 'config/vm_coordinator.conf'

class ChefExecutor

  class Executor
    def initialize(log_dir = nil)
      log_dir ||= VM_COORDINATOR_LOG
      FileUtils.mkdir_p(log_dir) unless File.exist?(log_dir)

      # initialize logger lazily
      @@logger = Logger.new("#{log_dir}/chef-executor.log")
    end

    def execute(command)
      @@logger.debug("Running command: #{command}")
      returned_val = system(command)
      @@logger.debug("Returned value: #{returned_val}, status #{$?}")

      returned_val
    end
  end

  def initialize(config)
    @config = config
  end

  def run(node_object = {}, executor = nil)
    raise ArgumentError if node_object.nil? or !node_object.has_key?(:data) or !node_object.has_key?(:file)

    node_object = DEFAULT_TEMPLATE_CONFIG.merge(node_object)
    executor ||= Executor.new

    node_object_file = node_object[:file]
    node_object_contents = Base64::decode64(node_object[:data])
    create_node_object_file(node_object_file, node_object_contents)

    command = "#{chef_solo} -c #{@config[:file]} -j #{node_object_file} >> /var/log/chef-system-out.log 2>&1"

    executor.execute(command)
  end

  private

  def create_node_object_file(file, data)
    File.open(file, 'w') do |f|
      f.write(data)
    end
  end

  # checks standard locations for path to chef-solo
  def chef_solo
    # TODO fix this issue in a different way
    # TODO add exception if not found

    %w(/usr/bin/chef-solo /usr/local/bin/chef-solo).each do |path|
      return path if File.exists? path
    end
  end

end