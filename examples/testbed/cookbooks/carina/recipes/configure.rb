# configure carina's bash
carina_user = node[:carina][:user]
carina_home = node[:carina][:home]

ruby_block "include .one_env" do
    block do
        file = Chef::Util::FileEdit.new("#{carina_home}/.bashrc")
        line = 'source ~/.one_env'
        file.insert_line_if_no_match(line, line)
        file.write_file
    end
end

template "#{carina_home}/.one_env" do
	owner carina_user
	group carina_user
	source "one_env.erb"
end

template "#{carina_home}/.one_auth" do
	owner carina_user
	group carina_user
	source "one_auth.erb"
    variables(
        :oneauth => node[:carina][:oneauth]
    )
end

# setup database
one_directory = node[:carina][:one_directory]
carina_directory = node[:carina][:directory]

template "#{carina_directory}/etc/system.conf" do
  source "system.conf.erb"
  variables(
    :db_password => node[:carina][:db_password]
  )
end

execute "create mysql schema" do
	user "carina"
	cwd "#{carina_directory}/misc"
	environment ({ "ONE_LOCATION" => one_directory })
	command "bash createschema.sh"
	not_if "mysql -u root --password=\"#{node[:carina][:db_password]}\" -e \"show databases\" | grep opennebula"
end

# setup apache
web_app "carina" do
	docroot "/var/www"
end

execute "copy cgi files" do
	creates "/usr/lib/cgi-bin/updateappstatus.sh"
	command "cp #{carina_directory}/cgi-bin/* /usr/lib/cgi-bin"
end

%w( repo downloads ).each do |directory|
    directory one_directory do
        owner carina_user
        group carina_user
        path "/var/www/#{directory}"
    end
end

# setup global.rb
template "#{carina_directory}/etc/global.rb" do
	owner carina_user
	group carina_user
	source "global.rb.erb"
    variables(
        :zone => node[:carina][:zone]
    )
end

# setup databag users
require 'chef/data_bag'

if Chef::DataBag.list.key?('services')
    services = data_bag('services')

    services.each do |service_name|
        service = data_bag_item('services', service_name)

        carina_service service_name do
            password service['password']
            zone service['zone']
            load_vm_info service['load_vm_info']
            carina_port service['carina_port']
        end
    end
end

