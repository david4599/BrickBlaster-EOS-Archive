;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ Load a SCX compress pic, use 320x200 256 colors to display               บ
;บ                                                                          บ
;บ and show the Load_Internal_File function                                 บ
;บ                                                                          บ
;บ Tabs : 13 21 29 37                                                       บ
;บ                                                                          บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

File_Pic1   db '..\data\test320.DLZ',0
Addr_Pic    dd 0

Start32:
            mov ah,Load_Internal_File
            mov edx,O File_Pic1
            Int_EOS                 ; Load the file even if the program isn't
            mov [Addr_Pic],eax      ; Link + Internal Check if the File is present

            mov ax,13h              ; Set VGA 320*200 256c
            DosInt 10h

            mov esi,[Addr_Pic]      ; Set palette
            add esi,10              ; Header Offset of SCX
            mov dx,3c8h
            xor al,al
            out dx,al
            mov ecx,256*3
            inc dl
            cli
@@again:    outsb                   ; rep outsb do not work with all cards
            loop @@again
            sti

            mov edi,[_0a0000h]      ; Display picture
            mov ecx,320*(200/4)
            rep movsd

            xor ah,ah               ; Wait a key
            DosInt 16h

            mov ax,4c00h
            int 21h                 ; Exit with Error Code 0
                                    ; and Automaticly restore video Mode !!!

            CODE32 ENDS

            END