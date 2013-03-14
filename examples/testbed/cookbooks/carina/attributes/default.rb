# installation
default[:carina][:user] = "carina"
default[:carina][:password] = "$1$kT4MVlr0$TaA8mP96az6.7Eb7.7K3Y/"
default[:carina][:home] = "/home/carina"
default[:carina][:one_directory] = "/var/lib/one"
default[:carina][:directory] = "#{default[:carina][:one_directory]}/opennebula-carina"

# database
default[:carina][:db_password] = "mysecretpassword"

# carina configuration
default[:carina][:proxy] = "http://one:2633/RPC2"
default[:carina][:oneauth] = "oneadmin:password"
default[:carina][:ip] = '192.168.122.52'
default[:carina][:zone] = 'flame'
