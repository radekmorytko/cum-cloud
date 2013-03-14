#!/bin/bash

# boostrap compute nodes
knife bootstrap 192.168.122.52 -N compute -x ubuntu --sudo -r "role[base],role[openvz]"

# boostrap frontend
knife bootstrap 192.168.122.53 -N frontend -x ubuntu --sudo -r "role[base],role[frontend]"

# bootstrap carina
knife bootstrap 192.168.122.54 -N carina -x ubuntu --sudo -r "role[base],role[carina]"

