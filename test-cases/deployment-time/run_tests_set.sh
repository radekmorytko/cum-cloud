#!/bin/bash

## The first and only optional argument is a hostname of a frontend node

frontend_name=frontend1
if [ -z "$1" ]; then
  echo "Using default hostname of a frontend: $frontend_name "
else
  frontend_name=$1
  echo "Using passed argument as a hostname of a frontend: $frontend_name"
fi

timestamp=`date +%s`
output_file="/tmp/deployment-time_$timestamp.log"

payload_file=payloads/payload.json
cp $payload_file $payload_file.original

for instance_count in `seq 1 2`; do
  for i in `seq 10`; do
    echo "Running $i test for $instance_count instance(s)"
    sed "s/\"instances\":[0-9]/\"instances\":$instance_count/" $payload_file > $payload_file.tmp
    mv $payload_file.tmp $payload_file

    output=`rake`

    time_elapsed=`echo $output | sed 's/.*\(Time elapsed: \([0-9]\{1,\}.[0-9]\{1,\}\)\).*/\2/'`

    echo "$instance_count $i $time_elapsed" >> $output_file

    # cleanup

    start=`ssh oneadmin@$frontend_name onevm list | tail -n +2 | head -n 1 | awk '{print $1}'`
    stop=`ssh oneadmin@$frontend_name onevm list | tail -n +2 | tail -n 1 | awk '{print $1}'`
    if [ ! -z $start ]; then
      echo "Cleaning up all VMs .."
      ssh oneadmin@frontend1 onevm delete $start..$stop
      echo "Done"
    fi

    echo "Waiting for a node to calm down"
    sleep 15
  done
done

mv $payload_file.original $payload_file

