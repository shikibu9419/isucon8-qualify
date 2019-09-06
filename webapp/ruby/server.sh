#!/bin/sh

trap "sudo systemctl stop torb.ruby.service; echo 'server stopped'" 0

sudo systemctl start torb.ruby.service
echo 'server started'

while true; do
  sleep 1
done
