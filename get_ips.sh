#!/bin/bash

apt-get update
apt-get install -y dnsutils

counter=1
for ip in $(nslookup tasks.worker | awk '/^Address:/ && NR > 2 {print $2}'); do
  echo "$ip" > "/ips/ip_${counter}"
  ((counter++))
done
