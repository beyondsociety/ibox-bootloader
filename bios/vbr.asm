BITS 16
ORG 0x7c00

start:
        jmp 0x0000:clear_cs
        
clear_cs:
   	mov ax, [0x7DFE]		; MBR sector is copied to 0x0600
   	cmp ax, 0xAA55		        ; Check if the word at 0x7DFE is set to 0xAA55 (Boot sector marker)
   	jne no_mbr
   	mov byte [cfg_mbr], 1	        ; Set for booting from a disk with a MBR
   	 
        call delay

        mov si, mbr_msg
        call print_string

        call delay

        mov si, mbr_done_msg
        call print_string
        jmp $

no_mbr:
   	mov si, mbr_no_msg
   	call print_string
   	jmp $

%include "common.inc"
   
; Bootloader Messages
mbr_msg              db 13, 10, ' Loaded VBR ... ', 0  
mbr_no_msg           db 13, 10, ' No MBR Found ... ', 0
mbr_done_msg         db '[Done] ', 0 

cfg_mbr              db 0	         ; Did we boot off of a disk with a proper MBR

times 510 - ($ - $$) db 0x00		 ; Fill Remaining Code section with Zeros
dw 0xAA55			         ; Indicates a Bootable Sector
