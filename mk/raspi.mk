ifeq ($(ARCH),aarch64)
else ifeq ($(ARCH),armhf)
else ifeq ($(ARCH),armv7)
else
  $(error $(ARCH) is unsupported on the raspi platform)
endif

PLATFORM_PHONYS := partition kernel
KERNEL_FLAVOR := rpi
KERNEL_PKG := linux-$(KERNEL_FLAVOR)
PLATFORM_PKGS := $(KERNEL_PKG)

BOOTFS_PART := 1
ROOTFS_PART := 2

RUNLEVEL_BOOT ?= modules bootmisc hostname networking seedrng swap
RUNLEVEL_DEFAULT ?= crond

partition: blkcheck
	$(DOSU) fdisk $(BLKDEV) <<<$$'o\nw\n'
	$(DOSU) sfdisk $(BLKDEV) <<<$$',1G,c,*\n,,83,\n'
