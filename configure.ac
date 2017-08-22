AC_INIT(ganeti-instance-guix, 0.1)

AC_CONFIG_AUX_DIR(build-aux)
AC_CONFIG_SRCDIR(configure)

AM_INIT_AUTOMAKE

# --with-os-dir=...
AC_ARG_WITH([os-dir],
  [AS_HELP_STRING([--with-os-dir=DIR],
    [top-level OS directory under which to install]
    [ (default is $datadir/ganeti/os)]
  )],
  [os_dir="$withval"],
  [os_dir="$datadir/ganeti/os"])
AC_SUBST(OS_DIR, $os_dir)

# Check common programs
AC_PROG_INSTALL

# Check for the required programs
ROOT_PATH=[$PATH$PATH_SEPARATOR/sbin$PATH_SEPARATOR/usr/sbin]dnl
[$PATH_SEPARATOR/usr/local/bin]

AC_ARG_VAR(BLOCKDEV, [blockdev path])
AC_PATH_PROG(BLOCKDEV, [blockdev], [], [$ROOT_PATH])
if test -z "$BLOCKDEV"
then
  AC_MSG_ERROR([blockdev not found, please install util-linux])
fi

AC_ARG_VAR(GUIX, [guix path])
AC_PATH_PROG(GUIX, [guix], [], [$ROOT_PATH])
if test -z "$GUIX"
then
  AC_MSG_ERROR([guix command not found])
fi

AC_ARG_VAR(QEMU_IMG, [qemu-img path])
AC_PATH_PROG(QEMU_IMG, [qemu-img], [], [$ROOT_PATH])
if test -z "$QEMU_IMG"
then
  AC_MSG_ERROR([qemu-img command not found])
fi

AC_CONFIG_FILES([ Makefile ])

AC_OUTPUT
