ONE_LOCATION = ENV["ONE_LOCATION"]

if ONE_LOCATION
  VAR_LOCATION = ONE_LOCATION + "/var"
  LOG_LOCATION = ONE_LOCATION + "/var"
  ETC_LOCATION = ONE_LOCATION + "/etc"
  RUBY_LIB_LOCATION = ONE_LOCATION+"/lib/ruby"
else
  LOG_LOCATION = "/var/log/one"
  VAR_LOCATION = "/var/lib/one"
  ETC_LOCATION = "/etc/one"
  RUBY_LIB_LOCATION = "/usr/lib/one/ruby"
end

APPFLOW_AUTH    = VAR_LOCATION + "/.one/appflow_auth"

APPFLOW_LOG        = LOG_LOCATION + "/appflow-server.log"
CONFIGURATION_FILE = ETC_LOCATION + "/appflow-server.conf"
