require 'ostruct'
require 'json'
require 'client/configurable'

class RestMessagePreparer
  include Configurable

  def prepare_deploy_message(service_specification)
    OpenStruct.new(
      :body => JSON.generate(service_specification),
      :headers => {
        'CLIENT_ENDPOINT' => "#{config['endpoint']['host']}:#{config['endpoint']['port']}",
        'Accept' => 'application/json'
      }
    )
  end
end
