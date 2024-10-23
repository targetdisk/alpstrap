GIMME_MODULE := git submodule update --init --recursive
ARCH_MODULE := modules/arch-install-scripts
APK_MODULE := modules/apk-tools
APK_BIN := $(APK_MODULE)/src/apk

ACHROOT := $(ARCH_MODULE)/arch-chroot
APK := LD_LIBRARY_PATH=$(APK_MODULE)/src $(APK_BIN)

tools: $(ACHROOT) $(APK_BIN)

$(ARCH_MODULE)/Makefile: .gitmodules
	$(GIMME_MODULE) -- $(ARCH_MODULE)

$(ACHROOT): $(ARCH_MODULE)/Makefile
	$(MAKE) -C $(ARCH_MODULE) arch-chroot

$(APK_MODULE)/Makefile: .gitmodules
	$(GIMME_MODULE) -- $(APK_MODULE)

$(APK_BIN): $(APK_MODULE)/Makefile
	$(MAKE) -C $(APK_MODULE)

.PHONY: tools
