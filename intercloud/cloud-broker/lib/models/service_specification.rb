require 'data_mapper'
require 'common/config_utils'
require 'common/configurable'

class ServiceSpecification
  include DataMapper::Resource
  include Configurable

  #property :id,              Serial
  property :name,            String, :key => true, :required => true
  #property :broker_id,       String, :required => true, :default => ConfigUtils.load_config['broker_id']
  property :client_endpoint, String, :required => true
  property :created_at,      DateTime, :default => DateTime.now

  has n, :stacks

  def deployed?
    stacks.count > 0 and stacks.reduce(true) { |status, stack| stack.deployed? and status}
  end

  def ready_to_deploy?
    (not deployed?)  and
    stacks.count > 0 and
    stacks.reduce(false) { |status, stack| stack.ready_to_deploy? or status}
  end
end
