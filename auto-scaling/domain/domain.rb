require 'domain/container'
require 'domain/stack'
require 'domain/service'
require 'domain/policy'
require 'domain/policy_set'

DataMapper.finalize

# a little of money-code to pretty prints data in logs
class Hash
  alias :to_s :inspect
end

class Array
  alias :to_s :inspect
end