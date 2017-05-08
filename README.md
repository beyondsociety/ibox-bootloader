### Bios based Bootloaders ###
bootfloppy.asm - Floppy (BPB, old int 0x13 functions, no file system needed)

mbr.asm - MBR partitioned hard disk (MBR partition table, int 0x13 extensions, no file system needed)

gpt.asm - GPT partitioned hard disk (GPT partitioned table, int 0x13 extensions, no file system needed)

bootnet.asm - Network (PXE API, no file system needed)

bootcd.asm - No emulation El Torito (no partitions, int 0x13 extensions, but with 2048-byte sectors, need ISO9660 file system)

### Uefi Based Bootloader ###
uefi - UEFI (everything different)

### Bootloader Info ###
Standard mbr/gpt_mbr - load 512 bytes VBR, this is independent to OS and can be replaced by any other standard MBR/GPT_MBR

VBR - This is specific for each file system, provides file loading API (at pre-defined entry point) to subsequent stages, VBR then loads /boot.bin from file system

stage2.asm - memory map, enable a20, detect cpu, load 32/64 bit kernel and initrd, setup consistent environment (cpu registers state, 32-bit protected mode without paging or compatiblity mode with identity-mapped region, etc, pass control to kernel)




