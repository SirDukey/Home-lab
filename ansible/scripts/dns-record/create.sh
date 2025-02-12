#!/bin/bash

YELLOW="\033[33m"
WHITE="\033[1;37m"
BLUE='\033[0;34m'
NC="\033[0m"

if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${YELLOW}A required argument is missing${NC}"
    echo -e "${YELLOW}Usage:${NC} ${WHITE}scripts/dns-record/create.sh${NC} ${BLUE}name ipv4${NC}"
    exit 1
fi

DNS_TSIG_KEY=$(sops -d group_vars/all.sops.yaml | grep bind__tsig_key__enc | awk '{print $2}')

cat << EOF | nsupdate -y hmac-sha512:nameserver:$DNS_TSIG_KEY
server 192.168.1.53
update delete $1.duke.lan A
update add $1.duke.lan 86400 A $2
send
EOF

