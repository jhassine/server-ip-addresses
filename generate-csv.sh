#!/usr/bin/env bash

set -euo pipefail

CIDR_REGEX='[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\/[0-9]\{1,\}'
IP_ADDRESS_REGEX='([0-9]{1,3}[\.]){3}[0-9]{1,3}'

cd /data

cidrs_aws=$(wget -qO- https://ip-ranges.amazonaws.com/ip-ranges.json | grep -o "$CIDR_REGEX" | sort -V)
echo -n "AWS CIDRs: "
echo "$cidrs_aws" | wc -l

cidrs_cloudflare=$(wget -qO- https://www.cloudflare.com/ips-v4 | sort -V)
echo -n "CloudFlare CIDRs: "
echo "$cidrs_cloudflare" | wc -l

cidrs_gcp=$(wget -qO- https://www.gstatic.com/ipranges/cloud.json | grep -o "$CIDR_REGEX" | sort -V)
echo -n "GCP CIDRs: "
echo "$cidrs_gcp" | wc -l

cidrs_azure=$(wget -qO- $(wget -qO- -U Mozilla https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519 | grep -Eo 'https://download.microsoft.com/download/\S+?\.json' | head -n 1) | grep -o "$CIDR_REGEX" | sort -V )
echo -n "Azure CIDRs: "
echo "$cidrs_azure" | wc -l

echo -e "$cidrs_aws\n$cidrs_cloudflare\n$cidrs_gcp\n$cidrs_azure\n" | uniq > datacenters.txt

get_csv_of_low_and_high_ip_from_cidr_list()
{
    cidrs=$1
    vendor=$2
    echo "$cidrs" | while read cidr;
    do
        hostmin=$(ipcalc -n $cidr |cut -f2 -d=)
        hostmax=$(ipcalc -b $cidr |cut -f2 -d=)
        echo "\"$cidr\",\"$hostmin\",\"$hostmax\",\"$vendor\""
    done
}

echo '"cidr","hostmin","hostmax","vendor"' > datacenters.csv
get_csv_of_low_and_high_ip_from_cidr_list "$cidrs_aws" "AWS" | uniq >> datacenters.csv
get_csv_of_low_and_high_ip_from_cidr_list "$cidrs_cloudflare" "CloudFlare" | uniq  >> datacenters.csv
get_csv_of_low_and_high_ip_from_cidr_list "$cidrs_gcp" "GCP" | uniq >> datacenters.csv
get_csv_of_low_and_high_ip_from_cidr_list "$cidrs_azure" "Azure" | uniq >> datacenters.csv

echo "Success!"