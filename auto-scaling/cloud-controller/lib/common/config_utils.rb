require 'yaml'

class ConfigUtils
  @@config = nil
  def self.load_config
    return @@config unless @config.nil?
    base_path   = "#{File.dirname(__FILE__)}/../../"
    config      = %w(
            ../config/config.yaml
            config/config.yaml
            ../config/config-default.yaml
            config/config-default.yaml
    ).map { |c| "#{base_path}/#{c}" }.detect { |c| File.exists?(c) }

    raise 'There is no config file!' if config.nil?

    environment = ENV['CLOUD_ENV'] || 'development'
    @@config    = environmentize(environment, YAML.load_file(config))
  end

  private
  def self.environmentize(environment, hash)
    if hash.has_key?(environment)
      to_merge = hash.delete(environment)
      hash.each_key { |key| hash.delete(key) }
      hash.merge!(to_merge)
    else
      hash.each_value { |v| environmentize(environment, v) if v.is_a?(Hash) }
    end
  end
end
