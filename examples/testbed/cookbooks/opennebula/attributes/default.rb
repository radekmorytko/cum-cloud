default[:opennebula][:user] = "oneadmin"
# hassed password using: openssl passwd -1 <password>
default[:opennebula][:password] = "$1$kT4MVlr0$TaA8mP96az6.7Eb7.7K3Y/"
default[:opennebula][:home] = "/home/oneadmin"
default[:opennebula][:uid] = 1001

# networking
default[:opennebula][:openvz][:interface] = 'eth0'
default[:opennebula][:openvz][:bridge] = 'virbr0'
