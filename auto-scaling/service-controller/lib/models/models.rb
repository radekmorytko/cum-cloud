require 'models/container'
require 'models/stack'
require 'models/service'
require 'models/policy'
require 'models/policy_set'

DataMapper.finalize

# a little of money-code to pretty prints data in logs
class Hash
  alias :to_s :inspect
end

class Array
  alias :to_s :inspect
end