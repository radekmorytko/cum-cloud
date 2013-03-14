actions :install

def initialize(*args)
  super
  @action = :install
end

# get archive
attribute :url, :kind_of => String, :required => true
attribute :owner, :regex => Chef::Config['user_valid_regex'], :required => true
attribute :group, :regex => Chef::Config['group_valid_regex']

# unpack archive
attribute :type, :kind_of => String, :default => "tar.gz"

# command execution
attribute :cwd, :kind_of => String
attribute :command, :kind_of => String
attribute :creates, :kind_of => String
