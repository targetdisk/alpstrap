ARCH ?= x86_64
PLATFORM ?= uefi
DESTROOT ?= destroot
REPO ?= repo
DOSU ?= sudo
ALPINE_REPO ?= https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/
PKGS ?=
BUSYBOX ?= busybox
APORTSDIR ?= $(APORTS_MODULE)
SHELL := /usr/bin/env bash
BLKDEV ?=
ROOTFS_TYPE ?= btrfs
MOUNTPOINT ?= mnt

RUNLEVEL_SYSINIT ?= devfs dmesg mdev hwdrivers
RUNLEVEL_SHUTDOWN ?= killprocs mount-ro savecache

ifeq ($(PLATFORM),raspi)
  include mk/raspi.mk
else ifeq ($(PLATFORM),uefi)
  include mk/uefi.mk
endif

RUNLEVEL_BOOT_CMDS := $(foreach SERVICE,$(RUNLEVEL_BOOT),\
		      rc-update add $(SERVICE) boot &&)
RUNLEVEL_SYSINIT_CMDS := $(foreach SERVICE,$(RUNLEVEL_SYSINIT),\
		      rc-update add $(SERVICE) sysinit &&)
RUNLEVEL_DEFAULT_CMDS := $(foreach SERVICE,$(RUNLEVEL_DEFAULT),\
		      rc-update add $(SERVICE) default &&)
RUNLEVEL_SHUTDOWN_CMDS := $(foreach SERVICE,$(RUNLEVEL_SHUTDOWN),\
		      rc-update add $(SERVICE) shutdown &&)

RUNLEVEL_CMDS := $(RUNLEVEL_BOOT_CMDS) $(RUNLEVEL_SYSINIT_CMDS) \
		 $(RUNLEVEL_DEFAULT_CMDS) $(RUNLEVEL_SHUTDOWN_CMDS) :

ifneq (,$(findstring /dev/mmcblk,$(BLKDEV)))
  P := p
else ifneq (,$(findstring /dev/nvme,$(BLKDEV)))
  P := p
else
  P :=
endif

GIMME_MODULE := git submodule update --init --recursive

ABUILD_MODULE := modules/abuild
ARCH_MODULE := modules/arch-install-scripts
APK_MODULE := modules/apk-tools
APORTS_MODULE := modules/aports
BASH_UTIL_MODULE := modules/bash-util

ABUILD_SCRIPT := $(ABUILD_MODULE)/abuild
APK_BIN := $(APK_MODULE)/src/apk

ABUILD := $(BUSYBOX) ash $(CURDIR)/$(ABUILD_SCRIPT) -c -P $(CURDIR)/$(REPO) rootbld
ACHROOT := $(ARCH_MODULE)/arch-chroot
ACHROOT_CMD := $(DOSU) $(ACHROOT) $(DESTROOT) /bin/sh -c '. /etc/profile'
APK := LD_LIBRARY_PATH=$(APK_MODULE)/src $(APK_BIN)
BUTIL := . $(BASH_UTIL_MODULE)

default-target: install

### TOOLS ###

tools: $(ACHROOT) $(APK_BIN) $(ABUILD_SCRIPT)

$(ARCH_MODULE)/Makefile: .gitmodules
	$(GIMME_MODULE) -- $(ARCH_MODULE)

$(ACHROOT): $(ARCH_MODULE)/Makefile
	$(MAKE) -j -C $(ARCH_MODULE) arch-chroot

$(APK_MODULE)/Makefile: .gitmodules
	$(GIMME_MODULE) -- $(APK_MODULE)

$(APK_BIN): $(APK_MODULE)/Makefile
	$(MAKE) -j -C $(APK_MODULE)

$(ABUILD_MODULE)/Makefile: .gitmodules
	$(GIMME_MODULE) -- $(ABUILD_MODULE)

$(ABUILD_SCRIPT): $(ABUILD_MODULE)/Makefile
	$(MAKE) -j -C $(ABUILD_MODULE) all

$(BASH_UTIL_MODULE)/Makefile: .gitmodules
	$(GIMME_MODULE) -- $(BASH_UTIL_MODULE)

### PORTS TREE ###

$(APORTS_MODULE)/README.md: .gitmodules
	$(GIMME_MODULE) -- $(APORTS_MODULE)

aports: $(APORTS_MODULE)/README.md

### REPO BUILDING ###

# Something will go here...

### BOOTSTRAPPING ###

$(DESTROOT):
	mkdir -p $(DESTROOT) || $(DOSU) mkdir -p $(DESTROOT)

$(DESTROOT)/.bootstrap-done: $(DESTROOT) $(APK_BIN)
	$(DOSU) $(APK) --arch $(ARCH) -X $(ALPINE_REPO) --root $(DESTROOT) \
		-U --allow-untrusted --initdb add alpine-keys $(PKGS) && touch $@
	$(DOSU) $(APK) --arch $(ARCH) -X $(ALPINE_REPO) --root $(DESTROOT) \
		add alpine-base btrfs-progs e2fsprogs $(PKGS) && touch $@

bootstrap: $(DESTROOT)/.bootstrap-done

### PARTITIONING ###

blkcheck: $(BASH_UTIL_MODULE)/Makefile
	@[ -z "$(BLKDEV)" ] && $(BUTIL)/logging.bash \
		&& die 'ERROR: Must define BLKDEV env variable!' \
		|| :

format: partition
	$(DOSU) mkfs.vfat $(BLKDEV)$(P)1
	$(DOSU) mkfs.$(ROOTFS_TYPE) $(BLKDEV)$(P)2

$(BLKDEV)$(P)2: partition

### INSTALLATION ###

services: $(DESTROOT)/.bootstrap-done $(ACHROOT)
	$(ACHROOT_CMD)' && $(RUNLEVEL_CMDS)'

fastest-repo: $(DESTROOT)/.bootstrap-done $(ACHROOT)
	$(ACHROOT_CMD)' && setup-apkrepos -f'

$(MOUNTPOINT):
	mkdir -p $@ || $(DOSU) mkdir -p $@

mount: $(BLKDEV)$(P)2 $(MOUNTPOINT)
	$(DOSU) mount $(BLKDEV)$(P)2 $(MOUNTPOINT)
	$(DOSU) mkdir -p $(MOUNTPOINT)/boot
	$(DOSU) mount $(BLKDEV)$(P)1 $(MOUNTPOINT)/boot

install: services fastest-repo

### CLEANLINESS ###
clean:
	git submodule deinit -f -- \
		$(APK_MODULE) $(ABUILD_MODULE) $(APORTS_MODULE) $(ARCH_MODULE) \
		$(BASH_UTIL_MODULE)
	$(DOSU) umount mnt/boot || :
	$(DOSU) umount mnt || :
	$(DOSU) rm -rf destroot/* repo/*

### MAKEY-MAKEY ###

.PHONY: default-target tools bootstrap aports blkcheck format install \
	$(PLATFORM_PHONYS)
