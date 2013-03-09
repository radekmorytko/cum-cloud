#
# Cookbook Name:: backend
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "opennebula::common"

package "bridge-utils"

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

