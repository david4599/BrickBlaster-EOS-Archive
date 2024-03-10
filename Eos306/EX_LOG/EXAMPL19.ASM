;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ This example show how to call the 32 bit debugger                        บ
;บ and how to use the log array in the debugger                             บ
;บ                                                                          บ
;บ Tabs : 13 21 29 37                                                       บ
;บ                                                                          บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

Msg         db '    þ Hello world...',13,10,36
DwordValue  dd 1024
MathExpr    db 'EAX+4*ECX+10',0



Start32:
            mov al,_Log_String      ; Define Data Type
            mov ebx,O Msg           ; Address of Data
            mov ecx,_Address        ; Define as Real Address
            call Add_Log            ; Add Log

            mov al,_Log_Dword       ; Define Data Type
            mov ebx,O DwordValue    ; Address of Data
            mov ecx,_Address        ; Define as Real Address
            call Add_Log            ; Add Log

            mov al,_Log_Byte_Array  ; Define Data Type
            mov ebx,O MathExpr      ; Address of Expression
            mov ecx,_String         ; Define as Mathematical Expression
            call Add_Log            ; Add Log

            call debug              ; Press Ctrl+L to see the Log in the Debugger

            mov ah,9
            mov edx,O Msg
            int 21h                 ; Call Display String

            mov ax,4c00h
            int 21h                 ; Exit with Error Code 0


            CODE32 ENDS

            END