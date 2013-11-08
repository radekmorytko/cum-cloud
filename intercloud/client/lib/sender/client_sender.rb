require 'exceptions'

module Intercloud
  class ClientSender # decorator
    include Sender

    def initialize(component)
      @component = component
    end

    def send(url, msg)
      response = @component.send(url, msg)
      raise DeploymentFailed unless response.code.to_i == 200
      response.body.to_i
    end

    def get_info(url, msg)
      response = @component.get_info(url, msg)
      JSON.parse(response.body)
    end

    def prepare_deploy_message(data_source, body)
      # lower layer responsible for generating headers
      msg      = @component.prepare_deploy_message(data_source, body)
      msg.body = JSON.generate(body)
      msg
    end

    def prepare_check_status_message(data_source)
      @component.prepare_check_status_message(data_source)
    end

  end
end