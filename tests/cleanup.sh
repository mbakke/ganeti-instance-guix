set -e

if [ "$(id -u)" != "0" ]; then
    exit 77
fi

. ./common.sh

# There have been cases where the loop device is not detached after a create.
# The purpose of this test is to provoke such failure and hopefully find the
# culprit; although I haven't yet been able to reproduce it synthetically.
# Please file a bug report if this test fails for you!

for i in $(seq 1 10); do
    echo "cleanup ext4, trial ${i}/10..."
    DISK_IMAGE="$(mktemp)"
    CLEANUP+=("rm $DISK_IMAGE")
    fallocate -l 200MiB "$DISK_IMAGE"
    MOUNT_POINT="$(mktemp -d)"
    CLEANUP+=("rmdir $MOUNT_POINT")
    mapped=$(losetup_device "$DISK_IMAGE")
    CLEANUP+=("${LOSETUP} -d $mapped")
    partition_device "$mapped"
    partition="${mapped}p2"
    format_device "$partition" "ext4"
    "$MOUNT" "$partition" "$MOUNT_POINT"
    CLEANUP+=("$UMOUNT $MOUNT_POINT")
    dd if=/dev/urandom of="${MOUNT_POINT}/test-file" bs=1M count=50
    cleanup
    ! [ -f "$MOUNT_POINT/test-file" ]
    ! [ -d "$MOUNT_POINT" ]
    ! [ -f "$DISK_IMAGE" ]
    CLEANUP=( )
done

for i in $(seq 1 10); do
    echo "cleanup btrfs+subvolume, trial ${i}/10..."
    DISK_IMAGE="$(mktemp)"
    CLEANUP+=("rm $DISK_IMAGE")
    fallocate -l 200MiB "$DISK_IMAGE"
    MOUNT_POINT="$(mktemp -d)"
    CLEANUP+=("rmdir $MOUNT_POINT")
    mapped=$(losetup_device "$DISK_IMAGE")
    CLEANUP+=("${LOSETUP} -d $mapped")
    partition_device "$mapped"
    partition="${mapped}p2"
    format_device "$partition" "btrfs"
    "$MOUNT" "$partition" "$MOUNT_POINT"
    CLEANUP+=("$UMOUNT $MOUNT_POINT")
    btrfs subvolume create "$MOUNT_POINT/subvol"
    dd if=/dev/urandom of="${MOUNT_POINT}/subvol/test-file" bs=1M count=50
    cleanup
    ! [ -f "$MOUNT_POINT/subvol/test-file" ]
    ! [ -d "$MOUNT_POINT" ]
    ! [ -f "$DISK_IMAGE" ]
    CLEANUP=( )
done

for i in $(seq 1 10); do
    echo "cleanup LVM+LUKS, trial ${i}/10..."
    DISK_IMAGE="$(mktemp)"
    CLEANUP+=("rm $DISK_IMAGE")
    fallocate -l 200MiB "$DISK_IMAGE"
    MOUNT_POINT="$(mktemp -d)"
    CLEANUP+=("rmdir $MOUNT_POINT")
    mapped=$(losetup_device "$DISK_IMAGE")
    CLEANUP+=("${LOSETUP} -d $mapped")
    partition_device "$mapped"
    "${PVCREATE}" --yes -ff "${mapped}p2"
    "${VGCREATE}" test_vg "${mapped}p2"
    CLEANUP+=("${VGCHANGE} -an test_vg")
    "${LVCREATE}" --yes -n test_lv -l 100%FREE -W y test_vg
    LV="/dev/test_vg/test_lv"
    luks_format "$LV" test_password
    luks_open "$LV" test_crypt test_password
    CLEANUP+=("luks_close test_crypt")
    format_device "/dev/mapper/test_crypt" "ext4"
    "$MOUNT" "/dev/mapper/test_crypt" "$MOUNT_POINT"
    CLEANUP+=("$UMOUNT $MOUNT_POINT")
    dd if=/dev/urandom of="${MOUNT_POINT}/test-file" bs=1M count=50
    cleanup
    ! [ -f "$MOUNT_POINT/test-file" ]
    ! [ -e "/dev/mapper/test_crypt" ]
    ! [ -e "$LV" ]
    ! [ -d "/dev/test_vg" ]
    ! [ -e "$mapped" ]
    ! [ -d "$MOUNT_POINT" ]
    ! [ -f "$DISK_IMAGE" ]
    CLEANUP=( )
done
