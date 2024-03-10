;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ This example show how to use the Memory library                          บ
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

Msg         db '    þ Press a key...',13,10,36

File_Pic1   db '..\data\test640.DLZ',0

Start32:
            call Init_Memory        ; Init the lib

            mov ah,9
            mov edx,O Msg
            int 21h                 ; Display String

            mov ah,Load_Internal_File
            mov edx,O File_Pic1
            Int_EOS                 ; Load a file

            xor ah,ah               ; Wait a key
            DosInt 16h

            mov ah,9
            mov edx,O Msg
            int 21h                 ; Display String

            mov ah,Load_Internal_File
            mov edx,O File_Pic1
            Int_EOS                 ; Load a file

            xor ah,ah               ; Wait a key
            DosInt 16h

            mov ah,9
            mov edx,O Msg
            int 21h                 ; Display String

            mov ah,DeAllocate_Memory
            Int_EOS                 ; Dispose memory

            xor ah,ah               ; Wait a key
            DosInt 16h

            mov ah,9
            mov edx,O Msg
            int 21h                 ; Call Display String

            mov ah,DeAllocate_Memory
            Int_EOS                 ; Dispose memory

            xor ah,ah               ; Wait a key
            DosInt 16h

            mov ax,4c00h
            int 21h                 ; Exit with Error Code 0

            CODE32 ENDS

            END