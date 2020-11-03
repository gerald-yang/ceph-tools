#!/bin/bash

NUM_MON=1
NUM_MGR=1
NUM_OSD=3
NUM_RGW=2
NUM_MDS=0
FRONTEND="civetweb"

if [ "$1" = "-o" ]; then
	OSD="$NUM_OSD" MON="$NUM_MON" MDS="$NUM_MDS" MGR="$NUM_MGR" RGW="$NUM_RGW" ../src/vstart.sh --rgw_port 7480 --rgw_frontend "$FRONTEND" -b
elif [ "$1" = "-k" ]; then
	OSD="$NUM_OSD" MON="$NUM_MON" MDS="$NUM_MDS" MGR="$NUM_MGR" RGW="$NUM_RGW" ../src/vstart.sh -n -k --rgw_port 7480 --rgw_frontend "$FRONTEND" -b
elif [ "$1" = "--crimson" ]; then
	MDS="$NUM_MDS" MGR="$NUM_MGR" OSD="$NUM_OSD" MON="$NUM_MON" ../src/vstart.sh -n --without-dashboard --memstore -X -o "memstore_device_bytes=4294967296" --nolockdep --crimson --nodaemon --redirect-output
else
	OSD="$NUM_OSD" MON="$NUM_MON" MDS="$NUM_MDS" MGR="$NUM_MGR" RGW="$NUM_RGW" ../src/vstart.sh -n --rgw_port 7480 --rgw_frontend "$FRONTEND" -b
fi
