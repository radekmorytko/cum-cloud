require 'exceptions'

module Intercloud
  class ClientSender # decorator
    include Sender

    def initialize(component)
      @component = component
    end

    def send(msg)
      response = @component.send(msg)
      raise DeploymentFailed unless response.code.to_i == 200
      response.body.to_i
    end

    def prepare_deploy_message(data_source, body)
      # lower layer responsible for generating headers
      msg      = @component.prepare_deploy_message(data_source, body)
      msg.body = JSON.generate(body)
      msg
    end

  end
end