require 'domain/container'
require 'domain/stack'
require 'domain/service'
require 'domain/policy'
require 'domain/policy_set'

DataMapper.finalize

class Hash
  alias :to_s :inspect
end

class Array
  alias :to_s :inspect
end