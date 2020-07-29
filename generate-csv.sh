#!/usr/bin/env sh

set -euxo pipefail

CIDR_REGEX='[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\/[0-9]\{1,\}'

cd /data

wget -qO- https://ip-ranges.amazonaws.com/ip-ranges.json | grep -o "$CIDR_REGEX" >> datacenters.txt

wget -qO- https://www.cloudflare.com/ips-v4 | sed 's/.*/"&"/' >> datacenters.txt

wget -qO- https://www.gstatic.com/ipranges/cloud.json | grep -o "$CIDR_REGEX" >> datacenters.txt

wget -qO- $(wget -qO- -U Mozilla https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519 | grep -Eo 'https://download.microsoft.com/download/\S+?\.json' | head -n 1) | grep -o "$CIDR_REGEX" >> datacenters.txt

echo '"cidr"' > datacenters.csv

cat datacenters.txt | sed 's/.*/"&"/' >> datacenters.csv

echo "Success!"