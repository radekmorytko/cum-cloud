#!/bin/bash

LOG_DIR=log/client_endpoint.log

bin/client_endpoint.rb 2> $LOG_DIR &

if [ $? -eq 0 ]; then
  echo "Client rest service started or failed. Check logs that are located at $LOG_DIR"
fi