require 'rake'
require 'rake/testtask'

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

task :synch, :host, :path do |t, args|
  args.with_defaults(:path => '/usr/lib/one/ruby/oneapps')

  user = 'root'
  host = args[:host]
  path = args[:path]

  puts `rsync -avz src/vm_coordinator #{user}@#{host}:#{path}`
end

task :package do
  PACKAGE_NAME='${PACKAGE_NAME:-vm_coordinator}'
  PACKAGE_TYPE='${PACKAGE_TYPE:-deb}'
  VENDOR='${VENDOR:-cum_cloud}'
  VERSION='${VERSION:-3.8.3}'
  NAME="#{PACKAGE_NAME}_#{VERSION}.#{PACKAGE_TYPE}"

  # cleanup
  FileUtils.remove_dir 'pkg', true
  FileUtils.mkdir_p('pkg/tmp')
  FileUtils.cp_r 'src/vm_coordinator', 'pkg/tmp'

  # create package
  puts %x{cd pkg && fpm -n #{PACKAGE_NAME} -t #{PACKAGE_TYPE} -s dir --vendor #{VENDOR} -v #{VERSION} -f -a all -p #{NAME} *}
end

