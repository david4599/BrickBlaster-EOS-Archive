;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;�                                                                          �
;� This example show how to use EOSLITE                                     �
;�                                                                          �
;� Tabs : 13 21 29 37                                                       �
;�                                                                          �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕

.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

Msg         db '    � Hello world...',13,10,36


Start32:
            mov ah,9
            mov edx,O Msg
            int 21h                 ; Call Display String
            mov ax,4c00h
            int 21h                 ; Exit with Error Code 0

            CODE32 ENDS

            END