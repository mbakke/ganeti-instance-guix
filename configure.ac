AC_INIT(ganeti-instance-guix, 0.6.1)

AC_CONFIG_AUX_DIR(build-aux)
AC_CONFIG_SRCDIR(configure)

AM_INIT_AUTOMAKE([foreign -Wall -Wno-portability])

# --with-os-dir=...
AC_ARG_WITH([os-dir],
  [AS_HELP_STRING([--with-os-dir=DIR],
    [top-level OS directory under which to install]
    [ (default is $datadir/ganeti/os)]
  )],
  [os_dir="$withval"],
  [os_dir="$datadir/ganeti/os"])
AC_SUBST(OS_DIR, $os_dir)

AC_ARG_WITH([variantsdir],
  [AS_HELP_STRING([--with-variantsdir=DIR],
    [where variants are expected to be found]
    [ (default is $sysconfdir/ganeti/instance-guix/variants)]
  )],
  [variantsdir="$withval"],
  [variantsdir="$sysconfdir/ganeti/instance-guix/variants"])
AC_SUBST(VARIANTSDIR, $variantsdir)

AC_ARG_WITH([guix],
  [AS_HELP_STRING([--with-guix=GUIX],
    [the Guix executable to use at run-time]
    [ (default is the root users Guix)]
  )],
  [guix="$withval"],
  [guix="$localstatedir/guix/profiles/per-user/root/current-guix/bin/guix"])
AC_SUBST(GUIX, $guix)

AC_ARG_WITH([gcrootsdir],
  [AS_HELP_STRING([--with-gcrootsdir=DIR],
    [where to store GC roots for the built system configurations]
    [ (default is $localstatedir/guix/gcroots/ganeti/instance-guix)]
  )],
  [gcrootsdir="$withval"],
  [gcrootsdir="$localstatedir/guix/gcroots/ganeti/instance-guix"])
AC_SUBST(GCROOTSDIR, $gcrootsdir)

# Check common programs
AC_PROG_INSTALL
AC_PROG_MKDIR_P
AC_PROG_LN_S
AC_PROG_SED

# Check for the required programs
AC_ARG_VAR(MOUNT, [mount path])
AC_PATH_PROG(MOUNT, [mount])
if test -z "$MOUNT"
then
  AC_MSG_ERROR([mount not found, please install util-linux])
fi

AC_ARG_VAR(UMOUNT, [umount path])
AC_PATH_PROG(UMOUNT, [umount])
if test -z "$UMOUNT"
then
  AC_MSG_ERROR([umount not found, please install util-linux])
fi

AC_ARG_VAR(FALLOCATE, [fallocate path])
AC_PATH_PROG(FALLOCATE, [fallocate])
if test -z "$FALLOCATE"
then
  AC_MSG_ERROR([fallocate not found, please install util-linux])
fi

AC_ARG_VAR(MKSWAP, [mkswap path])
AC_PATH_PROG(MKSWAP, [mkswap])
if test -z "$MKSWAP"
then
  AC_MSG_ERROR([mkswap not found, please install util-linux])
fi

AC_ARG_VAR(LOSETUP, [losetup path])
AC_PATH_PROG(LOSETUP, [losetup])
if test -z "$LOSETUP"
then
  AC_MSG_ERROR([losetup not found])
fi

AC_ARG_VAR(SFDISK, [sfdisk path])
AC_PATH_PROG(SFDISK, [sfdisk])
if test -z "$SFDISK"
then
  AC_MSG_ERROR([sfdisk not found])
fi

AC_ARG_VAR(CHATTR, [chattr path]) # e2fsprogs also covers mkfs.ext{2,3,4}
AC_PATH_PROG(CHATTR, [chattr])
if test -z "$CHATTR"
then
  AC_MSG_ERROR([chattr not found, please install e2fsprogs])
fi

AC_ARG_VAR(JQ, [jq path])
AC_PATH_PROG(JQ, [jq])
if test -z "$JQ"
then
  AC_MSG_ERROR([jq not found, please install jq])
fi

AC_ARG_VAR(PARTED, [parted path])
AC_PATH_PROG(PARTED, [parted])
if test -z "$PARTED"
then
  AC_MSG_ERROR([parted not found, please install parted])
fi

AC_ARG_VAR(BTRFS, [btrfs path])
AC_PATH_PROG(BTRFS, [btrfs], btrfs)

AC_PATH_PROG(MKFS_BTRFS, [mkfs.btrfs], mkfs.btrfs)
AC_PATH_PROG(MKFS_XFS, [mkfs.xfs], mkfs.xfs)
AC_PATH_PROG(MKFS_EXT2, [mkfs.ext2], mkfs.ext2)
AC_PATH_PROG(MKFS_EXT3, [mkfs.ext3], mkfs.ext3)
AC_PATH_PROG(MKFS_EXT4, [mkfs.ext4], mkfs.ext4)

AC_ARG_VAR(KPARTX, [kpartx path])
AC_PATH_PROG(KPARTX, [kpartx])
if test -z "$KPARTX"
then
  AC_MSG_ERROR([kpartx not found, please install multipath-tools])
fi

AC_ARG_VAR(PVCREATE, [pvcreate path])
AC_PATH_PROG(PVCREATE, [pvcreate], pvcreate)

AC_ARG_VAR(VGCREATE, [vgcreate path])
AC_PATH_PROG(VGCREATE, [vgcreate], vgcreate)

AC_ARG_VAR(VGREMOVE, [vgremove path])
AC_PATH_PROG(VGREMOVE, [vgremove], vgremove)

AC_ARG_VAR(LVCREATE, [lvcreate path])
AC_PATH_PROG(LVCREATE, [lvcreate], lvcreate)

AC_CONFIG_FILES([ Makefile ])

AC_OUTPUT
