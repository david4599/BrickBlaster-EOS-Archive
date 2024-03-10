;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ This example show how to call the 32 bit debugger                        บ
;บ                                                                          บ
;บ Tabs : 13 21 29 37                                                       บ
;บ                                                                          บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

Msg         db '    þ Hello world...',13,10,36


Start32:
            call debug              ; Where you want !!! Alt-x to exit

            mov ah,9
            mov edx,O Msg
            int 21h                 ; Call Display String

            mov ax,4c00h
            int 21h                 ; Exit with Error Code 0


            CODE32 ENDS

            END