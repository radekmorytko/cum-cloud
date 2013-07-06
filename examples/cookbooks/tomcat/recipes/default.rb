#
# Cookbook Name:: tomcat
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "tomcat6"
service "tomcat6"

template "/etc/tomcat6/server.xml" do
  source "server.xml.erb"
end

demoapp_src = "/var/lib/tomcat6/webapps/demoapp.war"
remote_file demoapp_src  do
  mode '404'
  source "http://student.agh.edu.pl/~cdariusz/pp/demoapp.war"
  not_if { ::File.exists?(demoapp_src) } 
end

