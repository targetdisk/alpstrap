ARCH ?= x86_64
PLATFORM ?= UEFI
DESTROOT ?= destroot
REPO ?= repo
DOSU ?= sudo
ALPINE_REPO ?= https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/
PKGS ?=
BUSYBOX ?= busybox
APORTSDIR ?= $(APORTS_MODULE)
SHELL := /usr/bin/env bash

GIMME_MODULE := git submodule update --init --recursive

ABUILD_MODULE := modules/abuild
ARCH_MODULE := modules/arch-install-scripts
APK_MODULE := modules/apk-tools
APORTS_MODULE := modules/aports

ABUILD_SCRIPT := $(ABUILD_MODULE)/abuild
APK_BIN := $(APK_MODULE)/src/apk

ABUILD := $(BUSYBOX) ash $(CURDIR)/$(ABUILD_SCRIPT) -c -P $(CURDIR)/$(REPO) rootbld
ACHROOT := $(ARCH_MODULE)/arch-chroot
APK := LD_LIBRARY_PATH=$(APK_MODULE)/src $(APK_BIN)

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

### PORTS TREE ###

$(APORTS_MODULE)/README.md: .gitmodules
	$(GIMME_MODULE) -- $(APORTS_MODULE)

aports: $(APORTS_MODULE)/README.md

### REPO BUILDING ###

# Something will go here...

### INSTALLATION ###

$(DESTROOT):
	mkdir -p $(DESTROOT) || $(DOSU) mkdir -p $(DESTROOT)

$(DESTROOT)/.bootstrap-done: $(DESTROOT) $(APK_BIN)
	$(DOSU) $(APK) --arch $(ARCH) -X $(ALPINE_REPO) --root $(DESTROOT) \
		-U --allow-untrusted --initdb add alpine-keys $(PKGS) && touch $@
	$(DOSU) $(APK) --arch $(ARCH) -X $(ALPINE_REPO) --root $(DESTROOT) \
		add alpine-base $(PKGS) && touch $@

bootstrap: $(DESTROOT)/.bootstrap-done

### CLEANLINESS ###
clean:
	git submodule deinit -f -- \
		$(APK_MODULE) $(ABUILD_MODULE) $(APORTS_MODULE) $(ARCH_MODULE)
	$(DOSU) rm -rf destroot/* repo/*

### MAKEY-MAKEY ###

.PHONY: tools bootstrap aports
