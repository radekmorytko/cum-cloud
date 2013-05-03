one_lib = File.dirname(__FILE__) + '/../../opennebula-3.8.3/src/oca/ruby'
oneapps_lib = File.dirname(__FILE__) + '/one/ruby/oneapps'

$: << one_lib
$: << oneapps_lib + '/stage'
$: << oneapps_lib + '/flow'
$: << oneapps_lib + '/flow/models'
$: << oneapps_lib + '/vm_coordinator'


require 'onechef'
require 'base64'
require 'ServiceTemplate'
require 'Service'



