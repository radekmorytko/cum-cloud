# action :install is responsible for:
# - downloading / copying specifed archive
# - unpacking archive
# - executing command [optional]
action :install do	
	# download archive to cache directory
	cache = "/var/chef/cache/#{new_resource.name}.#{new_resource.type}"
	
	# if url has a protocol then it is remote_file
	if new_resource.url.start_with?( 'http://', 'https://' )
		remote_file cache do
		  source new_resource.url
		  owner new_resource.owner
		  group new_resource.group
		  mode "0444"
		end
	else
		cookbook_file cache do
			source new_resource.url
			owner new_resource.owner
			group new_resource.group
			mode "0444"
		end
	end

	# unpack archive	
	case new_resource.type 
		when "tar.gz"
		  unpack_archive = "tar -xvzf #{cache} -C /tmp"
		when "zip"
		  unpack_archive = "unzip #{cache} -d /tmp"
		else
		  puts "Uknown archive type"
	end
	
	execute "unpack #{new_resource.name}: #{unpack_archive}" do
		user new_resource.owner
		creates new_resource.cwd
		command "#{unpack_archive}"
	end

	# execute command if provided
	if new_resource.command
		execute "executing initialization script for archive: #{new_resource.name}" do
			user new_resource.owner
			group new_resource.group
			cwd new_resource.cwd
			creates new_resource.creates
			command new_resource.command
		end
	end

end
