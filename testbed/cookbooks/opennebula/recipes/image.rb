package "ruby"
package "ruby-dev"
package "rubygems"
package "libopenssl-ruby"
package "curl"
package "apache2" do
  action :purge
end

execute "service apache2 stop"

gem_package "mime-types" do
  version '1.16'
end

# chef-solo is installed implicitly

# oneapps, vm_coordinator
packages = ['app-context_3.8.2.deb', 'vm_coordinator_3.8.3.deb']
packages.each do |pkg|
  dst = "/tmp/#{pkg}"

  cookbook_file dst do
    source pkg
    mode "0444"
  end

  package pkg do
    provider Chef::Provider::Package::Dpkg
    source dst
    action :install
  end
end

# cum-oneapps
%w(json sinatra rest-client).each do |gem|
  gem_package(gem) do
    gem_binary "gem"
  end
end
