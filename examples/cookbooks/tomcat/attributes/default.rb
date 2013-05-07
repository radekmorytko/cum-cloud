#### tomcat variables
default[:tomcat][:ajp_port] = 8009
default[:tomcat][:jvm_route] = ENV['VM_NAME']

#### application-specific variables
default[:app][:name] = 'demoapp'

