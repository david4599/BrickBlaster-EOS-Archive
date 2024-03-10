
            Locals
            Jumps
            .486
            .model flat
            .stack 4096


include ..\resource\eos.inc
include blaster.inc

            .code

SBANK macro
            ifndef WIN32
            push edx
            mov edx,edi
            shr edx,16
            call Set_Bank
            pop edx
            lea edi,[di]
            else
            add edi,[_0a0000h]
            endif
endm


;----------------------------------------------------------------------------
ifndef WIN32
start32:
_int equ int
else
_Start32:
Start32 equ _Start32
endif
;----------------------------------------------------------------------------

            mov ebx,es              ; These instruction must be first
            call Init_EOS           ; execute to enable all EOS function
            push ds                 ;
            pop es                  ;

            ifndef WIN32
            call Debug_back
            endif

            include main.asm
            include draw.asm
            include mouse.asm
            include file.asm
            include editor.asm
            include fonte.asm
            include hiscore.asm
            include exp.asm
            include fli32.asm

            ifdef WIN32
            include gif.asm
            endif

            end Start32