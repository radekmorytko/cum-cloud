module AutoScaling
  class Utils
    def self.setup_database
      #DataMapper::Logger.new($stdout, :debug)
      DataMapper.setup(:default, 'sqlite::memory:')
      DataMapper.auto_migrate!
    end
  end
end