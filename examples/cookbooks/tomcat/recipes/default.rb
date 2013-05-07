#
# Cookbook Name:: tomcat
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#package "openjdk-7-jdk"
package "tomcat6"

service "tomcat6" do
  supports :restart => true
  action :enable
end

template "/etc/tomcat6/server.xml" do
  source "server.xml.erb"
  owner "root"
  group "root"
  variables({
     :jvm_route => node[:tomcat][:jvm_route],
     :ajp_port => node[:tomcat][:ajp_port]
  })
  notifies :restart, 'service[tomcat6]'
end

demoapp_src = "/var/lib/tomcat6/webapps/demoapp.war"
demoapp_url = "http://student.agh.edu.pl/~rmorytko/cookbooks/demoapp.war"
remote_file demoapp_src  do
  source "http://student.agh.edu.pl/~rmorytko/cookbooks/demoapp.war"
  not_if { ::File.exists?(demoapp_src) } 
end

