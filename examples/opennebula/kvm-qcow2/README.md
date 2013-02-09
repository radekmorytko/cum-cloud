Introduction
============

Directory contains configuration files that are necessary to setup OpenNebula's virtual machine. Virtual machine is kvm-based and supports qcow2 file format.

It is assumed that OpenNebula instance is up and running.

Files
=====

Files should be executed in normal manner, ie. using command like onetemplate create, etc.

 * qcow2.datastore - qcow2 datastore
 * ubuntu.image
   * please customise your PATH
 * internal.vnet - virtual network template file
   * adjust BRIDGE value
   * adjust fixed pool
 * ubuntu.template
   * template requires OpenNebula 3.8 contextualized image
   * adjust NETWORK_ID value

