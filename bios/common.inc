; 16-bit function to print a string to the screen using the BIOS, input: si - Address of start of string to print.
print_string:
        pushad                          ; Push all general purpose registers to save them

print_loop:
        lodsb                           ; Load the value at [@es:@si] in @al
        test al, al                     ; If AL is the terminator character, stop printing. AL = character to write
        je print_done                  	

        mov ah, 0x0E	                ; AH = teletype mode - 0x0F: 0 (black) background + 7 (white) + 8 (bright) foreground color
        xor bx, bx                  	; BH = page number, BL = foreground color (graphic modes only) 
        int 0x10                        ; Bios function
        jmp print_loop                  ; Loop till the null character not found
 
print_done:
        popad                           ; Pop all general purpose registers to restore them
        ret                             ; Return control

; Clears the screen (white text on blue background)
clear_screen:
        pushad                          ; Push all general purpose registers to save them

        mov ah, 0x06                    ; AH = Scroll window up
        mov al, 0x00     		; AL = Number of lines to scroll, 00h = clear entire screen
        mov bh, 0x1f	   		; BH = Color attribute 
        mov ch, 0x00                    ; CH = Row number of upper left corner of screen
        mov cl, 0x00     		; CL = Column number of upper left corner of screen
        mov dh, 0x18                    ; DH = Row number of lower right corner of screen
        mov dl, 0x4f     		; DL = Column number of lower corner of screen
        int 0x10	   		; Bios Video Service Function
        
        mov ah, 0x02                    ; AH = Set Cursor Position 
        mov bh, 0x00                    ; BH = Display Page Number                    
        xor dx, dx                      ; DH = Row, DL = Column
        int 0x10                        ; Bios Video Service Function

        popad                           ; Pop all general purpose registers to restore them 
        ret                             ; Return Control

; Delay for 2 microseconds (1,000,00ths of a second)
delay:
        mov ah, 0x86                    ; AH = Wait specified number of microseconds
        mov cx, 0x001e                  ; CX = High word of count
        mov dx, 0x8480                  ; DX = Low word of count
        int 0x15                        ; AT Extended Services / APM
        ret                             ; Return control

