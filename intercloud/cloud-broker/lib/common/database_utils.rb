require 'logger'
require 'common/config_utils'
require 'domain/domain'
require 'data_mapper'

class DatabaseUtils
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def self.initialize_database
    environment = ENV['RACK_ENV'] == 'test' ? 'test' : 'development'

    @@logger.info("Initializing database (#{environment} environment)")

    config = ConfigUtils.load_config
    database_filename = config[environment]['database']

    DataMapper::Logger.new(STDOUT, config[environment]['database-log-level'])
    DataMapper.setup(:default, "sqlite:#{database_filename}")
    DataMapper::Model.raise_on_save_failure = true
    DataMapper.finalize

    if ENV['RACK_ENV'] == 'test'
      DataMapper.auto_migrate!
    else
      DataMapper.auto_upgrade!
      #DataMapper.auto_migrate!
    end
  end
end
