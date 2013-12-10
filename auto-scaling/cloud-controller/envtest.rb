#!/usr/bin/env ruby
require 'pp'
def environmentize(environment, hash)
  if hash.has_key?(environment)
    to_merge = hash.delete(environment)
    hash.each_key { |key| hash.delete(key) }
    hash.merge!(to_merge)
  else
    hash.each_value { |v| environmentize(environment, v) if v.is_a?(Hash) }
  end
end
h = {
  :a => { :val =>  { :key => 'aval'} },
  :b => { :val =>  { :key => 'bval'} }
}

pp h

environmentize(:a, h)

pp h

h = {
  :val => { :a =>  { :key => 'aval'}, :b => { :key => 'bval'} },
  :g => {
    :h => {
      :j => { :a =>  { :key => 'aval'}, :b => { :key => 'bval'} },
      :k => { :a =>  { :key => 'aval'}, :b => { :key => 'bval'} }
    }
  },
  :val2 => { :b =>  { :key => 'bval'}, :a => { :key => 'val'} }
}

pp h

environmentize(:b, h)

pp h
