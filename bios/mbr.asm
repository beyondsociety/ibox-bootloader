BITS 16                               ; MBR is actually loaded @ 0x7C00, but the origin here is 0x0600 
;ORG 0x0600                            ; so that the code still functions after being moved
org 0x7c00

start:       
       	cli                             ; Disable interrupts 
       	xor ax, ax                      ; Initialize segment registers to 0	        
       	mov ds, ax                      
        mov es, ax                     
       	mov ss, ax			; Initialize the stack, clear Stack Segment
       	mov sp, 0x7C00                  ; Set stack @ 0000:7C00
       	sti                             ; Enable interrupts
               
        call clear_screen
             
       	; Copy MBR sector to 0x0600 and jump there
       	cld                         	; Clear Direction Flag
        mov si, 0x7c00
       	mov di, 0x0600              	; Point DI to 0600, where the MBR will be copied to
	mov cx, 0x0200                  ; Copy 512 bytes, size of MBR
        rep movsb

        call delay

        mov si, relocate_msg
        call print_string
        jmp 0x0000:relocate

relocate:
        mov [drive_number], dl           ; Save the Drive Number passed by the BIOS
        call delay
	
        mov si, done_msg
        call print_string

        ; Check for extensions present: int 13h, ah=41h
        mov ah, 0x41
        mov bx, 0x55AA
        int 0x13
        jc no_extensions
        cmp bx, 0xAA55
        jnz no_extensions
                
        ; Extended read sectors from drive: int 13h, 42h
	mov ah, 0x42
        mov dl, [drive_number]
        lea si, [lba_address]
        int 0x13
        cmp ah, 0x00
        jne no_extensions

        call delay
        mov si, found_ext_msg
        call print_string
        call mbr_failback       

no_extensions: 
        call delay
	mov si, fail_ext_msg
        call print_string

        jmp mbr_failback
        jmp $

; We reach this point if we need to use legacy mbr
mbr_failback:
        call delay
        mov si, reading_mbr_msg
        call print_string 
   
        mov ax, 1
        cmp byte [0x7BBE], 0x80
        je found_mbr_active_part
        inc ax
        cmp byte [0x7BCF], 0x80
        je found_mbr_active_part
        inc ax
        cmp byte [0x7BDF], 0x80
        je found_mbr_active_part
        inc ax
        cmp byte [0x7BEF], 0x80
        je found_mbr_active_part
        
        call delay
        mov si, no_boot_msg
        call print_string
        jmp $

found_mbr_active_part:
	call read_sector
        call delay        

        mov si, done_msg
        call print_string

	jmp 0x0000:0x7c00

read_sector:
       	mov bx, 0x0000
        mov es, bx
       	mov bx, 0x7c00

       	mov ah, 0x02
        mov al, 0x01
       	mov cl, 0x02
       	mov ch, 0x00
       	mov dh, 0x00
       	mov dl, 0x80
       	int 0x13
       
        or ah, ah
        jc read_sector
        ret

lba_address:
        db 0x10                 ; Size of DAP (16 bytes long)
        db 0x00                 ; Unused, set to zero
        db 0x01                 ; Number of sectors to be read: max 127, 64 to write
        db 0x00                 ; Max sectors = 127, so not used, set to zero
        dw 0x0000               ; Segment to memory buffer where data to be written or read from
        dw 0x7c00               ; Offset to memory buffer where data to be written or read from
        dq 0x0000000000000001   ; Absolute start number of sectors to read from LBA. 

%include "common.inc"
   
; Bootloader Messages
relocate_msg:        db 13, 10, ' Relocated MBR ... ', 0
fail_ext_msg:        db 13, 10, ' No Extensions', 0
found_ext_msg:       db 13, 10, ' Found Extensions', 0
reading_ext_msg:     db 13, 10, ' Reading Extensions... ', 0
reading_mbr_msg:     db 13, 10, ' Reading MBR... ', 0

no_boot_msg:         db 'Cannot find a valid partition to boot from', 0
done_msg:            db '[Done] ', 0
drive_number         db 0

times 446 - ($ - $$) db 0

; ********************************************Partition Table*********************************************
; Partition table - Four 16-Byte entries describing the disk partitioning  
PT1_Status				db 0x00			; Drive number/Bootable flag
PT1_First_Head  			db 0x00			; First Head
PT1_First_Sector			db 0x00			; Bits 0-5:First Sector|Bits 6-7 High bits of First Cylinder
PT1_First_Cylinder			db 0x00			; Bits 0-7 Low bits of First Cylinder
PT1_Part_Type				db 0x00			; Partition Type
PT1_Last_Head	  			db 0x00			; Last Head 
PT1_Last_Sector				db 0x00			; Bits 0-5:Last Sector|Bits 6-7 High bits of Last Cylinder
PT1_Last_Cylinder			db 0x00			; Bits 0-7 Low bits of Last Cylinder
PT1_First_LBA				dd 0x00000000	        ; Starting LBA of Partition
PT1_Total_Sectors			dd 0x00000000	        ; Total Sectors in Partition
PT2_Status				db 0x00
PT2_First_Head  			db 0x00
PT2_First_Sector			db 0x00
PT2_First_Cylinder			db 0x00
PT2_Part_Type				db 0x00
PT2_Last_Head	  			db 0x00
PT2_Last_Sector				db 0x00
PT2_Last_Cylinder			db 0x00
PT2_First_LBA				dd 0x00000000
PT2_Total_Sectors			dd 0x00000000
PT3_Status				db 0x00
PT3_First_Head  			db 0x00
PT3_First_Sector			db 0x00
PT3_First_Cylinder			db 0x00
PT3_Part_Type				db 0x00
PT3_Last_Head	  			db 0x00
PT3_Last_Sector				db 0x00
PT3_Last_Cylinder			db 0x00
PT3_First_LBA				dd 0x00000000
PT3_Total_Sectors			dd 0x00000000
PT4_Status				db 0x00
PT4_First_Head  			db 0x00
PT4_First_Sector			db 0x00
PT4_First_Cylinder			db 0x00
PT4_Part_Type				db 0x00
PT4_Last_Head	  			db 0x00
PT4_Last_Sector				db 0x00
PT4_Last_Cylinder			db 0x00
PT4_First_LBA				dd 0x00000000
PT4_Total_Sectors			dd 0x00000000

MBR_Sig              dw 0xAA55	        ; Indicates a Bootable Sector



