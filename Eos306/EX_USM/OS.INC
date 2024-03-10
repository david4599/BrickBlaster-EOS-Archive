;            ษอออออออออออออออออออออออออออออออออออออออออออออออออออป
;            บ       ๗๗๗๗๗๗๗๗๗๗๗๗๗๗ OS.INC ๗๗๗๗๗๗๗๗๗๗๗๗๗๗        บ
;            บ                                                   บ
;            บ                 OS dependant part                 บ
;            บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบ
;            บ   by Freddy Vtel (FreddyV/Useless)              บ
;            บ                                                   บ
;            บ   Code starts .................. 22/08/1996       บ
;            บ   Last Update .................. 09/03/1996       บ
;            ศอออออออออออออออออออออออออออออออออออออออออออออออออออผ

_OS_ EQU 0

DOS32      EQU 1   ; DOS32 DOS Extender
EOS        EQU 2   ; EOS DOS Extender
EOS3       EQU 3   ; EOS v3.00แ or above.
PMODEW_ASM EQU 4   ; PMODE/W DOS Extender (100% ASM code)
PMODEW_C   EQU 5   ; PMODE/W DOS Extender unther WATCOM C
DOS4GW_ASM EQU 6   ; DOS4G/W DOS Extender (100% ASM code)
DOS4GW_C   EQU 7   ; DOS4G/W DOS Extender unther WATCOM C
DJGPP      EQU 8   ; DJGPP (Not supported by now)

; **********************************************
; * Include here the DOS extender you will use *
; **********************************************
OS EQU EOS3

_DPMI   EQU (((OS eq EOS)) or (OS eq DOS32)) eq 0
_WATCOM EQU ((OS Eq DOS4GW_C) or (OS Eq PMODEW_C))

; ** DOS32 DEFINITIONS **

if OS eq DOS32

EXTRN Debug :Near              ; Define external symbol

Cls MACRO
        mov ax,3
        int 10h
ENDM

Waitkey MACRO
        xor eax,eax
        int 16h
ENDM

endif

; ** EOS DEFINITIONS **

If ((OS eq EOS) or (OS eq EOS3))
INCLUDE ..\RESOURCE\EOS.INC

Cls Macro
       mov ax,3
       Dosint 10h
Endm

Waitkey MACRO
       xor eax,eax
       Dosint 16h
ENDM

endif

; ** DJGPP DEFINITIONS **

If OS Eq DJGPP
.MODEL FLAT,C

extrn getch:proc
Waitkey MACRO
        call getch
ENDM

endif

; ** PMODE/W DEFINITIONS **

if OS Eq PMODEW_ASM
.model flat

Cls MACRO
        mov ax,3
        int 10h
ENDM

Waitkey MACRO
        xor eax,eax
        int 16h
ENDM

endif