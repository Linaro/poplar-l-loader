/*
 * (C) Copyright 2017 Linaro Limited
 *
 * Jorge Ramirez-Ortiz <jorge.ramirez-ortiz@linaro.org>
 *
 * Configuration for Poplar 96boards EE. Parts were derived from other ARM
 * configurations.
 *
 * SPDX-License-Identifier:	GPL-2.0+
 *
 */

OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(start)
SECTIONS
{
	. = ALIGN(4);
	.text	:
	{
		*(.text)
		*(.rodata)
	}

	. = ALIGN(4);
	.data : { *(.data) }

	. = ALIGN(4);
	.bss : { *(.bss) }

	. = ALIGN(4);
       .tail : { *(.tail) }
}


