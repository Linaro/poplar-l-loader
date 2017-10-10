#!/bin/bash

# Generate Linux partition table for Poplar eMMC

TEMP_FILE=$(mktemp /tmp/linux-8g.XXXXXX)
trap "rm -f ${TEMP_FILE}" EXIT ERR SIGHUP SIGINT SIGQUIT SIGTERM

# Poplar has 7456KB eMMC
SECTOR_NUMBER=15269888
SECTOR_SIZE_BYTES=512
SIZE=$((${SECTOR_NUMBER} * ${SECTOR_SIZE_BYTES}))

##### Linux on Poplar uses 3 partitions #####
# $ fdisk -L mbr.bin
# Disk mbr.bin: 7.3 GiB, 7818182656 bytes, 15269888 sectors
# Units: sectors of 1 * 512 = 512 bytes
# Sector size (logical/physical): 512 bytes / 512 bytes
# I/O size (minimum/optimal): 512 bytes / 512 bytes
# Disklabel type: dos
# Disk identifier: 0xcf7e875d
#
# Device        Boot  Start      End  Sectors   Size Id Type
# mbr.bin1           1     8191     8191     4M f0 Linux/PA-RISC boot
# mbr.bin2 *      8192   287527   279336 136.4M  c W95 FAT32 (LBA)
# mbr.bin3      288768 15269887 14981120   7.1G 83 Linux
#####

echo "Creating MBR for Poplar eMMC"
truncate --size=${SIZE} ${TEMP_FILE}
{
	echo "label: dos"
	echo "start=1      size=8191     type=f0"
	echo "start=8192   size=279336   type=0c bootable"
	echo "start=288768 size=14981120 type=83"
} | sfdisk --quiet ${TEMP_FILE}

# Extract just the MBR
dd status=none if=${TEMP_FILE} of=mbr.bin bs=${SECTOR_SIZE_BYTES} count=1
