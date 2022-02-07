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

# Check for the required programs
AC_ARG_VAR(BLOCKDEV, [blockdev path])
AC_PATH_PROG(BLOCKDEV, [blockdev])
if test -z "$BLOCKDEV"
then
  AC_MSG_ERROR([blockdev not found, please install util-linux])
fi

AC_ARG_VAR(QEMU_IMG, [qemu-img path])
AC_PATH_PROG(QEMU_IMG, [qemu-img])
if test -z "$QEMU_IMG"
then
  AC_MSG_ERROR([qemu-img command not found])
fi

AC_CONFIG_FILES([ Makefile ])

AC_OUTPUT
