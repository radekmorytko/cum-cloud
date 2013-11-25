require 'data_mapper'
require 'common/configurable'

class Stack
  include DataMapper::Resource
  include Configurable

  property :id,            Serial
  property :type,          String, :required => true
  property :instances,     Integer, :required => true
  property :status,        Enum[:initialized, :failed, :deployed], :default => :initialized

  # cloud id where it is deployed at
  property :controller_id, String

  belongs_to :service_specification

  has n, :offers

  def deployed?
    status == :deployed
  end

  def ready_to_deploy?
    not deployed? and deployment_criteria_satisfied?
  end

  private 
  def deployment_criteria_satisfied?
    offers.count > 0 and
    # 86400 = 24*60*60 -> # seconds in a day
    (DateTime.now - offers.max_by { |o| o.received_at }.received_at).to_f * 86400 > config['resource_mapping']['offers_wait_interval'] 
  end
end

