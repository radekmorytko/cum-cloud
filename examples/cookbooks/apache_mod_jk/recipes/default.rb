#
# Cookbook Name:: apache_mod_jk
# Recipe:: default
#

package "libapache2-mod-jk"

template "/etc/libapache2-mod-jk/workers.properties" do
  source "workers.properties.erb"
  owner "root"
  group "root"
  variables({
     :tomcat_workers => node[:mod_jk][:tomcat_workers],
     :loadbalancer => node[:mod_jk][:loadbalancer],
  })
  #notifies :restart, 'service[apache2]'
end

template "/etc/apache2/mods-available/jk.conf" do
  source "jk.conf.erb"
  owner "root"
  group "root"
  variables({
     :app_name => node[:app][:name],
     :workers => node[:mod_jk][:workers]
  })
  #notifies :restart, 'service[apache2]'
end


