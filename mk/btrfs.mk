FSOPTS ?= defaults,discard,ssd,noatime

$(MOUNTPOINT)/.subvols-done: $(BLKDEV)$(P)2 $(MOUNTPOINT)
	$(DOSU) mount -o $(FSOPTS) $(BLKDEV)$(P)$(ROOTFS_PART) $(MOUNTPOINT)
	cd $(MOUNTPOINT) && \
		$(DOSU) btrfs subvolume create alp-root-$(PLATFORM)-$(ARCH) && \
		$(DOSU) btrfs subvolume create home && \
		$(DOSU) btrfs subvolume create root && \
		cd alp-root-$(PLATFORM)-$(ARCH) && \
		  $(DOSU) mkdir home root && \
		  $(DOSU) btrfs subvolume create etc && \
		  $(DOSU) btrfs subvolume create var && \
		  $(DOSU) btrfs subvolume create usr && \
		  $(DOSU) btrfs subvolume create opt
	$(DOSU) umount $(MOUNTPOINT)
	$(DOSU) mount -o $(FSOPTS),subvol=/alp-root-$(PLATFORM)-$(ARCH) \
		$(BLKDEV)$(P)$(ROOTFS_PART) $(MOUNTPOINT)
	$(DOSU) mount -o $(FSOPTS),subvol=/home \
		$(BLKDEV)$(P)$(ROOTFS_PART) $(MOUNTPOINT)/home
	$(DOSU) mount -o $(FSOPTS),subvol=/root \
		$(BLKDEV)$(P)$(ROOTFS_PART) $(MOUNTPOINT)/root
	$(DOSU) mount -o $(FSOPTS),subvol=/alp-root-$(PLATFORM)-$(ARCH)/etc \
		$(BLKDEV)$(P)$(ROOTFS_PART) $(MOUNTPOINT)/etc
	$(DOSU) mount -o $(FSOPTS),subvol=/alp-root-$(PLATFORM)-$(ARCH)/var \
		$(BLKDEV)$(P)$(ROOTFS_PART) $(MOUNTPOINT)/var
	$(DOSU) mount -o $(FSOPTS),subvol=/alp-root-$(PLATFORM)-$(ARCH)/usr \
		$(BLKDEV)$(P)$(ROOTFS_PART) $(MOUNTPOINT)/usr
	$(DOSU) mount -o $(FSOPTS),subvol=/alp-root-$(PLATFORM)-$(ARCH)/opt \
		$(BLKDEV)$(P)$(ROOTFS_PART) $(MOUNTPOINT)/opt
	$(DOSU) touch $@

$(MOUNTPOINT)/.mount-done: $(MOUNTPOINT)/.subvols-done
	$(DOSU) mkdir -p $(MOUNTPOINT)/boot
	$(DOSU) mount -o defaults,discard $(BLKDEV)$(P)$(BOOTFS_PART) $(MOUNTPOINT)/boot
	$(DOSU) touch $@

umount:
	$(DOSU) umount $(MOUNTPOINT)/boot || :
	$(DOSU) umount $(MOUNTPOINT)/etc || :
	$(DOSU) umount $(MOUNTPOINT)/home || :
	$(DOSU) umount $(MOUNTPOINT)/opt || :
	$(DOSU) umount $(MOUNTPOINT)/root || :
	$(DOSU) umount $(MOUNTPOINT)/usr || :
	$(DOSU) umount $(MOUNTPOINT)/var || :
	$(DOSU) umount $(MOUNTPOINT) || :
