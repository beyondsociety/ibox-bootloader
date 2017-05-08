; 3.5 inch 1.44 MB Floppy Disk, 80 Cylinders, 2 Heads = 1 for each side
; 18 Sectors Per Track, 2880 Sectors, 512 Bytes Per Sector
BITS 16
ORG 0x7C00

	jmp short boot_code
	nop

	; Bios Parameter Block
	BytesPerSector		dw 512
	SectorPerCluster	db 1
	ReservedSectors		dw 1
	NumberOfFATs		db 2
	RootDirectoryEntries    dw 224
	TotalSectors            dw 2880
	MediaDescriptor		db 0xF0
	SectorsPerFAT		dw 9
	SectorsPerTrack		db 18
	NumberOfHeads		dw 2
	HiddenSectors           dd 0
	TotalSectorsHuge	dd 0	
	DriveNumber		db 0
	Reserved		db 0x00
	BootSignature		db 0x29
        SerialNumber            dd 0xa0a1a2a3
	VolumeName		db "IBOXFLOPPY "
	FileSystemType		db "FAT12   "

; Boot Code
boot_code:
        xor ax, ax
	mov ds, ax
        mov es, ax
	mov ss, ax
	mov sp, 0x7C00
        mov bp, sp

        mov [DriveNumber], dl

        call clear_screen
        call delay

        mov si, boot_msg
        call print_string
        
        call reset_disk
        call read_second_stage

        jmp 0x0000:0x7E00

reset_disk:
	xor ax, ax
	int 13h
	or ah, ah
	jc reset_disk
	ret  

read_second_stage:
        mov ax, 0x0000
	mov es, ax
	mov bx, 0x7E00
	
	mov ah, 0x02
	mov al, 0x17
	mov ch, 0x00
	mov cl, 0x02
	mov dh, 0x00
	mov dl, [DriveNumber]
	int 13h
	or ah, ah
	jc read_second_stage
        ret
	
%include "common.inc"

boot_msg: db 13, 10, 'Booting from Floppy Disk', 0
dot: db '.', 0

times 510 - ($ - $$) db 0
dw 0xAA55
