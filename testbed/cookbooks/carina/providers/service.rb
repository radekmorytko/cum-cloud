
action :create do	
    name = new_resource.name
    home = "/home/#{new_resource.name}"

    # user
    user name do
        password new_resource.password
        home home
        shell "/bin/bash"
        supports :manage_home => true
        action :create
    end

    %w( logs work conf vm ).each do |dir|
        directory dir do
            owner name
            group name
            path "#{home}/#{dir}"
        end
    end

    # oneenv.conf
    template "#{home}/conf/oneenv.conf" do
        owner name
        group name
        source "oneenv.conf.erb"
        variables({
            :carina_ip => node[:carina][:ip],
            :service_name => name,
            :zone => new_resource.zone,
            :load_vm_info => new_resource.load_vm_info,
            :carina_port => new_resource.carina_port
        })
    end

    # mysql schema
    one_directory = node[:carina][:one_directory]
    carina_directory = node[:carina][:directory]

    execute "create mysql schema for carina" do
        user "carina"
        cwd "#{carina_directory}/misc"
        environment ({ "ONE_LOCATION" => one_directory })
        command "bash createschema.sh #{name}"
        not_if "mysql -u root --password=\"#{node[:carina][:db_password]}\" -e \"show databases\" | grep #{name}"
    end

    # apache
    context_directory = "/var/www/repo/#{name}/context"
    directory context_directory do
        owner name
        group name
        recursive true
    end

    execute "cp /var/lib/one/opennebula-carina/context/* #{context_directory}" do
        user name
        creates "#{context_directory}/init.sh"
    end

    # config.rb
    template "#{home}/config.rb" do
        owner name
        group name
        source "config.rb.erb"
        variables({
            :proxy => node[:carina][:proxy],
            :oneauth => node[:carina][:oneauth],
        })
    end

    # vm templates
    execute "cp #{carina_directory}templates/* #{home}/vm" do
        user user
        creates "#{context_directory}/authorized_keys"
    end

    # ssh keys
    execute "ssh-keygen -t rsa -q -f #{home}/.ssh/id_rsa -P \"\"" do
        user name
        creates "#{home}/.ssh/id_rsa.pub"
    end

    execute "cp #{home}/.ssh/id_rsa.pub #{context_directory}/authorized_keys" do
        user user
        creates "#{context_directory}/authorized_keys"
    end
end

action :delete do
    name = new_resource.name

    execute "rm -rf /var/www/repo/#{name}"
    execute "usedel -r #{name}"
    # + mysql
end
