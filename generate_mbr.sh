#!/bin/sh
# Generate partition table for Poplar eMMC
#
# linux: 3 entries
PTABLE=linux-8g
TEMP_FILE=$(mktemp /tmp/${PTABLE}.XXXXXX)

#Poplar has 8gb eMMC
SECTOR_NUMBER=15269888
SECTOR_SIZE_BYTES=512
SIZE=$((${SECTOR_NUMBER} * ${SECTOR_SIZE_BYTES}))

echo "Creating MBR for Poplar eMMC"

# get the partition table
case ${PTABLE} in
    linux*)
      truncate --size=$SIZE ${TEMP_FILE}

#mbr.bin1             1     8191     8191     4M f0 Linux/PA-RISC boot
#mbr.bin2   *      8192   287527   279336 136.4M  c W95 FAT32 (LBA)
#mbr.bin3        288768 15269887 14981120   7.1G 83 Linux

      sfdisk ${TEMP_FILE} <<EOF
1, 8191, f0
,279336, 0c *
,, 83
EOF

      ;;
esac

#extract the mbr
dd if=${TEMP_FILE} of=mbr.bin bs=${SECTOR_SIZE_BYTES} count=1
rm -f ${TEMP_FILE}
