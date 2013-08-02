# add external dependencies - ie. opennebula library
$: << File.join(File.dirname(File.expand_path(__FILE__)), 'ext')
$: << File.join(File.dirname(File.expand_path(__FILE__)), 'lib')

require 'opennebula/opennebula_client'
