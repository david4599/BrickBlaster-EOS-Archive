;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ This example show how to play a sample                                   บ
;บ                                                                          บ
;บ Tabs : 13 21 29 37                                                       บ
;บ                                                                          บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

Module_Name db '..\data\testsmpl.mod',0

Msg_Module  db '    þ Module Not Found...',13,10,36
Msg_Playing db '    þ Press Space to play a sample...',13,10,36


Start32:
            mov ah,Use_Int_09       ; Use Internal Keyboard handler to use keyboard
            mov bx,On
            Int_EOS

            mov ah,Detect_Sound_Card
            xor bx,bx               ; Find the Best One (Gravis ;))
            mov cx,1                ; Display the results
            Int_EOS                 ; You must use this function before using
                                    ; the player
            mov ah,Load_Module
            mov al,0                ; Normal Load
            mov bx,44000            ; Set Replay Rate For SB
            mov ecx,1               ; Number Of Track For Sample
            mov edx,O Module_Name
            Int_EOS
            jnc Load_Ok             ; Can Load ??

            mov ah,Exit_Error       ; No Exit with Exit_Error function
            mov edx,O Msg_Module    ; en Display Message
            Int_EOS
Load_Ok:

            mov ah,Play_Module      ; Start playing module
            Int_EOS
            mov [Master_Volume],32      ; Set Music Volume
            mov [Master_Volume_Sfx],63  ; Set Sample Volume

            mov ah,9                ; Display Message
            mov edx,O Msg_Playing
            int 21h

@@again:
            cmp Key_Map[Escape],On  ; Escape ?
            je @@end
            cmp Key_Map[Space],On   ; Space ?
            jne @@again

            mov ah,Play_Sample
            mov cx,339              ; Freq.
            mov dx,00               ; Piste Sample 0
            mov bx,09h              ; Sample number
            Int_EOS

@@wait:
            cmp Key_Map[Space],Off  ; Space ?
            jne @@wait

            jmp @@again

@@end:
            mov ah,Stop_Module      ; Stop  playing module
            Int_EOS

            mov ah,Clear_Module     ; Unload module From memory
            Int_EOS

            mov ax,4c00h            ; Exit with error code 0
            int 21h


            CODE32 ENDS

            END