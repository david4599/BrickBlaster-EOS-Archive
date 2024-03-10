;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ This example show how to use the Linear Framebuffer with VESA 2.0        บ
;บ                                                                          บ
;บ                                                                          บ
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

Buffer      dd ?

Vesa_Txt    db '    þ Mode SVGA not supported or VESA not found !',13,10
            db '      To install a vesa driver, refer to your video card documentation.',13,10,36

Start32:
            mov ah,Load_Internal_File
            mov edx,O File_Pic1
            Int_EOS                 ; Load the file even if the program isn't
            mov [Addr_Pic],eax      ; Link + Internal Check if the File is present

            mov eax,Mode640x480x256 ; Init SVGA Mode
            mov ecx,640*480         ; Linear Buffer Size
            call Init_Vesa2
            jc Error_Vesa
            mov [Buffer],eax        ; Linear Buffer Address

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

            mov edi,[Buffer]
            mov ecx,(640/4)*480
            rep movsd

            xor ah,ah               ; Wait a key
            DosInt 16h

            mov ax,4c00h
            int 21h                 ; Exit with Error Code 0
                                    ; and Automaticly restore video Mode !!!

Error_Vesa:
            mov edx,offset Vesa_Txt
            mov ah,Exit_Error
            Int_EOS

            CODE32 ENDS

            END