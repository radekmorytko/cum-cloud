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
directory "/vz/one/datastore" do
	owner "oneadmin"
	group "oneadmin"
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

