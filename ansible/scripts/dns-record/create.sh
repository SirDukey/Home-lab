#!/bin/bash

set -e

GREEN="\033[32m"
YELLOW="\033[33m"
WHITE="\033[1;37m"
BLUE='\033[0;34m'
NC="\033[0m"

if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${YELLOW}A required argument is missing${NC}"
    echo -e "${YELLOW}Usage:${NC} ${WHITE}scripts/dns-record/create.sh${NC} ${BLUE}name ipv4${NC}"
    exit 1
fi

VARIABLE_FILE=group_vars/all.sops.yaml
DNS_TSIG_KEY=$(sops -d $VARIABLE_FILE | grep bind__tsig_key__enc | awk '{print $2}')
SERVER=$(grep global_primary_nameserver $VARIABLE_FILE | awk '{print $2}')
DOMAIN=$(grep global_dns_domain $VARIABLE_FILE | awk '{print $2}')

cat << EOF | nsupdate -y hmac-sha512:nameserver:$DNS_TSIG_KEY
server $SERVER
update delete $1.$DOMAIN A
update add $1.$DOMAIN 86400 A $2
send
EOF

dig $1.$DOMAIN @$SERVER
echo -e "${GREEN}Record has been added/udpdated${NC}"