require 'models/container'
require 'models/stack'
require 'models/service'

DataMapper.finalize

class Hash
  alias :to_s :inspect
end

class Array
  alias :to_s :inspect
end