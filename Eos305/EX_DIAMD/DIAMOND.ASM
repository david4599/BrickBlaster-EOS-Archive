.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

INCLUDE ..\RESOURCE\EOS.INC

File_Name   db 128 dup (0)

Msg_Playing db '    ю Usage DIAMOND.EXE <file>.mod - ESC to quit.',13,10,36

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

Start32:
            mov ah,9
            mov edx,O Msg_Playing
            int 21h

            Get_Param File_Name
            jc @@Ok100

            mov ah,Detect_Sound_Card
            mov ecx,1
            Int_EOS

            mov ah,Load_Module
            mov al,1                        ; Use Internal File
            mov bx,44100
            xor ecx,ecx
            mov edx,O File_Name
            Int_EOS
            jc @@Ok100

            mov ah,Play_Module
            Int_EOS
@@Ok100:
            xor ah,ah
            DosInt 16h

            mov ah,Stop_Module
            Int_EOS

            mov ah,Clear_Module
            Int_EOS

            mov ax,4c00h
            int 21h

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

CODE32 ENDS

        END