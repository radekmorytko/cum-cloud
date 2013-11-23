require 'yaml'

class ConfigUtils
  @@config = nil
  def self.load_config
    return @@config unless @config.nil?
    base_path = "#{File.dirname(__FILE__)}/../../"
    config = %w(
            ../config/config.yaml
            config/config.yaml
            ../config/config-default.yaml
            config/config-default.yaml
    ).map { |c| "#{base_path}/#{c}" }.detect { |c| File.exists?(c) }

    raise 'There is no config file!' if config.nil?
    @@config = YAML.load_file(config)
  end
end
