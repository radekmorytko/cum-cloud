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

# cum-oneapps
%w(json sinatra rest-client redis).each do |gem|
  gem_package(gem) do
    gem_binary "gem"
  end
end

oneapps_path = '/usr/lib/one/ruby/oneapps'
directory oneapps_path do
   recursive true
end

# symlink
execute "rm -rf /etc/one-context.d/99-one-chef"
execute "ln -s #{oneapps_path}/vm_coordinator/99-one-chef /etc/one-context.d/99-one-chef"
