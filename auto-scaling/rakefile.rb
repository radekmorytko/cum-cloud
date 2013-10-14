require 'rake'
require 'rake/testtask'

task :default => :package

task :package do
  PACKAGE_NAME='${PACKAGE_NAME:-auto_scaling}'
  PACKAGE_TYPE='${PACKAGE_TYPE:-rpm}'
  VENDOR='${VENDOR:-sap_cloud}'
  VERSION='${VERSION:-1.0.0}'
  NAME="#{PACKAGE_NAME}_#{VERSION}.#{PACKAGE_TYPE}"

  # clean
  FileUtils.rm_rf 'pkg'

  # prepare absolute structure
  FileUtils.mkdir_p('pkg/opt')
  FileUtils.cp_r 'cloud-controller', 'pkg/opt/'
  FileUtils.cp_r 'cloud-provider', 'pkg/opt/'
  FileUtils.cp_r 'server', 'pkg/opt/'
  FileUtils.cp_r 'service-controller', 'pkg/opt/'

  # create package
  cwd = File.dirname(File.expand_path(__FILE__))
  cmd = "cd pkg && fpm -n #{PACKAGE_NAME} -t #{PACKAGE_TYPE} \
         -s dir --vendor #{VENDOR} -v #{VERSION} -f -a all -p #{NAME} *"

  puts %x{#{cmd}}
end

