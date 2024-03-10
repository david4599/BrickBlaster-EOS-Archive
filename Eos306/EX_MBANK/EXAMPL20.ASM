;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ This example show how to use the automatic bank switching with           บ
;บ                                                                          บ
;บ the SVGA cards                                                           บ
;บ                                                                          บ
;บ Tabs : 13 21 29 37                                                       บ
;บ                                                                          บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

File_Pic1   db '..\data\test640.DLZ',0
Addr_Pic    dd 0

Screen      dw ?

Sel_Txt     db '    þ Out of selector !',13,10,36
Vesa_Txt    db '    þ Mode SVGA not supported or VESA not found !',13,10
            db '      To install a vesa driver, refer to your video card documentation.',13,10,36


Start32:
            mov ah,Load_Internal_File
            mov edx,O File_Pic1
            Int_EOS                 ; Load the file even if the program isn't
            mov [Addr_Pic],eax      ; Link + Internal Check if the File is present

            mov ax,Mode640x480x256  ; Init SVGA Mode
            call Init_Vesa
            jnc NoError_Vesa

            mov edx,offset Vesa_Txt
            mov ah,Exit_Error
            Int_EOS
NoError_Vesa:
            call Init_Vesa_Bank     ; Turn On the Automatic Bank Switching
            mov [screen],bx
            jnc NoError_Sel

            mov edx,offset Sel_Txt
            mov ah,Exit_Error
            Int_EOS
NoError_Sel:
            mov esi,[Addr_Pic]      ; Set palette
            add esi,10              ; Header offset of SCX
            mov dx,3c8h
            xor al,al
            out dx,al
            mov ecx,256*3
            inc dl
            cli
@@again:    outsb                   ; rep outsb do not work with all cards
            loop @@again
            sti

            push es                 ; Display picture part of picture
            mov es,[screen]
            xor edi,edi

            mov edx,edi             ; EDI Address of first pixel to be display
            shr edx,16
            call Set_Bank
            and edi,0ffffh

            mov ecx,20*640/4        ; Copy the First 20 Lines
            rep movsd
            add edi,400*640         ; skip the next 400 Lines
            add esi,400*640         ; So we are at line 420
            mov ecx,20*640/4        ; copy 20 lines wihtout set the bank again
            rep movsd               ;
            add edi,20*640
            add esi,20*640
            mov ecx,20*640/4        ; copy the last 20 lines
            rep movsd               ;

            pop es

            xor ah,ah               ; Wait a key
            DosInt 16h

            call Close_Vesa_Bank    ; Turn Off the Automatic Bank Switching

            mov ax,4c00h
            int 21h                 ; Exit with Error Code 0
                                    ; and Automaticly restore video Mode !!!

            CODE32 ENDS

            END