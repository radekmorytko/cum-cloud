require 'rake'
require 'rake/testtask'

task :default => :deploy

task :deploy, :host, :package do |t, args|
  args.with_defaults(:host => :'one', :package => 'oneapps_3.8.3.deb')
  user = 'root'

  puts %x{cd src && ./gen_package.sh}
  puts %x{scp src/#{args[:package]} root@#{args[:host]}:~}
  puts %x{ssh root@#{args[:host]} dpkg -i /root/#{args[:package]}}
end

