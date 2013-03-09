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
username = "oneadmin"
user username do
	uid 1001
	password "$1$kT4MVlr0$TaA8mP96az6.7Eb7.7K3Y/"
	home "/home/#{username}"
	shell "/bin/bash"
	supports :manage_home => true
	action :create
end

# ssh keys
execute "generate ssh skys for #{username}." do
	user username
	creates "/home/#{username}/.ssh/id_rsa.pub"
	command "ssh-keygen -t rsa -q -f /home/#{username}/.ssh/id_rsa -P \"\""
end
