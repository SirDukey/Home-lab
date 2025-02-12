#!/bin/bash

# This script will remove Ceph from the node, run it on all the nodes to completely remove Ceph from the cluster

RED="\033[31m"
YELLOW="\033[33m"
WHITE="\033[1;37m"
NC="\033[0m"

echo -e "${RED}Warning: ${YELLOW}This script will completely remove ${WHITE}Ceph${NC} ${YELLOW}from the system${NC}"
echo -e "${YELLOW}Continue: ${WHITE}y/n${NC}"
read CONTINUE
if [ "$CONTINUE" == "y" ]; then
  echo -e "${WHITE}REMOVING CEPH...${NC}"
  systemctl stop ceph-mon.target
  systemctl stop ceph-mgr.target
  systemctl stop ceph-mds.target
  systemctl stop ceph-osd.target
  rm -rf /etc/systemd/system/ceph*
  killall -9 ceph-mon ceph-mgr ceph-mds
  rm -rf /var/lib/ceph/mon/  /var/lib/ceph/mgr/  /var/lib/ceph/mds/
  pveceph purge
  apt purge ceph-mon ceph-osd ceph-mgr ceph-mds
  apt purge ceph-base ceph-mgr-modules-core
  rm -rf /etc/ceph/*
  rm -rf /etc/pve/ceph.conf
  rm -rf /etc/pve/priv/ceph.*
else
  echo "not going ahead, bye"
  exit 0
fi


