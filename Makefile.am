AUTOMAKE_OPTIONS = no-dist-gzip dist-lzip

osname=$(subst ganeti-instance-,,$(PACKAGE))
osdir=$(OS_DIR)/$(osname)
variantsdir=$(DESTDIR)$(VARIANTSDIR)

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
	-e 's,[@]BLOCKDEV[@],$(BLOCKDEV),g' \
	-e 's,[@]GUIX[@],$(GUIX),g' \
	-e 's,[@]GCROOTSDIR[@],$(GCROOTSDIR),g' \
	-e 's,[@]VARIANTSDIR[@],$(VARIANTSDIR),g' \
	-e 's,[@]QEMU_IMG[@],$(QEMU_IMG),g'

common.sh: common.sh.in Makefile
	$(do_subst) < $< > $@

# End users should place variants.list in $variantsdir.
install-exec-local:
	$(MKDIR_P) $(osdir)
	$(LN_S) $(variantsdir)/variants.list $(osdir)/variants.list

CLEANFILES = common.sh
