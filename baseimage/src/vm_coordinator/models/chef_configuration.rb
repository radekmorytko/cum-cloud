$LOAD_PATH.unshift(File.dirname(File.expand_path('..', __FILE__)))

require 'logger'
load 'config/vm_coordinator.conf'

class ChefConfiguration
  @@logger = Logger.new("#{VM_COORDINATOR_LOG}/chef_configuration.log")

  attr_accessor :conf_template

  def prepare(config = {})
    config ||= {}
    config = DEFAULT_CHEF_CONFIG.merge(config)

    @conf_template = ConfigTemplate.new(
        config[:path],
        config[:path] + '/cookbooks',
        config[:path] + '/site_cookbooks',
        config[:path] + '/cache',
        File.join(config[:path], config[:filename]),
        File.join(config[:template_dir], config[:template_filename])
    )

    make_config_dirs
    move_cookbooks
    save_config_file
  end

  # checks standard locations for path to chef-solo
  def chef_solo
    %w(/usr/bin/chef-solo /usr/local/bin/chef-solo).each do |path|
      return path if File.exists? path
    end

    raise RuntimeError, 'chef-solo cannot be found'
  end

  private
  def make_config_dirs
    @@logger.debug('Making configuration directories')

    # prepend dirs with the root path
    [@conf_template.dir,  @conf_template.cache_path, @conf_template.cookbooks_path, @conf_template.site_cookbooks_path].each { |d|
      next if File.exist?(d)
      @@logger.debug("Directory: #{d}")
      FileUtils.mkdir_p(d)
    }
  end

  def move_cookbooks
    if !File.exists?(CONTEXT_COOKBOOKS_DIR)
      @@logger.debug("There are no cookbooks under: #{CONTEXT_COOKBOOKS_DIR}")
      return
    end

    @@logger.debug("Moving cookbooks from #{CONTEXT_COOKBOOKS_DIR} to: #{@conf_template.dir}")
    FileUtils.cp_r(CONTEXT_COOKBOOKS_DIR, @conf_template.dir)
  end

  def save_config_file
    @conf_template.save
  end
end

ConfigTemplate = Struct.new(
    :dir,
    :cookbooks_path,
    :site_cookbooks_path,
    :cache_path,
    :config_path,
    :template_filename) do
  def save
    FileUtils.mkdir_p(dir) unless File.exists?(dir)

    File.open(config_path, 'w') do |f|
      f.write(render)
    end
  end

  def render
    template_dir = File.dirname(File.expand_path('../templates', __FILE__))
    template_path = File.join(template_dir, template_filename)
    template_contents = File.read(template_path)

    ERB.new(template_contents).result(binding)
  end
end