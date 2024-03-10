TRUE    EQU     1
FALSE   EQU     0
CRLF    EQU     10,13

Waitkey MACRO
    mov ah,0
    int 16h
ENDM

Stop MACRO
        mov     ax,4c00h
        int     21h
ENDM

Write MACRO STRING_, COLOR5_T
LOCAL TEXT5_T , skip_wrln
        push  eax
        push  edx
        jmp skip_wrln

        IFB <STRING_>
TEXT5_T DB 36
        ELSE
TEXT5_T DB STRING_,36
        ENDIF
skip_wrln:

        MOV     EDX,OFFSET TEXT5_T
        mov     ah,9
        int     21h
        pop edx
        pop eax
ENDM

Writeln MACRO STRING_
LOCAL TEXT3_S
local skip_wrln
        push eax
        push edx

        jmp skip_wrln

        IFB <STRING_>
TEXT3_S DB 13,10,36
        ELSE
TEXT3_S DB STRING_,13,10,36
        ENDIF
skip_wrln:
        mov EDX,offset TEXT3_S
        mov ah,9
        Int 21h
        pop edx
        pop eax
ENDM

WriteCh MACRO Char
        push eax
        push edx
        mov dl,Char
        mov ah,2
        Int 21h
        pop edx
        pop eax
ENDM
