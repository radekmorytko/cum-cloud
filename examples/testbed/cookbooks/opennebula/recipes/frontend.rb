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

# opennebula package, delivered as deb
opennebula_pkg_name = 'Ubuntu-12.04-opennebula_3.6.0-1_amd64.deb'
opennebula_pkg_dst = "/var/chef/cache/#{opennebula_pkg_name}"

cookbook_file opennebula_pkg_dst do
	source opennebula_pkg_name
	owner "root"
	group "root"
	mode "0444"
end

package opennebula_pkg_name do
	provider Chef::Provider::Package::Dpkg
	source opennebula_pkg_dst
	action :install
end

# opennebula configuration
cookbook_file "/etc/one/oned.conf" do
	source "oned.conf"
	owner "root"
	group "root"
end

# install openvz drivers
remote_file "/var/chef/cache/one-ovz.zip" do
  source "https://github.com/dchrzascik/one-ovz-driver/archive/master.zip"
  mode "0444"
end

execute "unpack drivers" do
	user "oneadmin"
	command "unzip /var/chef/cache/one-ovz.zip -d /tmp"
	not_if { ::File.exists?("/tmp/one-ovz-driver-master/")}
end

execute "install drivers" do
	user "root"
	command "cd /tmp/one-ovz-driver-master/ && rake install"
	not_if { ::File.exists?("/var/lib/one/remotes/vmm/ovz")}
end
