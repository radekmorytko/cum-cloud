opennebula Cookbook
===================
Cookbook which aims to setup OpenNebula environment that consist of frontend node and backend node. The latter is configured to run OpenVZ. Please note that cookbook itself doesn't install OpenVZ.

Requirements
------------

It is recommended to run cookbook together with recipes such as:
- `apt`, to get the latest repository updadtes
- `chef-client`, to run chef-client as a daemon
- `hostname`, to set node's name to the one used by Chef
- `sudo`, to get superuser privlidges for oneadmin user

Note that it is recommended to use `hostname` which is present in cookbook directory, as it is modified version of community cookbook.

Attributes
----------

* general
<pre>
default[:opennebula][:user] = "oneadmin"
default[:opennebula][:password] = "$1$kT4MVlr0$TaA8mP96az6.7Eb7.7K3Y/"
default[:opennebula][:home] = "/home/oneadmin"
</pre>
* networking
<pre>
default[:opennebula][:openvz][:interface] = "eth0"
default[:opennebula][:openvz][:bridge] = "virbr0"
</pre>

Note that password is 'shadowed' using command: <pre>openssl passwd -1 <password></pre>

Usage
-----

Exemplary frontend role:
<pre>
name "frontend"

run_list(
  'recipe[opennebula::frontend]',
)

override_attributes({
  :opennebula => {
    :home => "/var/lib/one"
  }
})
</pre>

License and Authors
-------------------

Authors: Dariusz Chrząścik
License: Apache License v2.
