PLATFORM_PHONYS := partition kernel
KERNEL_FLAVOR ?= lts
KERNEL_PKG := linux-$(KERNEL_FLAVOR)
PLATFORM_PKGS := $(KERNEL_PKG)

BOOTFS_PART := 1
ROOTFS_PART := 2

RUNLEVEL_BOOT ?= hwclock modules bootmisc hostname networking seedrng swap
RUNLEVEL_DEFAULT ?= acpid crond

ifeq ($(ARCH),x86_64)
  OVMF_ARCH := x64
else ifeq ($(ARCH),x86)
  OVMF_ARCH := ia32
else ifneq (,$(findstring arm,$(ARCH)))
  OVMF_ARCH := arm
else
  OVMF_ARCH := $(ARCH)
endif

ifeq ($(ARCH),$(shell uname -m))
  KVMFLAGS := -enable-kvm -cpu host
else
  KVMFLAGS :=
endif

QEMU_OVMF ?= /usr/share/ovmf/$(OVMF_ARCH)/OVMF.fd
QEMU_SMP ?= 2
QEMU_MEM ?= 1G

partition: blkcheck
	$(DOSU) fdisk $(BLKDEV) <<<$$'g\nw\n'
	$(DOSU) sfdisk $(BLKDEV) <<<$$',1G,C12A7328-F81F-11D2-BA4B-00A0C93EC93B,*\n,,0FC63DAF-8483-4772-8E79-3D69D8477DE4,\n'

$(MOUNTPOINT)/boot/startup.nsh:
	$(MAKE) blkcheck
	@echo 'vmlinuz-$(KERNEL_FLAVOR) rw root=UUID=$(shell lsblk -rno UUID $(BLKDEV)$(P)$(ROOTFS_PART)) initrd=\initramfs-$(KERNEL_FLAVOR)' \
		| $(DOSU) tee $@

$(MOUNTPOINT)/.bootloader-done: $(MOUNTPOINT)/boot/startup.nsh
	touch $@

qemu-test: umount
	$(DOSU) $(WAYLAND_ASSIST) qemu-system-$(ARCH) \
		$(KVMFLAGS) \
		-smp $(QEMU_SMP) \
		-m $(QEMU_MEM) \
		-bios $(QEMU_OVMF) \
		-vga std -display gtk \
		-drive driver=raw,file.filename=$(BLKDEV) \
		-net user
