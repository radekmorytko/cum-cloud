#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "ruby"
package "rubygems"
package "unzip"
package "screen"
package "wget"
execute "wget -P /etc/yum.repos.d http://download.gluster.org/pub/gluster/glusterfs/LATEST/CentOS/glusterfs-epel.repo"

package "glusterfs"

# oneadmin user
one_username = node[:opennebula][:user]
one_password = node[:opennebula][:password]
one_home = node[:opennebula][:home]
one_uid = node[:opennebula][:uid]

user one_username do
	uid one_uid
	password one_password
	home one_home
	shell "/bin/bash"
	supports :manage_home => true
	action :create
end

directory "#{one_home}/.ssh" do
	owner one_username
	group one_username
	mode 00700
	recursive true
	action :create
end

# ssh keys
execute "generate ssh skys for #{one_username}" do
	creates "#{one_home}/.ssh/id_rsa.pub"
	command "ssh-keygen -t rsa -q -f #{one_home}/.ssh/id_rsa -P \"\""
	only_if { ::File.exists?("#{one_home}")}
end

execute "chown -R #{one_username}:#{one_username} #{one_home}/.ssh"
