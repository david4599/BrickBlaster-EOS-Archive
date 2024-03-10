;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ Load a SCX compress picture and display in 320x200 256 colors            บ
;บ                                                                          บ
;บ with hard scrolling                                                      บ
;บ                                                                          บ
;บ Tabs : 13 21 29 37                                                       บ
;บ                                                                          บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

File_Pic            db '..\data\test320.DLZ',0
Addr_Pic            dd 0

scroll_position     dw 80
leftright           db 0

Start32:
            mov ah,Load_Internal_File
            mov edx,O File_Pic
            Int_EOS                         ; Load the file even if the program isn't link
            mov [Addr_Pic],eax

            mov ax,13h                      ; Set VGA 320*200 256c
            DosInt 10h

            mov dx,3ceh                     ; Enable hard scrolling
	mov al,5
	out dx,al
	inc dx
	in al,dx
	and al,11101111b
	out dx,al
	dec dx
	mov al,6
	out dx,al
	inc dx
	in al,dx
	and al,11111101b
	out dx,al
	mov dx,3c4h
	mov al,4
	out dx,al
	inc dx
	in al,dx
	and al,11110111b
	or al,4
	out dx,al
	mov dx,3d4h
	mov al,14h
	out dx,al
	inc dx
	in al,dx
	and al,10111111b
	out dx,al
	dec dx
	mov al,17h
	out dx,al
	inc dx
	in al,dx
	or al,01000000b
	out dx,al

            mov ax,0f00h+0002h              ; Clear the screen
            mov dx,3c4h
            out dx,ax
            mov edi,[_0a0000h]
            mov ecx,80*200
            xor eax,eax
            rep stosd

            mov esi,[Addr_Pic]              ; Set palette
            add esi,10                      ; Header Offset of SCX
            mov dx,3c8h
            xor al,al
            out dx,al
            mov ecx,256*3
            inc dl
            cli
@@lp:       outsb                           ; rep outsb do not work with all cards
            loop @@lp
            sti

            movzx edi,scroll_position       ; Copy picture into VRAM
            add edi,[_0a0000h]
            mov dx,3c4h
            mov ecx,200
@@ag:
            push ecx
            mov ecx,80
@@plan:
            mov ax,0100h+0002h
            rept 4
            out dx,ax
            push ax
            lodsb
            mov Byte ptr [edi],al
            pop ax
            shl ah,1
            endm
            inc edi
            loop @@plan
            add edi,160
            pop ecx
            loop @@ag

            mov ax,7813h                    ; Init Horizontal scrolling
	mov dx,03d4h
	out dx,ax

@@again:
            mov ah,Wait_Vbl                 ; Wait the vertical retrace
            Int_EOS

            cli                             ; Scrolling...
            mov bx,scroll_position
	mov ah,bh
	mov al,0ch
	mov dx,3d4h
	out dx,ax
	mov ah,bl
	mov al,0dh
	out dx,ax
	sti

            mov ah,1                        ; Test if a key is pressed
            DosInt 16h
            jnz @@end

            cmp leftright,0
            jne @@decr
            inc scroll_position             ; Inc scrolling
            cmp scroll_position,160
            jne @@again
            mov leftright,1
@@decr:
            dec scroll_position             ; dec scrolling
            cmp scroll_position,0
            jne @@again
            mov leftright,0
            jmp @@again

@@end:
            mov ax,4c00h                    ; Exit with Error Code 0
            int 21h                         ; and Automaticly restore video Mode

            CODE32 ENDS

            END