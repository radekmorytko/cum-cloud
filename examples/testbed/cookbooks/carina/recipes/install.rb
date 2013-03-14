# packages
package "libmysqlclient-dev"
package "ruby"
package "rubygems"
package "unzip"
package "ruby-dev"

# gems
%w( sinatra mysql json rest-client redis ).each do |gem|
	gem_package(gem) do
		gem_binary "gem"
	end
end

# install carina
carina_user = node[:carina][:user]
carina_home = node[:carina][:home]
carina_password = node[:carina][:password]

# a. add carina user
user carina_user do
	password carina_password
	home carina_home
	shell "/bin/bash"
	supports :manage_home => true
	action :create
end

# b. create one directory
one_directory = node[:carina][:one_directory]

directory one_directory do
	owner carina_user
	group carina_user
	mode 00755
	recursive true
end

# c. download, unpack to home and install opennebula client commands
opennebula_archive "opennebula-3.6.0" do
	url "opennebula-3.6.0.tar.gz"
	owner carina_user
	group carina_user
	
	cwd "/tmp/opennebula-3.6.0/" 
	command "./install.sh -c -d #{one_directory}"
	creates "#{one_directory}/bin"
	
	action :install
end

# d. download and unpack carina
carina_directory = node[:carina][:directory]

opennebula_archive "opennebula-carina" do
	url "https://github.com/blackberry/OpenNebula-Carina/archive/master.zip"
	owner carina_user
	group carina_user
	
	type "zip"
	
	cwd "/tmp/OpenNebula-Carina-master"
	creates "#{carina_directory}"
	command "mv /tmp/OpenNebula-Carina-master #{one_directory}/opennebula-carina"
	
	action :install
end
