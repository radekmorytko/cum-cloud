module AutoScaling
  class Utils
    def self.setup_database
      #DataMapper::Model.raise_on_save_failure = true
      DataMapper::Logger.new($stdout, ENV['CLOUD_ENV'] == 'test' ? :debug : :info)
      DataMapper.setup(:default, 'sqlite::memory:')
      DataMapper.auto_migrate!
    end
  end
end
