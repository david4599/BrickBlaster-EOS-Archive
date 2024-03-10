;            ษอออออออออออออออออออออออออออออออออออออออออออออออออออป
;            บ    ๗๗๗๗๗๗๗๗๗๗๗๗๗๗ ERR_CODE.INC ๗๗๗๗๗๗๗๗๗๗๗๗๗๗     บ
;            บ                                                   บ
;            บ               Error codes definition              บ
;            บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบ
;            บ   By Freddy Vtel (FreddyV/Useless)              บ
;            บ                                                   บ
;            บ   Code Starts .................. 01/03/1997       บ
;            บ   Last Update .................. 01/03/1997       บ
;            ศอออออออออออออออออออออออออออออออออออออออออออออออออออผ

Global Display_Error_ :Near

if _WATCOM
Global _Error_Number :DWORD
endif

; Memory Error Codes

Mem_Error EQU 000h

ME_AskForNoMem    EQU Mem_Error+1
ME_OutOfMemory    EQU Mem_Error+2
ME_BlockDestroyed EQU Mem_Error+3
ME_BlockFree      EQU Mem_Error+4 ;When one try to free a free memory block


; Timer Error Codes

Tim_Error EQU 100h

TE_NoFreeTimer Equ Tim_Error+1    ;No more timer available
TE_NotFound    Equ Tim_Error+2    ;Trying to release an unknown timer

; Files Error codes

File_Error EQU 200h

FE_Unknown  EQU File_Error+1
FE_NoFile   EQU File_Error+2
FE_NoPath   EQU File_Error+3
FE_NoHandle EQU File_Error+4
FE_NoAccess EQU File_Error+5
FE_HandleNr EQU File_Error+6

; Sound System Error codes

USS_Error EQU 300h

SE_NoDevice EQU USS_Error+1        ;No Device Selected
SE_Started  EQU USS_Error+2        ;Sound Output already started.

; Output devices Error

DEV_Error EQU 400h

DE_InitFail EQU DEV_Error+1

; USM Player Error codes

USMP_Error EQU 500h

PE_NotUSM EQU USMP_Error+1         ;It's not an USM file.

