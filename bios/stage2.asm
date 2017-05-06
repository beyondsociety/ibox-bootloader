[bits 16]
[org 0x7E00]

boot:
        xor ax, ax
        mov ds, ax
        
        call delay

        mov si, boot_msg
        call print_string

	jmp $

boot_msg: db 13, 10, 'Loaded Second Stage', 0
%include "common.inc"
