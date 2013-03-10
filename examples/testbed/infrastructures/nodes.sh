#!/bin/bash

# boostrap compute nodes
knife bootstrap 192.168.122.52 -N compute -x ubuntu --sudo -r "role[base],role[opennebula::openvz]"

# boostrap frontend
knife bootstrap 192.168.122.53 -N frontend -x ubuntu --sudo -r "role[base],role[opennebula::frontend]"

