#!/bin/bash

# Use this script to create a dns record

set -e

GREEN="\033[32m"
YELLOW="\033[33m"
WHITE="\033[1;37m"
BLUE='\033[0;34m'
NC="\033[0m"

if [ -z "$1" ] || [ -z "$2" ] || [ -x "$3" ]; then
    echo -e "${YELLOW}A required argument is missing${NC}"
    echo -e "${YELLOW}Usage:${NC} ${WHITE}scripts/dns-record/create.sh${NC} ${BLUE}record ipv4|record type${NC}"
    echo -e "${YELLOW}Examples:${NC} ${BLUE}create.sh es-01 192.168.1.55 A${NC}"
    echo -e "${YELLOW}         ${NC} ${BLUE}create.sh es-01 elastic CNAME${NC}"
    exit 1
fi

VARIABLE_FILE=group_vars/all.sops.yaml
DNS_TSIG_KEY=$(sops -d $VARIABLE_FILE | grep bind__tsig_key__enc | awk '{print $2}')
SERVER=$(grep global_primary_nameserver $VARIABLE_FILE | awk '{print $2}')
DOMAIN=$(grep global_dns_domain $VARIABLE_FILE | awk '{print $2}')
RECORD_TYPE=$3
RECORD_1=$1.$DOMAIN
if [ $RECORD_TYPE == "CNAME" ]; then
  RECORD_2=$2.$DOMAIN
else
  RECORD_2=$2
fi

cat << EOF | nsupdate -y hmac-sha512:nameserver:$DNS_TSIG_KEY
server $SERVER
update delete $RECORD_1 $RECORD_TYPE
update add $RECORD_1 86400 $RECORD_TYPE $RECORD_2
send
EOF

dig $RECORD_1 @$SERVER
echo -e "${GREEN}Record has been added/udpdated${NC}"