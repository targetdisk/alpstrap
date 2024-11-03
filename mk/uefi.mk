PLATFORM_PHONYS := partition kernel
PLATFORM_PKGS := linux-lts grub-efi efibootmgr

BOOTFS_PART := 1
ROOTFS_PART := 2

RUNLEVEL_BOOT ?= hwclock modules bootmisc hostname networking seedrng swap
RUNLEVEL_DEFAULT ?= acpid crond

partition: blkcheck
	$(DOSU) fdisk $(BLKDEV) <<<$$'g\nw\n'
	$(DOSU) sfdisk $(BLKDEV) <<<$$',1G,C12A7328-F81F-11D2-BA4B-00A0C93EC93B,*\n,,0FC63DAF-8483-4772-8E79-3D69D8477DE4,\n'
