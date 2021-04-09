## Copyright (c) 2021 LabOS developers and contributors

PHONY := __all
__all:

include Makefile.config

MAKEFLAGS += --no-print-directory

iso      := LabOS.iso
grub_cfg := grub.cfg
instree  := $(abspath ./install)

install: install-grub

install-kernel:
	mkdir -p "$(instree)/boot"
	@INSTALLDIR="$(instree)/boot" $(MAKE) -C kernel install

install-grub: install-kernel
	mkdir -p "$(instree)/boot/grub"
	cp $(grub_cfg) "$(instree)/boot/grub"
	grub-mkrescue -o $(iso) $(instree)

PHONY += install install-kernel install-grub

run: run-grub

run-grub: install-grub
	qemu-system-x86_64 								 \
		-drive id=cd0,file=${iso},if=none,format=raw \
		-device ahci,id=ahci 						 \
		-device ide-cd,drive=cd0,bus=ahci.0 >/dev/null

PHONY += run run-grub

clean: clean-kernel
	rm -rf "$(instree)"
	rm -rf "$(iso)"

clean-kernel:
	@$(MAKE) -C kernel clean

__all: install

.PHONY: $(PHONY)
