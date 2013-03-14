actions :create, :delete

attribute :password, :kind_of => String, :required => true
attribute :zone, :kind_of => String, :required => true
attribute :load_vm_info, :kind_of => String, :required => true
attribute :carina_port, :kind_of => Integer, :required => true


def initialize(*args)
  super
  @action = :create
end


