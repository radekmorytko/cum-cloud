require 'rake'
require 'rake/testtask'
require 'rake/packagetask'

task :default => :unit_tests

# tests
def test(t, files)
  t.verbose = true
  t.warning = true
  t.test_files = FileList.new(files)
  t.libs = %W(../lib src/vm_coordinator)
end

task :unit_tests do
  Rake::TestTask.new(:unit_tests) do |t|
    puts "Running unit tests"
    test(t, "test/**/*_test.rb")
  end
end

# pack cookbooks and send it (temporary solution)
Rake::PackageTask.new("cookbooks", :noversion) do |p|
  p.need_tar_gz = true
  p.package_files.include("src/cookbooks/**/**")
end

task :cookbooks => [:package] do
  print "Sending to remote host"
  `scp pkg/cookbooks.tar.gz cdariusz@student.agh.edu.pl:~/public_html/pp`
end

