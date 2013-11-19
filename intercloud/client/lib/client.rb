require 'client/version'
require 'client/cloud_broker'

class Client
  def initialize(cloud_broker, database)
    @cloud_broker = cloud_broker
    @database     = database
  end
  def deploy(service_specification)
    service_id = @cloud_broker.deploy(service_specification)
    @database.set(service_id, 'deployed')
  end
end

