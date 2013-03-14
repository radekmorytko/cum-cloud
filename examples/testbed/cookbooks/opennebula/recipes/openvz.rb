#
# Cookbook Name:: backend
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "opennebula::common"

# datastore directory
one_username = node[:opennebula][:user]

directory "/vz/one/datastore" do
	owner one_username
	group one_username
	mode 00755
	recursive true
	action :create
end

# gems
%w( openvz systemu xml-mapping ).each do |gem|
	gem_package(gem) do
		gem_binary "gem"
	end
end

# bridge
package "bridge-utils"

bridge = node[:opennebula][:openvz][:bridge],
interface = node[:opennebula][:openvz][:interface]

interfaces = value_for_platform(
  "ubuntu" => { "default" => ['/etc/network/interfaces'] },
  "centos" => { "default" => ["/etc/sysconfig/network-scripts/ifcfg-#{bridge}", 
                              "/etc/sysconfig/network-scripts/ifcfg-#{interface}"] }
)

interfaces.each do |interface|
    template interface do
      source "#{interface.split('/')[-1]}.erb"
      variables(
        :bridge => node[:opennebula][:openvz][:bridge],
        :interface => node[:opennebula][:openvz][:interface]
      )
    end
    
    service "networking" do
        subscribes :restart, resources("template[#{interface}]"), :immediately
    end
end
