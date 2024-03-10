;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ This example show how to use EOS and the Diamond player                  บ
;บ                                                                          บ
;บ Tabs : 13 21 29 37                                                       บ
;บ                                                                          บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

Module_Name db '..\data\test.mod',0

Msg_Module  db '    þ Module Not Found...',13,10,36
Msg_Playing db '    þ Playing Module',13,10,36
Msg_Paused  db '    þ Paused',13,10,36


Start32:
            mov ah,Detect_Sound_Card
            xor bx,bx               ; Find the Best One (Gravis ;))
            mov cx,1                ; Display the results
            Int_EOS                 ; You must use this function before using
                                    ; the player

            mov ah,Load_Module
            mov al,0                ; Normal Load
            mov bx,44000            ; Set Replay Rate For SB
            mov edx,O Module_Name
            Int_EOS
            jnc Load_Ok             ; Can Load ??

            mov ah,Exit_Error       ; No Exit with Exit_Error function
            mov edx,O Msg_Module    ; en Display Message
            Int_EOS
Load_Ok:

            mov ah,Play_Module      ; Start playing module
            Int_EOS

            mov ah,9                ; Display Message
            mov edx,O Msg_Playing
            int 21h

            xor ah,ah               ; Wait A key
            DosInt 16h

            mov ah,Stop_Module      ; Stop  playing module
            Int_EOS

            mov ah,9                ; Display Message
            mov edx,O Msg_Paused
            int 21h

            xor ah,ah               ; Wait A key
            DosInt 16h

            mov ah,Play_Module      ; ReStart playing module
            Int_EOS

            mov ah,9                ; Display Message
            mov edx,O Msg_Playing
            int 21h

            xor ah,ah               ; Wait A key
            DosInt 16h

            mov ah,Stop_Module      ; Stop  playing module
            Int_EOS

            mov ah,Clear_Module     ; Unload module From memory
            Int_EOS

            mov ax,4c00h            ; Exit with error code 0
            int 21h


            CODE32 ENDS

            END