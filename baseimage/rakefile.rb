require 'rake'
require 'rake/testtask'

task :default => :unit_tests

# tests
def test(t, files)
  t.verbose = true
  t.warning = true
  t.test_files = FileList.new(files)
  t.libs = %W(lib/vm_coordinator)
end

task :unit_tests do
  Rake::TestTask.new(:unit_tests) do |t|
    puts "Running unit tests"
    test(t, "test/**/*_test.rb")
  end
end

task :package do
  PACKAGE_NAME='${PACKAGE_NAME:-vm_coordinator}'
  PACKAGE_TYPE='${PACKAGE_TYPE:-deb}'
  VENDOR='${VENDOR:-cum_cloud}'
  VERSION='${VERSION:-3.8.3}'
  NAME="#{PACKAGE_NAME}_#{VERSION}.#{PACKAGE_TYPE}"

  # clean
  FileUtils.rm_rf 'pkg'

  # prepare absolute structure
  FileUtils.mkdir_p('pkg/opt')
  FileUtils.cp_r 'lib/vm_coordinator', 'pkg/opt'

  # create package
  cwd = File.dirname(File.expand_path(__FILE__))
  cmd = "cd pkg && fpm -n #{PACKAGE_NAME} -t #{PACKAGE_TYPE} \
         -s dir --vendor #{VENDOR} -v #{VERSION} -f -a all \
         --after-install #{cwd}/lib/vm_coordinator/package/postinstall \
         --after-remove #{cwd}/lib/vm_coordinator/package/postremove -p #{NAME} *"

  puts %x{#{cmd}}
end

