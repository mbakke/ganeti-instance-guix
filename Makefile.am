osname=$(subst ganeti-instance-,,$(PACKAGE))
osdir=$(OS_DIR)/$(osname)
variantsdir=$(DESTDIR)$(VARIANTSDIR)

dist_os_SCRIPTS = create import export rename verify
dist_os_DATA = ganeti_api_version parameters.list
os_DATA = common.sh

TESTS = 					\
	tests/cleanup.sh			\
	tests/create.sh				\
	tests/file-system.sh			\
	tests/partition.sh

TEST_EXTENSIONS = .sh
SH_LOG_COMPILER = $(SHELL)

dist_doc_DATA = COPYING NEWS README.md

exampledir = $(docdir)/examples

dist_example_DATA = \
	examples/config-base.scm \
	examples/dynamic.scm \
	examples/generic.scm \
	examples/hurd.scm

EXTRA_DIST = \
	$(TESTS)				\
	common.sh.in

do_subst = $(SED) \
	-e 's,[@]EXAMPLEDIR[@],$(exampledir),g' \
	-e 's,[@]localstatedir[@],$(localstatedir),g' \
	-e 's,[@]GUIX[@],$(GUIX),g' \
	-e 's,[@]GCROOTSDIR[@],$(GCROOTSDIR),g' \
	-e 's,[@]VARIANTSDIR[@],$(VARIANTSDIR),g' \
	-e 's,[@]QEMU_IMG[@],$(QEMU_IMG),g' \
	-e 's,[@]MOUNT[@],$(MOUNT),g' \
	-e 's,[@]UMOUNT[@],$(UMOUNT),g' \
	-e 's,[@]FALLOCATE[@],$(FALLOCATE),g' \
	-e 's,[@]MKSWAP[@],$(MKSWAP),g' \
	-e 's,[@]CHATTR[@],$(CHATTR),g' \
	-e 's,[@]MKE2FS[@],$(MKE2FS),g' \
	-e 's,[@]PARTED[@],$(PARTED),g' \
	-e 's,[@]BTRFS[@],$(BTRFS),g' \
	-e 's,[@]MKFS_BTRFS[@],$(MKFS_BTRFS),g' \
	-e 's,[@]MKFS_F2FS[@],$(MKFS_F2FS),g' \
	-e 's,[@]MKFS_XFS[@],$(MKFS_XFS),g' \
	-e 's,[@]KPARTX[@],$(KPARTX),g' \
	-e 's,[@]PVCREATE[@],$(PVCREATE),g' \
	-e 's,[@]VGCREATE[@],$(VGCREATE),g' \
	-e 's,[@]VGCHANGE[@],$(VGCHANGE),g' \
	-e 's,[@]LVCREATE[@],$(LVCREATE),g' \
	-e 's,[@]LOSETUP[@],$(LOSETUP),g' \
	-e 's,[@]BLKID[@],$(BLKID),g' \
	-e 's,[@]WIPEFS[@],$(WIPEFS),g' \
	-e 's,[@]CRYPTSETUP[@],$(CRYPTSETUP),g'

common.sh: common.sh.in Makefile
	$(do_subst) < $< > $@

examples/%.scm: examples/%.scm.in Makefile
	$(do_subst) < $< > $@

# End users should place variants.list in $variantsdir.
install-exec-local:
	$(MKDIR_P) $(osdir)
	$(LN_S) $(variantsdir)/variants.list $(osdir)/variants.list

CLEANFILES = common.sh
