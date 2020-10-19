#!/bin/bash

NODE1="node-1"
NODE1_DISK="/dev/sdc"
NODE2="node-2"
NODE2_DISK="/dev/sdc"
NODE3="node-3"
NODE3_DISK="/dev/sdc"

if [ "$1" = "re" ]; then
	ceph-deploy purge "$NODE1"
	ceph-deploy purge "$NODE2"
	ceph-deploy purge "$NODE3"
	ceph-deploy purgedata "$NODE1"
	ceph-deploy purgedata "$NODE2"
	ceph-deploy purgedata "$NODE3"
	ceph-deploy forgetkeys
	rm -f ceph.*
	ceph_dev=$(ssh "$NODE1" dmsetup ls | grep ceph | awk '{print $1}')
	if ! [ -z "$ceph_dev" ]; then
		echo "remove device mapper: $ceph_dev"
		ssh "$NODE1" dmsetup remove "$ceph_dev"
	fi
	ceph_dev=$(ssh "$NODE2" dmsetup ls | grep ceph | awk '{print $1}')
	if ! [ -z "$ceph_dev" ]; then
		echo "remove device mapper: $ceph_dev"
		ssh "$NODE2" dmsetup remove "$ceph_dev"
	fi
	ceph_dev=$(ssh "$NODE3" dmsetup ls | grep ceph | awk '{print $1}')
	if ! [ -z "$ceph_dev" ]; then
		echo "remove device mapper: $ceph_dev"
		ssh "$NODE3" dmsetup remove "$ceph_dev"
	fi
	ssh "$NODE1" dd if=/dev/zero of="$NODE1_DISK" bs=1M count=100
	ssh "$NODE2" dd if=/dev/zero of="$NODE2_DISK" bs=1M count=100
	ssh "$NODE3" dd if=/dev/zero of="$NODE3_DISK" bs=1M count=100
fi

ceph-deploy new "$NODE1" "$NODE2" "$NODE3"
if [ "$1" != "re" ]; then
	mv /etc/yum.repos.d/ceph.repo /etc/yum.repos.d/ceph.repo.bak
fi
ceph-deploy install "$NODE1"
ceph-deploy install "$NODE2"
ceph-deploy install "$NODE3"
ceph-deploy mon create-initial
ceph-deploy admin "$NODE1"
ceph-deploy admin "$NODE2"
ceph-deploy admin "$NODE3"
ceph-deploy mgr create "$NODE1"
ceph-deploy osd create --data "$NODE1_DISK" "$NODE1"
ceph-deploy osd create --data "$NODE2_DISK" "$NODE2"
ceph-deploy osd create --data "$NODE3_DISK" "$NODE3"

# if mgr failed to start, could be two Werkzeug versions installed
#pip uninstall Werkzeug
#pip install Werkzeug

