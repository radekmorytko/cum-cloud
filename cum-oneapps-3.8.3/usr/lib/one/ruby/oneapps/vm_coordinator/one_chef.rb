require 'erb'
require 'logger'
require 'fileutils'
require 'open-uri'
require 'base64'

class OneChef

  @@logger = Logger.new('/tmp/chef.log')

  DEFAULT_CHEF_CONFIG = {
      :path => '/tmp/chef',
      :filename => 'chef.conf',
      :template_filename => 'chef.conf.erb'
  }

  DEFAULT_TEMPLATE_CONFIG = {
      :file => '/tmp/chef/node.json'
  }

  def run(args = {})
    args[:config] ||= {}
    args[:config].merge!(DEFAULT_CHEF_CONFIG)
    args[:node_object].merge!(DEFAULT_TEMPLATE_CONFIG)

    @conf_template = ConfigTemplate.new(
        args[:config][:path],
        args[:config][:path] + '/cookbooks', # :cookbook_path
        args[:config][:path] + '/site_cookbooks', # :site_cookbooks_path
        args[:config][:path] + '/cache', # :cache_path
        args[:config][:filename],
        args[:config][:template_filename]
    )

    prepare_configuration
    prepare_cookbooks(args[:cookbooks_url]) if args[:cookbooks_url]

    node_object_file = args[:node_object][:file]
    node_object_contents = Base64::decode64(args[:node_object][:data])
    create_node_object_file(node_object_file, node_object_contents)

    command = "/usr/local/bin/chef-solo -c #{File.join('/', @conf_template.path, @conf_template.filename)} " <<
              "-j #{node_object_file} 2>&1 >> /var/log/chef-system-out.log"

    @@logger.debug("Running command: #{command}")

    returned_val = system(command)

    @@logger.debug("Returned value: #{returned_val}, status #{$?}")

  end

  private

  def prepare_cookbooks(cookbooks_url)
    @@logger.debug('Preparing cookbooks')
    downloaded_file = download_cookbooks(cookbooks_url)
    command = "tar xzf #{downloaded_file} -C #{@conf_template.cookbooks_path}"
    @@logger.debug("Extracting cookbooks by running command: #{command}")
    returned_val = system(command)
    @@logger.debug("Returned val: #{returned_val}")
  end

  def download_cookbooks(cookbooks_url)
    @@logger.debug('Downloading cookbooks')
    tmp_cookbook = @conf_template.path + '/tmp_cookbooks.tar.gz'
    File.open(tmp_cookbook, 'wb') do |saved_file|
      open(cookbooks_url, 'rb') do |read_file|
        saved_file.write(read_file.read)
      end
      @@logger.debug("Saved file #{tmp_cookbook}")
    end
    tmp_cookbook
  end

  def prepare_configuration
    make_config_dirs
    save_config_file
  end

  def make_config_dirs
    @@logger.debug('Making configuration directories')
    # prepend dirs with the root path
    [@conf_template.path,
       @conf_template.cache_path,
       @conf_template.cookbooks_path,
       @conf_template.site_cookbooks_path].each { |d|
      @@logger.debug("Directory: #{d}")
      FileUtils.mkdir_p(d) unless File.exist?(d)
    }
  end

  def save_config_file
    @conf_template.save
  end

  def create_node_object_file(file, data)
    File.open(file, 'w') do |f|
      f.write(data)
    end
  end

  ConfigTemplate = Struct.new(
      :path,
      :cookbooks_path,
      :site_cookbooks_path,
      :cache_path,
      :filename,
      :template_filename) do
    def save
      config_filename = File.join('/', path, filename)
      FileUtils.mkdir_p(path) unless File.exists?(path)
      File.open(config_filename, 'w') do |f|
        f.write(render)
      end
    end

    def render
      current_dir = File.dirname(File.expand_path('.', __FILE__))
      template_path = File.join('/', current_dir, template_filename)
      template_contents = File.read(template_path)
      ERB.new(template_contents).result(binding)
    end
  end
end