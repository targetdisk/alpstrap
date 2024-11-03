FSOPTS ?= defaults,discard,noatime

$(MOUNTPOINT)/.mount-done: $(BLKDEV)$(P)2 $(MOUNTPOINT)
	$(DOSU) mount -o $(FSOPTS) $(BLKDEV)$(P)$(ROOTFS_PART) $(MOUNTPOINT)
	$(DOSU) mkdir -p $(MOUNTPOINT)/boot
	$(DOSU) mount -o $(FSOPTS) $(BLKDEV)$(P)$(BOOTFS_PART) $(MOUNTPOINT)/boot
	$(DOSU) touch $@

umount:
	$(DOSU) umount $(MOUNTPOINT)/boot || :
	$(DOSU) umount $(MOUNTPOINT) || :
