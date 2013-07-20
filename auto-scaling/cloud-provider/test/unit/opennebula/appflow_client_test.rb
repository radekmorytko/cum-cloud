require 'rubygems'
require 'test/unit'
require 'mocha/setup'
require 'fakeweb'

require 'opennebula/appflow_client'

module AutoScaling
  class OpenNebulaClientTest < Test::Unit::TestCase

    OPTIONS = {
        :username => 'oneadmin',
        :password => 'password',
        :server => 'http://example.com'
    }

    def setup
      @appflow_client = AppflowClient.new OPTIONS
    end

    def test_shall_return_configuration_when_service_is_running
      service_id = 120
      FakeWeb.register_uri(:get,
                           "http://#{OPTIONS[:username]}:#{OPTIONS[:password]}@example.com/service/#{service_id}",
                           [{:body => PENDING_CONFIGURATION, :times => 2}, {:body => CONFIGURATION}])

      expected = {
          "worker"=>[{:ip=>"192.168.122.101", :id=>"139"}],
          "loadbalancer"=>[{:ip=>"192.168.122.100", :id=>"138"}]
      }
      actual = @appflow_client.configuration service_id

      assert_equal expected, actual
    end


    def test_shall_throw_exception_when_service_is_pending
      service_id = 120
      FakeWeb.register_uri(:get,
                           "http://#{OPTIONS[:username]}:#{OPTIONS[:password]}@example.com/service/#{service_id}",
                           {:body => PENDING_CONFIGURATION, :times => 4})

      assert_raises RuntimeError do
        @appflow_client.configuration service_id
      end

    end

    PENDING_CONFIGURATION =
<<EOF
{
  "DOCUMENT": {
    "TEMPLATE": {
      "BODY": {
        "state": 1,
        "name": "chef_sample_service",
        "log": [
          {
            "message": "New state: DEPLOYING",
            "timestamp": 1374277594,
            "severity": "I"
          }
        ],
        "deployment": "straight",
        "roles": [
          {
            "cardinality": 1,
            "state": "1",
            "name": "loadbalancer",
            "vm_template": 7,
            "appstage_id": 39,
            "nodes": [
              {
                "deploy_id": 140,
                "vm_info": {
                  "VM": {
                    "ID": "140"
                  }
                }
              }
            ]
          },
          {
            "cardinality": 1,
            "state": 0,
            "name": "tomcat-worker",
            "parents": [
              "loadbalancer"
            ],
            "vm_template": 7,
            "appstage_id": 25,
            "nodes": [

            ]
          }
        ]
      }
    },
    "UNAME": "oneadmin",
    "PERMISSIONS": {
      "OTHER_A": "0",
      "OTHER_M": "0",
      "OTHER_U": "0",
      "OWNER_A": "0",
      "OWNER_M": "1",
      "OWNER_U": "1",
      "GROUP_A": "0",
      "GROUP_M": "0",
      "GROUP_U": "0"
    },
    "UID": "0",
    "GNAME": "oneadmin",
    "TYPE": "100",
    "NAME": "chef_sample_service",
    "GID": "0",
    "ID": "120"
  }
}
EOF

    CONFIGURATION =
<<-eos
{
  "DOCUMENT": {
    "TEMPLATE": {
      "BODY": {
        "state": 2,
        "name": "chef_sample_service",
        "log": [
          {
            "message": "New state: DEPLOYING",
            "timestamp": 1374272897,
            "severity": "I"
          },
          {
            "message": "New state: RUNNING",
            "timestamp": 1374272964,
            "severity": "I"
          }
        ],
        "deployment": "straight",
        "roles": [
          {
            "cardinality": 1,
            "state": "2",
            "name": "loadbalancer",
            "vm_template": 7,
            "appstage_id": 39,
            "nodes": [
              {
                "deploy_id": 138,
                "vm_info": {
                  "VM": {
                    "UNAME": "oneadmin",
                    "TEMPLATE": {
                      "CPU": "1",
                      "DISK": {
                        "DRIVER": "qcow2",
                        "SOURCE": "/var/lib/one/datastores/1/657be1156d0009a8da7c7d0d782fb57a",
                        "TM_MAD": "qcow2",
                        "DATASTORE_ID": "1",
                        "IMAGE_ID": "32",
                        "SAVE": "NO",
                        "TYPE": "FILE",
                        "TARGET": "hda",
                        "DISK_ID": "0",
                        "IMAGE": "Ubuntu 12.04 base",
                        "READONLY": "NO",
                        "DATASTORE": "default",
                        "CLONE": "YES",
                        "DEV_PREFIX": "hd"
                      },
                      "CONTEXT": {
                        "FILES": "/srv/context/cookbooks",
                        "NODE": "eyJydW5fbGlzdCI6WyJyZWNpcGVbaGFwcm94eV0iXSwiaGFwcm94eSI6eyJtZW1iZXJfcG9ydCI6IjgwODAiLCJtZW1iZXJzIjpbXX0sIm5hbWUiOiJub2RlLWxvYWRiYWxhbmNlciJ9",
                        "SERVICE_ID": "119",
                        "TARGET": "hdb",
                        "DISK_ID": "1",
                        "ETH0_DNS": "192.168.122.1",
                        "IP": "192.168.122.100",
                        "ROLE": "MASTER",
                        "VM_NAME": "loadbalancer_0_(service_119)"
                      },
                      "GRAPHICS": {
                        "PORT": "6038",
                        "TYPE": "vnc",
                        "LISTEN": "0.0.0.0"
                      },
                      "NAME": "ubuntu-server-cum",
                      "TEMPLATE_ID": "7",
                      "MEMORY": "512",
                      "OS": {
                        "ARCH": "x86_64"
                      },
                      "VMID": "138",
                      "NIC": {
                        "MAC": "02:00:c0:a8:7a:64",
                        "NETWORK_ID": "0",
                        "NETWORK": "Internal",
                        "VLAN": "NO",
                        "BRIDGE": "virbr0",
                        "IP": "192.168.122.100"
                      }
                    },
                    "UID": "0",
                    "PERMISSIONS": {
                      "OTHER_U": "0",
                      "OTHER_M": "0",
                      "OTHER_A": "0",
                      "OWNER_U": "1",
                      "OWNER_M": "1",
                      "OWNER_A": "0",
                      "GROUP_U": "0",
                      "GROUP_M": "0",
                      "GROUP_A": "0"
                    },
                    "LCM_STATE": "3",
                    "ETIME": "0",
                    "GNAME": "oneadmin",
                    "LAST_POLL": "1374274002",
                    "CPU": "4",
                    "NET_TX": "13098",
                    "DEPLOY_ID": "one-138",
                    "HISTORY_RECORDS": {
                      "HISTORY": {
                        "OID": "138",
                        "ETIME": "0",
                        "VMMMAD": "vmm_kvm",
                        "TMMAD": "shared",
                        "ESTIME": "0",
                        "HOSTNAME": "kvm01",
                        "PSTIME": "1374272899",
                        "RETIME": "0",
                        "STIME": "1374272899",
                        "VNMMAD": "dummy",
                        "DS_ID": "0",
                        "DS_LOCATION": "/var/lib/one/datastores",
                        "RSTIME": "1374272910",
                        "HID": "0",
                        "PETIME": "1374272910",
                        "EETIME": "0",
                        "REASON": "0",
                        "SEQ": "0"
                      }
                    },
                    "STATE": "3",
                    "STIME": "1374272897",
                    "NAME": "ubuntu-server-cum",
                    "ID": "138",
                    "GID": "0",
                    "RESCHED": "0",
                    "MEMORY": "524288",
                    "NET_RX": "592979"
                  }
                }
              }
            ]
          },
          {
            "cardinality": 1,
            "state": "2",
            "name": "worker",
            "parents": [
              "loadbalancer"
            ],
            "vm_template": 7,
            "appstage_id": 25,
            "nodes": [
              {
                "deploy_id": 139,
                "vm_info": {
                  "VM": {
                    "UNAME": "oneadmin",
                    "TEMPLATE": {
                      "CPU": "1",
                      "DISK": {
                        "DRIVER": "qcow2",
                        "SOURCE": "/var/lib/one/datastores/1/657be1156d0009a8da7c7d0d782fb57a",
                        "TM_MAD": "qcow2",
                        "DATASTORE_ID": "1",
                        "IMAGE_ID": "32",
                        "SAVE": "NO",
                        "TYPE": "FILE",
                        "TARGET": "hda",
                        "DISK_ID": "0",
                        "IMAGE": "Ubuntu 12.04 base",
                        "READONLY": "NO",
                        "DATASTORE": "default",
                        "CLONE": "YES",
                        "DEV_PREFIX": "hd"
                      },
                      "CONTEXT": {
                        "FILES": "/srv/context/cookbooks",
                        "NODE": "eyJydW5fbGlzdCI6WyJyZWNpcGVbdG9tY2F0XSJdLCJuYW1lIjoidG9tY2F0LXdvcmtlciJ9",
                        "SERVICE_ID": "119",
                        "TARGET": "hdb",
                        "DISK_ID": "1",
                        "ETH0_DNS": "192.168.122.1",
                        "IP": "192.168.122.101",
                        "ROLE": "SLAVE",
                        "VM_NAME": "tomcat-worker_0_(service_119)"
                      },
                      "GRAPHICS": {
                        "PORT": "6039",
                        "TYPE": "vnc",
                        "LISTEN": "0.0.0.0"
                      },
                      "NAME": "ubuntu-server-cum",
                      "TEMPLATE_ID": "7",
                      "MEMORY": "512",
                      "OS": {
                        "ARCH": "x86_64"
                      },
                      "VMID": "139",
                      "NIC": {
                        "MAC": "02:00:c0:a8:7a:65",
                        "NETWORK_ID": "0",
                        "NETWORK": "Internal",
                        "VLAN": "NO",
                        "BRIDGE": "virbr0",
                        "IP": "192.168.122.101"
                      }
                    },
                    "UID": "0",
                    "PERMISSIONS": {
                      "OTHER_U": "0",
                      "OTHER_M": "0",
                      "OTHER_A": "0",
                      "OWNER_U": "1",
                      "OWNER_M": "1",
                      "OWNER_A": "0",
                      "GROUP_U": "0",
                      "GROUP_M": "0",
                      "GROUP_A": "0"
                    },
                    "LCM_STATE": "3",
                    "ETIME": "0",
                    "GNAME": "oneadmin",
                    "LAST_POLL": "1374274017",
                    "CPU": "8",
                    "NET_TX": "580022",
                    "DEPLOY_ID": "one-139",
                    "HISTORY_RECORDS": {
                      "HISTORY": {
                        "OID": "139",
                        "ETIME": "0",
                        "VMMMAD": "vmm_kvm",
                        "TMMAD": "shared",
                        "ESTIME": "0",
                        "HOSTNAME": "kvm01",
                        "PSTIME": "1374272941",
                        "RETIME": "0",
                        "STIME": "1374272941",
                        "VNMMAD": "dummy",
                        "DS_ID": "0",
                        "DS_LOCATION": "/var/lib/one/datastores",
                        "RSTIME": "1374272956",
                        "HID": "0",
                        "PETIME": "1374272956",
                        "EETIME": "0",
                        "REASON": "0",
                        "SEQ": "0"
                      }
                    },
                    "STATE": "3",
                    "STIME": "1374272930",
                    "NAME": "ubuntu-server-cum",
                    "ID": "139",
                    "GID": "0",
                    "RESCHED": "0",
                    "MEMORY": "541684",
                    "NET_RX": "42572334"
                  }
                }
              }
            ]
          }
        ]
      }
    },
    "UNAME": "oneadmin",
    "PERMISSIONS": {
      "OTHER_A": "0",
      "OTHER_M": "0",
      "OTHER_U": "0",
      "OWNER_A": "0",
      "OWNER_M": "1",
      "OWNER_U": "1",
      "GROUP_A": "0",
      "GROUP_M": "0",
      "GROUP_U": "0"
    },
    "UID": "0",
    "GNAME": "oneadmin",
    "TYPE": "100",
    "NAME": "chef_sample_service",
    "GID": "0",
    "ID": "119"
  }
}
eos

  end
end
