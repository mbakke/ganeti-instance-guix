# root is required for losetup, et.al.
if [ "$(id -u)" != "0" ]; then
    exit 77
fi

set -e

# Create a disk image for testing.
DISK_IMAGE="$(mktemp)"
CLEANUP+=("rm $DISK_IMAGE")
fallocate -l 10GiB "$DISK_IMAGE"

# Use distinct cache directories.
export CACHE_DIR=/tmp/test-cache
export GCROOTSDIR=/tmp/test-gcroots

# Configure the required variables.
export NIC_0_IP=192.168.1.2
export NIC_0_NETWORK_SUBNET=192.168.1.2/24
export NIC_0_NETWORK_GATEWAY=192.168.1.5
export DISK_COUNT=1
export DISK_0_PATH="$DISK_IMAGE"
export OSP_LAYOUT=basic
export OSP_FILESYSTEM=ext4
export VARIANT_CONFIG=$(pwd)/examples/dynamic.scm

# Create the default configuration.
INSTANCE_NAME=create-default ./create
INSTANCE_NAME=create-luks LUKS_PASSPHRASE=password ./create

# Advanced layouts.
export OSP_LAYOUT=advanced

export VARIANT_CONFIG=$(pwd)/examples/dynamic-lvm.scm
INSTANCE_NAME=create-lvm ./create
INSTANCE_NAME=create-lvm-luks LUKS_PASSPHRASE=password ./create

export VARIANT_CONFIG=$(pwd)/examples/dynamic-btrfs.scm
export OSP_FILESYSTEM=btrfs
INSTANCE_NAME=create-btrfs ./create
INSTANCE_NAME=create-btrfs-luks LUKS_PASSPHRASE=password ./create

# TODO: Boot these images..!
