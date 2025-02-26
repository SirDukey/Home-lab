#!/bin/bash

# Update zabbix components to latest version

set -e

GREEN="\033[32m"
YELLOW="\033[33m"
WHITE="\033[1;37m"
BLUE='\033[0;34m'
NC="\033[0m"

if [ -z "$1" ]; then
    echo -e "${YELLOW}A required argument is missing${NC}"
    echo -e "${YELLOW}Usage:${NC} ${WHITE}scripts/zabbix/update.sh${NC} ${BLUE}plan|apply${NC}"
    exit 1
fi

OPTION=$1
if [ "$OPTION" == "plan" ]; then
    apt list --upgradable | grep zabbix
    echo -e "${YELLOW}To upgrade run with ${NC} ${WHITE}apply${NC} argument"
elif ["$OPTION" == "apply" ]; then
    apt install --only-upgrade zabbix-server-mysql zabbix-sql-scripts zabbix-nginx-conf zabbix-frontend-php zabbix-agent2
    echo -e "${GREEN}Zabbix packages have been upgraded${NC}"
fi
