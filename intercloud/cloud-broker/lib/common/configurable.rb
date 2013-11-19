require 'common/config_utils'

module Configurable
  def config
    @config ||= ConfigUtils.load_config
  end
end

