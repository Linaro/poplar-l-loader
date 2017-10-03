#
# (C) Copyright 2017 Linaro Limited
#
# Jorge Ramirez-Ortiz <jorge.ramirez-ortiz@linaro.org>
#
# Configuration for Poplar 96boards EE. Parts were derived from other ARM
# configurations.
#
# SPDX-License-Identifier:	GPL-2.0+
#

ARM_TRUSTED_FIRMWARE ?= ../poplar-arm-trusted-firmware/
ARM_TF_INCLUDE ?= $(ARM_TRUSTED_FIRMWARE)/plat/hisilicon/poplar/include

CROSS_COMPILE ?= arm-linux-gnueabihf-

CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld
OBJCOPY=$(CROSS_COMPILE)objcopy

# Use build date/time and Git commit id to form a version message
VDATE=$(shell date '+%Y/%m/%d %H:%M:%S%z')
VCOMMIT=$(shell git rev-parse --verify --short HEAD 2>/dev/null)
VERSION_MSG='"LOADER:  Built $(VDATE) Commit-id $(VCOMMIT)"'

LLOADER_LEN=960K

all: fastboot.bin

fastboot.bin: mbr.bin l-loader.bin
	dd if=mbr.bin of=$@ bs=512 count=1
	dd if=l-loader.bin of=$@ obs=512 ibs=512 seek=1 skip=1 conv=notrunc

mbr.bin: generate_mbr.sh
	bash -x $<

l-loader.bin: l-loader
	$(OBJCOPY) -O binary $< $@
	truncate -s ${LLOADER_LEN} $@

l-loader: start.o debug.o l-loader.lds
	$(LD) -Bstatic -Tl-loader.lds start.o debug.o -o $@

start.o: start.S
	$(CC) -c -o $@ $< -I$(ARM_TF_INCLUDE) -DVERSION_MSG=$(VERSION_MSG)

debug.o: debug.S
	$(CC) -c -o $@ $<

l-loader.lds: l-loader.ld.in
	$(CPP) -P -o $@ - < $< -I$(ARM_TF_INCLUDE)

clean:
	rm -f *.o l-loader.lds l-loader l-loader.bin mbr.bin fastboot.bin
