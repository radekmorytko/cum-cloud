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

# oneadmin user
one_username = node[:opennebula][:user]
one_password = node[:opennebula][:password]
one_home = node[:opennebula][:home]

user one_username do
	uid 1001
	password one_password
	home one_home
	shell "/bin/bash"
	supports :manage_home => true
	action :create
end

# ssh keys
execute "generate ssh skys for #{one_username}." do
	user one_username
	creates "#{one_home}/.ssh/id_rsa.pub"
	command "ssh-keygen -t rsa -q -f #{one_home}/.ssh/id_rsa -P \"\""
	only_if { ::File.exists?("#{one_home}")}
end
