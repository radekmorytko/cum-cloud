require 'sinatra'

class ClientEndpoint < Sinatra::Base
  use Rack::CommonLogger
  post '/service' do
    "Hello World"
  end
end
