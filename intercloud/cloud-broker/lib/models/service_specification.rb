require 'data_mapper'
require 'dm-validations'
require 'common/config_utils'
require 'common/configurable'

class ServiceSpecification
  include DataMapper::Resource
  include Configurable

  property :id,              Serial
  property :status,          Enum[:scheduled, :failed, :deployed], :default => :scheduled
  property :broker_id,       String, :required => true, :default => ConfigUtils.load_config['broker_id']
  property :specification,   Json, :required => true
  property :client_endpoint, String, :required => true
  property :deployed,        Boolean, :default => false
  property :created_at,      DateTime, :default => DateTime.now

  has n, :offers

  def ready_to_deploy?
    not deployed? and deployment_criteria_satisfied?
  end

  def deployed?
    deployed
  end

  private 
  def deployment_criteria_satisfied?
    offers.count > 0 and
    # 86400 = 24*60*60 -> # seconds in a day
    (DateTime.now - offers.max_by { |o| o.received_at }.received_at).to_f * 86400 > config['resource_mapping']['offers_wait_interval'] 
  end
end
