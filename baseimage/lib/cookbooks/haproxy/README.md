Description
===========

Installs haproxy and prepares the configuration location.

Requirements
============

## Platform

* Ubuntu (10.04+ due to config option change)
* Debian (6.0+)

Attributes
==========

* `node['haproxy']['incoming_address']` - sets the address to bind the
  haproxy process on, 0.0.0.0 (all addresses) by default
* `node['haproxy']['incoming_port']` - sets the port on which haproxy
  listens
* `node['haproxy']['members']` - used by the default recipe to specify the member systems to add. Default

```
[{
  "hostname" => "localhost",
  "ipaddress" => "127.0.0.1",
  "port" => "4000"
}, {
  "hostname" => "localhost",
  "ipaddress" => "127.0.0.1",
  "port" => "4001"
}]
```

* `node['haproxy']['member_port']` - the port that member systems will
  be listening on if not otherwise specified in the members attribute, default 8080
* `node['haproxy']['app_server_role']` - used by the `app_lb` recipe
  to search for a specific role of member systems. Default
  `webserver`.
* `node['haproxy']['balance_algorithm']` - sets the load balancing
  algorithm; defaults to roundrobin.
* `node['haproxy']['enable_ssl']` - whether or not to create listeners
  for ssl, default false
* `node['haproxy']['ssl_incoming_address']` - sets the address to bind
  the haproxy on for SSL, 0.0.0.0 (all addresses) by default
* `node['haproxy']['ssl_member_port']` - the port that member systems
  will be listening on for ssl, default 8443
* `node['haproxy']['ssl_incoming_port']` - sets the port on which
  haproxy listens for ssl, default 443
* `node['haproxy']['httpchk']` - used by the `app_lb` recipe. If set,
  will configure httpchk in haproxy.conf
* `node['haproxy']['ssl_httpchk']` - used by the `app_lb` recipe. If
  set and `enable_ssl` is true, will configure httpchk in haproxy.conf
  for the `ssl_application` section
* `node['haproxy']['enable_admin']` - whether to enable the admin
  interface. default true. Listens on port 22002.
* `node['haproxy']['admin']['address_bind']` - sets the address to
  bind the administrative interface on, 127.0.0.1 by default
* `node['haproxy']['admin']['port']` - sets the port for the
  administrative interface, 22002 by default
* `node['haproxy']['pid_file']` - the PID file of the haproxy process,
  used in the tuning recipe.
* `node['haproxy']['defaults_options']` - an array of options to use
  for the config file's `defaults` stanza, default is
  ["httplog", "dontlognull", "redispatch"]
* `node['haproxy']['defaults_timeouts']['connect']` - connect timeout
  in defaults stanza
* `node['haproxy']['defaults_timeouts']['client']` - client timeout in
  defaults stanza
* `node['haproxy']['defaults_timeouts']['server']` - server timeout in
  defaults stanza
* `node['haproxy']['x_forwarded_for']` - if true, creates an
  X-Forwarded-For header containing the original client's IP address.
  This option disables KeepAlive.
* `node['haproxy']['member_max_connections']` - the maxconn value to
  be set for each app server
* `node['haproxy']['user']` - user that haproxy runs as
* `node['haproxy']['group']` - group that haproxy runs as
* `node['haproxy']['global_max_connections']` - in the `app_lb`
  config, set the global maxconn
* `node['haproxy']['member_max_connections']` - in both configs, set
  the maxconn per member
* `node['haproxy']['frontend_max_connections']` - in the `app_lb`
  config, set the the maxconn per frontend member
* `node['haproxy']['frontend_ssl_max_connections']` - in the `app_lb`
  config, set the maxconn per frontend member using SSL
* `node['haproxy']['install_method']` - determines which method is
  used to install haproxy, must be 'source' or 'package'. defaults to
  'package'
* `node['haproxy']['conf_dir']` - the location of the haproxy config
  file
* `node['haproxy']['source']['version']` - the version of haproxy to
  install
* `node['haproxy']['source']['url']` - the full URL to the haproxy
  source package
* `node['haproxy']['source']['checksum']` - the checksum of the
  haproxy source package
* `node['haproxy']['source']['prefix']` - the prefix used to `make
  install` haproxy
* `node['haproxy']['source']['target_os']` - the target used to
  `make` haproxy
* `node['haproxy']['source']['target_cpu']` - the target cpu used to
  `make` haproxy
* `node['haproxy']['source']['target_arch']` - the target arch used
  to `make` haproxy
* `node['haproxy']['source']['use_pcre']` - whether to build with
  libpcre support

Recipes
=======

## default

Sets up haproxy using statically defined configuration. To override
the configuration, modify the templates/default/haproxy.cfg.erb file
directly, or supply your own and override the cookbook and source by
reopening the `template[/etc/haproxy/haproxy.cfg]` resource.

## app\_lb

Sets up haproxy using dynamically defined configuration through
search. See __Usage__ below.

## tuning

Uses the community `cpu` cookbook's `cpu_affinity` LWRP to set
affinity for the haproxy process.

## install\_package

Installs haproxy through the package manager. Used by the `default`
and `app_lb` recipes.

## install\_source

Installs haproxy from source. Used by the `default` and `app_lb`
recipes.

Usage
=====

Use either the default recipe or the `app_lb` recipe.

When using the default recipe, the members attribute specifies the application servers.

    "haproxy" => {
      "members" => [{
        "hostname" => "appserver1",
        "ipaddress" => "123.123.123.1",
        "port" => "4000"
      }, {
        "hostname" => "appserver2",
        "ipaddress" => "123.123.123.2",
        "port" => "4000"
      }, {
        "hostname" => "appserver3",
        "ipaddress" => "123.123.123.3",
        "port" => "4000"
      }]
    }

Note that the `port` attribute is optional and will default to the value of `node['haproxy']['member_port']`

The `app_lb` recipe is designed to be used with the application
cookbook, and provides search mechanism to find the appropriate
application servers. Set this in a role that includes the
haproxy::app_lb recipe. For example,

    name "load_balancer"
    description "haproxy load balancer"
    run_list("recipe[haproxy::app_lb]")
    override_attributes(
      "haproxy" => {
        "app_server_role" => "webserver"
      }
    )

The search uses the node's `chef_environment`. For example, create
`environments/production.rb`, then upload it to the server with knife

    % cat environments/production.rb
    name "production"
    description "Nodes in the production environment."
    % knife environment from file production.rb

License and Author
==================

- Author:: Joshua Timberman (<joshua@opscode.com>)
- Copyright:: 2009-2012, Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
