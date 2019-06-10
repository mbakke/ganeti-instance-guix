AC_INIT(ganeti-instance-guix, 0.3.1)

AC_CONFIG_AUX_DIR(build-aux)
AC_CONFIG_SRCDIR(configure)

AM_INIT_AUTOMAKE([foreign])

# --with-os-dir=...
AC_ARG_WITH([os-dir],
  [AS_HELP_STRING([--with-os-dir=DIR],
    [top-level OS directory under which to install]
    [ (default is $datadir/ganeti/os)]
  )],
  [os_dir="$withval"],
  [os_dir="$datadir/ganeti/os"])
AC_SUBST(OS_DIR, $os_dir)

AC_ARG_WITH([guix],
  [AS_HELP_STRING([--with-guix=GUIX],
    [the Guix executable to use at run-time]
    [ (default is the root users Guix)]
  )],
  [guix="$withval"],
  [guix="$localstatedir/guix/profiles/per-user/root/current-guix/bin/guix"])
AC_SUBST(GUIX, $guix)

AC_ARG_WITH([guixprofiledir],
  [AS_HELP_STRING([--with-guixprofiledir=DIR],
    [where to store the instance-specific Guix profiles]
    [ (default is $sysconfdir/ganeti/instance-guix/profiles)]
  )],
  [guixprofiledir="$withval"],
  [guixprofiledir="$sysconfdir/ganeti/instance-guix/profiles"])
AC_SUBST(GUIXPROFILEDIR, $guixprofiledir)

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
