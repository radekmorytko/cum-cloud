require 'rake'
require 'rake/testtask'

task :default => :unit_tests

# tests
def test(t, files)
  t.verbose = true
  t.warning = true
  t.test_files = FileList.new(files)
  t.libs = %W(../lib src/vm_coordinator src/vm_coordinator/conf)
end

task :unit_tests do
  Rake::TestTask.new(:unit_tests) do |t|
    puts "Running unit tests"
    test(t, "test/**/*_test.rb")
  end
end

task :synch, :host, :path do |t, args|
  args.with_defaults(:path => '/usr/lib/one/ruby/oneapps')

  user = 'root'
  host = args[:host]
  path = args[:path]

  puts `rsync -avz src/vm_coordinator #{user}@#{host}:#{path}`
end

