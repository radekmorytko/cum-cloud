require 'yaml'

class ConfigUtils
  @@config = nil
  def self.load_config
    return @@config unless @config.nil?
    config = %w(
            ../config/config.yaml
            config/config.yaml
            ../config/config-default.yaml
            config/config-default.yaml
    ).detect { |c| File.exists?(c) }

    raise 'There is no config file!' if config.nil?
    @@config = YAML.load_file(config)
  end
end
