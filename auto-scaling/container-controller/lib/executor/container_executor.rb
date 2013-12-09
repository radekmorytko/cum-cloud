require 'rubygems'
require 'logger'
require 'set'

require 'domain/domain'

module AutoScaling
  class ContainerExecutor

    @@logger = Logger.new(STDOUT)

    def initialize(cloud_provider)
      @cloud_provider = cloud_provider
    end

  end
end
