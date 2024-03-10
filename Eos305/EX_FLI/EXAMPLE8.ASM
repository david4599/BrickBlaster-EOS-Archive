;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ Load a FLC and display in 320x200 256 colours with FLI32 Lib             บ
;บ                                                                          บ
;บ Tabs : 13 21 29 37                                                       บ
;บ                                                                          บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

File_FLC    db '..\data\test.FLC',0
File_Txt    db '    þ File error !',13,10,36

Start32:
            mov ah,Use_Int_09       ; Use Internal Keyboard handler to use keyboard
            mov bx,On
            Int_EOS

            mov edx,O File_FLC      ; Load a FLI or FLC into the memory
            call Load_Fli           ; Initialize if needed the track-disk mode
            jc Fli_Error            ; and check the header

            mov ax,13h              ; Set VGA 320*200 256c
            DosInt 10h

            mov ah,Allocate_Selector
            mov esi,0a0000h
            mov edi,0fh
            Int_EOS
            mov Fli_Selector,bx     ; Set Selector

            call First_Frame_Fli    ; Uncompress the first frame
            jc Fli_Error
@@again:
            mov ah,Wait_Vbl         ; Wait the vertical retrace
            Int_EOS

            call Next_Frame_Fli     ; Uncompress next frame
            jc Fli_Error

            cmp Key_Map[Escape],On  ; Test if the Esc key is pressed
            jne @@again

            call Dispose_Fli        ; Freeing memory and close file

            mov ax,4c00h            ; Exit with Error Code 0
            int 21h                 ; and Automaticly restore video Mode

Fli_Error:
            mov edx,offset File_Txt ; Restore initial Video mode, interrupts, free all reserved
            mov ah,Exit_Error       ; memory ,stop music if played and exit with a error
            Int_EOS                 ; message and Error Code 1

            CODE32 ENDS

            END