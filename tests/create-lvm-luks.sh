#!/bin/sh

if [ "$(id -u)" != "0" ]; then
    exit 77
fi

DISK_IMAGE="$(mktemp)"
fallocate -l 10GiB "$DISK_IMAGE"

export CACHE_DIR=/tmp/test-cache
export GCROOTSDIR=/tmp/test-gcroots

INSTANCE_NAME=create-lvm-luks \
NIC_0_IP=192.168.1.2 \
NIC_0_NETWORK_SUBNET=192.168.1.2/24 \
NIC_0_NETWORK_GATEWAY=192.168.1.5 \
DISK_COUNT=1 \
DISK_0_PATH="$DISK_IMAGE" \
OSP_LAYOUT=advanced OSP_FILESYSTEM=ext4 \
VARIANT_CONFIG=$(pwd)/examples/dynamic-lvm-luks.scm \
LUKS_PASSPHRASE=password \
./create

status="$?"

rm "$DISK_IMAGE"
exit $status
