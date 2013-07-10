package "ruby"
package "rubygems"

# chef-solo is installed implicitly

# oneapps
opennebula_pkg_name = 'app-context_3.8.2.deb'
opennebula_pkg_dst = "/tmp/#{opennebula_pkg_name}"

cookbook_file opennebula_pkg_dst do
  source opennebula_pkg_name
  mode "0444"
end

package opennebula_pkg_name do
  provider Chef::Provider::Package::Dpkg
  source opennebula_pkg_dst
  action :install
end

# vm-coordinator
# oneapps
vm_coordinator_pkg_name = 'vm_coordinator_3.8.3.deb'
vm_coordinator_pkg_dst = "/tmp/#{opennebula_pkg_name}"

cookbook_file vm_coordinator_pkg_dst do
  source vm_coordinator_pkg_name
  mode "0444"
end

package vm_coordinator_pkg_name do
  provider Chef::Provider::Package::Dpkg
  source vm_coordinator_pkg_dst
  action :install
end

# cum-oneapps
%w(json sinatra rest-client).each do |gem|
  gem_package(gem) do
    gem_binary "gem"
  end
end

oneapps_path = '/usr/lib/one/ruby/oneapps'
directory oneapps_path do
   recursive true
end
