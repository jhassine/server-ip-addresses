#!/usr/bin/env sh

set -euxo pipefail

CIDR_REGEX='[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\/[0-9]\{1,\}'
IP_ADDRESS_REGEX='([0-9]{1,3}[\.]){3}[0-9]{1,3}'

cd /data

wget -qO- https://ip-ranges.amazonaws.com/ip-ranges.json | grep -o "$CIDR_REGEX" > datacenters.txt

wget -qO- https://www.cloudflare.com/ips-v4 >> datacenters.txt

wget -qO- https://www.gstatic.com/ipranges/cloud.json | grep -o "$CIDR_REGEX" >> datacenters.txt

wget -qO- $(wget -qO- -U Mozilla https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519 | grep -Eo 'https://download.microsoft.com/download/\S+?\.json' | head -n 1) | grep -o "$CIDR_REGEX" >> datacenters.txt

cat datacenters.txt | sort -V > datacenters.txt

echo '"cidr","hostmin","hostmax"' > datacenters.csv

cat datacenters.txt | while read cidr; do
        hostmin=$(ipcalc $cidr | grep 'HostMin' | grep -E -o "$IP_ADDRESS_REGEX");
        hostmax=$(ipcalc $cidr | grep 'HostMax' | grep -E -o "$IP_ADDRESS_REGEX");
        echo "\"$cidr\",\"$hostmin\",\"$hostmax\"" >> datacenters.csv;
    done
cat datacenters.txt | while read cidr; do echo "\"$cidr\"" >> datacenters.csv; done

echo "Success!"