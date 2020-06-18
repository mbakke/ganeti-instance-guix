AUTOMAKE_OPTIONS = no-dist-gzip dist-lzip

osname=$(subst ganeti-instance-,,$(PACKAGE))
osdir=$(OS_DIR)/$(osname)
variantsdir = $(DESTDIR)$(sysconfdir)/ganeti/instance-guix

dist_os_SCRIPTS = create import export rename verify
dist_os_DATA = ganeti_api_version parameters.list
os_DATA = common.sh

dist_doc_DATA = COPYING README

exampledir = $(docdir)/examples

dist_example_DATA = \
	examples/dynamic.scm \
	examples/generic.scm

EXTRA_DIST = \
	common.sh.in

do_subst = sed \
	-e 's,[@]localstatedir[@],$(localstatedir),g' \
	-e 's,[@]variantsdir[@],$(variantsdir),g' \
	-e 's,[@]BLOCKDEV[@],$(BLOCKDEV),g' \
	-e 's,[@]GUIX[@],$(GUIX),g' \
	-e 's,[@]GUIXPROFILEDIR[@],$(GUIXPROFILEDIR),g' \
	-e 's,[@]QEMU_IMG[@],$(QEMU_IMG),g'

common.sh: common.sh.in Makefile
	$(do_subst) < $< > $@

install-exec-local:
	$(MKDIR_P) $(variantsdir)
	$(LN_S) -f $(exampledir)/dynamic.scm $(variantsdir)/default.scm
	$(MKDIR_P) $(GUIXPROFILEDIR)

uninstall-local:
	test -L $(variantsdir)/default.scm && rm -f $(variantsdir)/default.scm || true

CLEANFILES = common.sh
