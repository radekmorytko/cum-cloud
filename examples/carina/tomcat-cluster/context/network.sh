#!/bin/bash
# -------------------------------------------------------------------------- #
# Copyright 2011-2012, Research In Motion (rim.com)                          #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

. /mnt/context.sh

hostname $HOSTNAME
hostname > /etc/hostname

echo "$ETH0_IP $HOSTNAME" >> /etc/hosts

#Allow ssh traffic in
iptables -I INPUT -p tcp --dport 22 -j ACCEPT

wget http://$CARINA_IP/cgi-bin/updatevmstatus.sh?service=$SERVICE_NAME\&vmid=$VMID\&envid=$ENVID\&newip=$IP\&name=$HOSTNAME 2> /dev/null
