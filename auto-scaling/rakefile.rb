require 'rake'
require 'rake/testtask'

task :default => :package

task :deploy do

end

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
  %w(cloud-controller cloud-provider server service-controller).each do |dir|
    FileUtils.cp_r(dir, 'pkg/opt/auto-scaling')
  end

  # create package
  cwd = File.dirname(File.expand_path(__FILE__))
  cmd = "cd pkg && fpm -n #{PACKAGE_NAME} -t #{PACKAGE_TYPE} \
         -s dir --vendor #{VENDOR} -v #{VERSION} -f -a all -p #{NAME} *"

  puts %x{#{cmd}}
end

