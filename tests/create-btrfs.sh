touch /tmp/mydisk ; fallocate -l 10GiB /tmp/mydisk
INSTANCE_NAME=test \
NIC_0_IP=192.168.1.2 \
NIC_0_NETWORK_SUBNET=192.168.1.2/24 \
NIC_0_NETWORK_GATEWAY=192.168.1.5 \
DISK_COUNT=1 \
DISK_0_PATH=/tmp/mydisk \
OSP_LAYOUT=standard OSP_FILESYSTEM=btrfs \
VARIANT_CONFIG=$(pwd)/examples/dynamic-btrfs.scm \
./create