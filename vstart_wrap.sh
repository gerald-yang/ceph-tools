if [ "$1" = "new" ]; then
	OSD=3 MON=3 MDS=2 MGR=1 RGW=1 ./vstart.sh -n --rgw_port 7480 --rgw_frontend civetweb -b
	exit 0
fi
OSD=3 MON=3 MDS=2 MGR=1 RGW=1 ./vstart.sh --rgw_port 7480 --rgw_frontend civetweb -b
