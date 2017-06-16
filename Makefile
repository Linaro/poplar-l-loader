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

CROSS_COMPILE ?= arm-linux-gnueabihf-
CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld
OBJCOPY=$(CROSS_COMPILE)objcopy

TEXT_BASE=0x1000
LLOADER_LEN=960K

all: fastboot.bin

fastboot.bin: mbr.bin l-loader.bin
	dd if=mbr.bin of=$@ bs=512 count=1
	dd obs=512 ibs=512 seek=1 skip=1 if=l-loader.bin of=$@ conv=notrunc

mbr.bin: generate_mbr.sh
	bash -x $<

l-loader.bin: l-loader
	$(OBJCOPY) -O binary $< temp.bin
	dd if=temp.bin of=$@ bs=${LLOADER_LEN} count=1 conv=sync

l-loader: start.o debug.o
	$(LD) -Bstatic -Tl-loader.lds -Ttext ${TEXT_BASE} start.o debug.o -o $@

start.o: start.S
	$(CC) -c -o $@ $< -DTEXT_BASE=${TEXT_BASE}

debug.o: debug.S
	$(CC) -c -o $@ $<

clean:
	rm -f *.o l-loader l-loader.bin temp.bin temp mbr.bin fastboot.bin
