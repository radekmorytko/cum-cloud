require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'models/chef_configuration'

class ChefConfigurationTest < Test::Unit::TestCase
  TMP_DIR = 'tmp'

  def setup
    @configuration = ChefConfiguration.new "./#{TMP_DIR}/log"
  end

  def teardown
    FileUtils.remove_dir TMP_DIR, :true
  end

  def test_if_prepares_configuration
    path = "#{TMP_DIR}/config"

    config = {
        :path => path
    }

    @configuration.prepare(config)

    # check directiores
    [path, path + '/cookbooks', path + '/site_cookbooks', path + '/cache'].each do |dir|
      assert(File.directory? dir)
    end

    # check chef configuration
    File.exists? path + "/chef.conf"
  end
end