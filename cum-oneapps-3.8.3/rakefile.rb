require 'rake'
require 'rake/testtask'

task :default => :deploy

task :gen_package do
  puts %x{cd lib && ./gen_package.sh}
end

task :deploy, [:host, :package] => [:gen_package] do |t, args|
  args.with_defaults(:host => :'one', :package => 'oneapps_3.8.3.deb')
  user = 'root'

  puts %x{scp lib/#{args[:package]} root@#{args[:host]}:~}
  puts %x{ssh root@#{args[:host]} dpkg -i /root/#{args[:package]}}
end

