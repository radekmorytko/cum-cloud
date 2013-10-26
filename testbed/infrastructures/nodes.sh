#!/bin/bash

# boostrap compute nodes
for i in `seq 232 237`; do
	# lab430-06 is permanently crashed
	if [ $i == 236 ]; then
		continue
	fi

	knife bootstrap 172.19.145.$i -x root -P "root123$" -r "role[base],role[openvz]"
done

# boostrap frontend
#knife bootstrap 172.19.145.231 -N frontend-01 -r "role[base],role[frontend]"

# bootstrap carina
#knife bootstrap 192.168.122.54 -N carina -x ubuntu --sudo -r "role[base],role[carina]"

