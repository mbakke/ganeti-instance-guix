set -e

. ./common.sh

DISK_IMAGE="$(mktemp)"
CLEANUP+="rm $DISK_IMAGE"

fallocate -l 1GiB "$DISK_IMAGE"

# ext support is mandatory.
format_device "$DISK_IMAGE" ext4

if [ -x "$MKFS_BTRFS" ]; then
    format_device "$DISK_IMAGE" btrfs
fi

if [ -x "$MKFS_XFS" ]; then
    format_device "$DISK_IMAGE" xfs
fi

if [ -x "$MKFS_F2FS" ]; then
    format_device "$DISK_IMAGE" f2fs
fi

! format_device "$DISK_IMAGE" unknown-fs
