#
# Cookbook Name:: frontend
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "opennebula::common"

# depdendency for openvz-one
package "rake"

# depdencies for opennebula deb package
package "apg"
package "genisoimage"
package "libmysqlclient18"
package "libxmlrpc-c++4"
package "libxmlrpc-core-c3"
package "ruby-json"
package "ruby-sinatra"
package "thin1.8"
package "lvm2"
package "ruby-mysql"
package "ruby-password"
package "ruby-sequel"
package "ruby-sqlite3"

# opennebula package, delivered as a file
opennebula_pkg_name = value_for_platform(
  "ubuntu" => { "default" => 'Ubuntu-12.04-opennebula_3.6.0-1_amd64.deb' },
  "centos" => { "default" => 'CentOS-6.2-opennebula-3.6.0-1.x86_64.rpm' }
)

package_provider = value_for_platform(
  "ubuntu" => { "default" => Chef::Provider::Package::Dpkg },
  "centos" => { "default" => Chef::Provider::Package::Yum }
)

opennebula_pkg_dst = "/var/chef/cache/#{opennebula_pkg_name}"

cookbook_file opennebula_pkg_dst do
	source opennebula_pkg_name
	mode "0444"
end

package opennebula_pkg_name do
	provider package_provider
	source opennebula_pkg_dst
	action :install
end

# opennebula configuration
template "/etc/one/oned.conf" do
  source "oned.conf.erb"
  mode "0774"
end

# install openvz drivers
one_username = node[:opennebula][:user]

opennebula_archive "one-ovz-driver" do
	url "https://github.com/dchrzascik/one-ovz-driver/archive/master.zip"
	type "zip"
	owner "root"
	group "root"
	
	cwd "/tmp/one-ovz-driver-master/" 
	command "rake install"
	creates "/var/lib/one/remotes/vmm/ovz"
	
	action :install
end
