#!/usr/bin/env sh

set -euxo pipefail

CIDR_REGEX='[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\/[0-9]\{1,\}'

cd /data

echo "cidr" > datacenters.csv

wget -qO- https://ip-ranges.amazonaws.com/ip-ranges.json | grep -o "$CIDR_REGEX" >> datacenters.csv

wget -qO- https://www.cloudflare.com/ips-v4 >> datacenters.csv

wget -qO- https://www.gstatic.com/ipranges/cloud.json | grep -o "$CIDR_REGEX" >> datacenters.csv

wget -qO- $(wget -qO- -U Mozilla https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519 | grep -Eo 'https://download.microsoft.com/download/\S+?\.json' | head -n 1) | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\/[0-9]\{1,\}' >> datacenters.csv

echo "Success!"