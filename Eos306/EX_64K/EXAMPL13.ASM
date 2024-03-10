;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ This example show how to display two pictures (256 colors!) on the       บ
;บ                                                                          บ
;บ screen                                                                   บ
;บ                                                                          บ
;บ Tabs : 13 21 29 37                                                       บ
;บ                                                                          บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

Locals
.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

Offset_pic_1 = 640*80
Offset_pic_2 = 640*80

File_Pic1   db '..\data\test640.dlz',0
File_Pic2   db '..\data\eclipse.dlz',0

Addr_Pic    dd 0
Adrs_Sel    dw ?

Palette     label word
            dw 256 dup (?)

Sel_Txt     db '    þ Out of selector !',13,10,36
Vesa_Txt    db '    þ Mode 640x480x64k not supported or VESA not found !',13,10
            db '      To install a vesa driver, refer to your video card documentation.',13,10,36

Start32:
            mov ax,Mode640x480x64k          ; Init SVGA Mode
            call Init_Vesa                  ;
            jnc NoError_Vesa                ;
            mov edx,offset Vesa_Txt         ;
            mov ah,Exit_Error               ;
            Int_EOS                         ;
NoError_Vesa:

            call Init_Vesa_Bank             ; Turn On the Automatic Bank Switching
            mov [adrs_sel],bx               ;
            jnc NoError_Sel                 ;
            mov edx,offset Sel_Txt          ;
            mov ah,Exit_Error               ;
            Int_EOS                         ;
NoError_Sel:

            mov ah,Load_Internal_File       ; Load the file
            mov edx,O File_Pic1             ;
            Int_EOS                         ;
            mov [Addr_Pic],eax              ;

            mov esi,[Addr_Pic]              ; Convert palette (256 to 64k)
            add esi,10                      ;
            lea edi,Palette                 ;
            call Convert_Palette_to_64k     ;

            xor edi,edi                     ; Display picture
            add esi,offset_pic_1            ;
            mov ecx,640*240                 ;
            call display_64k                ;

            push edi                        ; Save the screen position

            mov ah,DeAllocate_Memory        ; UnLoad the last file
            Int_EOS                         ;

            mov ah,Load_Internal_File       ; Load the file
            mov edx,O File_Pic2             ;
            Int_EOS                         ;
            mov [Addr_Pic],eax              ;

            mov esi,[Addr_Pic]              ; Convert palette (256 to 64k)
            add esi,10                      ;
            lea edi,Palette                 ;
            call Convert_Palette_to_64k     ;

            pop edi                         ; Display picture
            add esi,offset_pic_2            ;
            mov ecx,640*240                 ;
            call display_64k                ;

            mov ah,DeAllocate_Memory        ; UnLoad the last file
            Int_EOS                         ;

            xor ah,ah                       ; Wait a key
            DosInt 16h

            call Close_Vesa_Bank            ; Turn Off the Automatic Bank Switching

            mov ax,4c00h                    ; Exit with Error Code 0
            int 21h                         ; and Automaticly restore video Mode !!!

Convert_Palette_to_64k:                     ; Convert palette (256 to 64k)
            mov ebp,256
@@convert:
            movzx eax,B [esi+0]
            movzx ebx,B [esi+1]
            movzx ecx,B [esi+2]
            add esi,3
            shr eax,1
            shl eax,11
            shl ebx,5
            shr ecx,1
            or  eax,ebx
            or  eax,ecx
            stosw
            dec ebp
            jnz @@convert
            ret

Display_64k:
            push es                         ; Display 64k picture
            mov es,[adrs_sel]
@@dsp:      xor eax,eax
            lodsb
            mov ax,W [Palette+eax*2]
            stosw
            loop @@dsp
            pop es
            ret

            CODE32 ENDS

            END