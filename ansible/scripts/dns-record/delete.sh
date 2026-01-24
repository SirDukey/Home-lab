#!/bin/bash

# Use this script to delete a dns record

set -e

GREEN="\033[32m"
YELLOW="\033[33m"
WHITE="\033[1;37m"
BLUE='\033[0;34m'
NC="\033[0m"

if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${YELLOW}A required argument is missing${NC}"
    echo -e "${YELLOW}Usage:${NC} ${WHITE}scripts/dns-record/delete.sh${NC} ${BLUE}name type${NC}"
    echo -e "${YELLOW}Option:${NC} ${WHITE}--external${NC} ${BLUE}deletes the external DNS domain${NC}"
    echo -e "${YELLOW}Examples:${NC} ${BLUE}delete.sh es-01 A${NC}"
    echo -e "${YELLOW}         ${NC} ${BLUE}delete.sh es-01 CNAME${NC}"
    exit 1
fi

VARIABLE_FILE=group_vars/all.sops.yaml
DNS_TSIG_KEY=$(sops -d $VARIABLE_FILE | grep bind__tsig_key__enc | awk '{print $2}')
SERVER=$(grep global_primary_nameserver $VARIABLE_FILE | awk '{print $2}')

if [ "$4" == "--external" ]; then
  DOMAIN=$(grep external_dns_domain $VARIABLE_FILE | awk '{print $2}')
else
  DOMAIN=$(grep global_dns_domain $VARIABLE_FILE | awk '{print $2}')
fi

cat << EOF | nsupdate -y hmac-sha256:nameserver:$DNS_TSIG_KEY
server $SERVER
update delete $1.$DOMAIN $2
send
EOF

dig $1.$DOMAIN @$SERVER
echo -e "${GREEN}Record has been deleted${NC}"