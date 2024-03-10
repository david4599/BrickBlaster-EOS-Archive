;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ Load a SCX compress pic, use 320x200 256 colors to display               บ
;บ                                                                          บ
;บ and show the Load_Internal_File function Using the flat model            บ
;บ                                                                          บ
;บ Tabs : 13 21 29 37                                                       บ
;บ                                                                          บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
.386
.model flat
.stack 4096
.data
INCLUDE ..\RESOURCE\EOS.INC

            db 4096 dup (0)         ; Just to use the diet compression
                                    ; otherwise the file is too short ;)

File_Pic1   db '..\data\test320.DLZ',0
Addr_Pic    dd 0

File_Mod    db '..\data\test.mod',0

.code

Start32:
            mov ebx,es              ; These instructions must be first
            call Init_EOS           ; execute to enable all EOS function
            push ds                 ;
            pop es                  ;

            mov ah,Detect_Sound_Card
            mov ecx,1               ; Display the sound card
            Int_EOS

            mov ah,Load_Module
            mov al,1                ; 1 = Load as Internal File
            mov ecx,44100           ; Play A 44100 Hz
            mov edx,O File_Mod
            Int_EOS


            mov ah,Load_Internal_File
            mov edx,O File_Pic1
            Int_EOS                 ; Load the file even if the program isn't
            mov [Addr_Pic],esi      ; Link + Internal Check if the File is present
                                    ; Take the Flat Address
            mov ax,13h              ; Set VGA 320*200 256c
            Int 10h

            mov esi,[Addr_Pic]      ; Set palette
            add esi,10              ; Header Offset of SCX
            mov dx,3c8h
            xor al,al
            out dx,al
            mov ecx,256*3
            inc dl
            cli
@@again:    outsb                   ; rep outsb do not work with all cards
          ÿÿloop @@again
            sti

            mov edi,0a0000h         ; Display picture
            mov ecx,320*(200/4)
            rep movsd

            mov ah,Play_Module
            Int_EOS

            xor ah,ah               ; Wait a key
            int 16h

            call Fade_Down

            mov ah,Stop_Module
            Int_EOS

            mov ah,Clear_Module
            Int_EOS

            mov ax,4c00h
            int 21h                 ; Exit with Error Code 0
                                    ; and Automaticly restore video Mode !!!

Fade_Down:
            mov ebp,63
@@fade_again:
            mov esi,[Addr_Pic]
            mov edx,256
            add esi,10
@@loop1:
            sub B [esi],1
            adc B [esi],0
            inc esi
            dec edx
            jne @@loop1
            mov ah,Wait_Vbl
            Int_EOS
            mov esi,[Addr_Pic]      ; Set palette
            add esi,10              ; Header Offset of SCX
            mov dx,3c8h
            xor al,al
            out dx,al
            mov ecx,256*3
            inc dl
            cli
@@again1:   outsb                   ; rep outsb do not work with all cards
          ÿÿloop @@again1
            sti
            mov ah,Get_Info
            Int_EOS
            mov ah,Set_Volume
            sub cl,1
            adc cl,0
            mov bl,cl
            mov cl,dl
            Int_EOS
            dec ebp
            jne @@fade_again
            ret

            END Start32