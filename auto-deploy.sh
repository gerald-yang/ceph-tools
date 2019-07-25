#!/bin/bash

if [ "$1" = "re" ]; then
	ceph-deploy purge node-1
	ceph-deploy purge node-2
	ceph-deploy purge node-3
	ceph-deploy purgedata node-1
	ceph-deploy purgedata node-2
	ceph-deploy purgedata node-3
	ceph-deploy forgetkeys
	rm -f ceph.*
	ceph_dev=$(ssh node-1 dmsetup ls | grep ceph | awk '{print $1}')
	if ! [ -z "$ceph_dev" ]; then
		echo "remove device mapper: $ceph_dev"
		ssh node-1 dmsetup remove "$ceph_dev"
	fi
	ceph_dev=$(ssh node-2 dmsetup ls | grep ceph | awk '{print $1}')
	if ! [ -z "$ceph_dev" ]; then
		echo "remove device mapper: $ceph_dev"
		ssh node-2 dmsetup remove "$ceph_dev"
	fi
	ceph_dev=$(ssh node-3 dmsetup ls | grep ceph | awk '{print $1}')
	if ! [ -z "$ceph_dev" ]; then
		echo "remove device mapper: $ceph_dev"
		ssh node-3 dmsetup remove "$ceph_dev"
	fi
	ssh node-1 dd if=/dev/zero of=/dev/sdc bs=1M count=100
	ssh node-2 dd if=/dev/zero of=/dev/sdc bs=1M count=100
	ssh node-3 dd if=/dev/zero of=/dev/sdc bs=1M count=100
fi

ceph-deploy new node-1 node-2 node-3
if [ "$1" != "re" ]; then
	mv /etc/yum.repos.d/ceph.repo /etc/yum.repos.d/ceph.repo.bak
fi
ceph-deploy install node-1
ceph-deploy install node-2
ceph-deploy install node-3
ceph-deploy mon create-initial
ceph-deploy admin node-1
ceph-deploy admin node-2
ceph-deploy admin node-3
ceph-deploy mgr create node-1
ceph-deploy osd create --data /dev/sdc node-1
ceph-deploy osd create --data /dev/sdc node-2
ceph-deploy osd create --data /dev/sdc node-3

# if mgr failed to start, could be two Werkzeug versions installed
#pip uninstall Werkzeug
#pip install Werkzeug

