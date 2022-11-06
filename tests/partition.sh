#!/bin/sh

set -e

if [ "$(id -u)" != "0" ]; then
    exit 77
fi

. ./common.sh

DISK_IMAGE="$(mktemp)"
CLEANUP+="rm $DISK_IMAGE"

fallocate -l 1GiB "$DISK_IMAGE"

mapped_device=$(losetup_device "$DISK_IMAGE")
CLEANUP+=("${LOSETUP} -d $mapped_device")

partition_device "$mapped_device"
test 2 == $(parted -j "$mapped_device" print | jq '.disk.partitions | length')

partition_device "$mapped_device" "500MiB"
test "497MiB" == $(parted -j "$mapped_device" unit MiB print \
                       | jq -r '.disk.partitions[] | select(.number==2).size')
