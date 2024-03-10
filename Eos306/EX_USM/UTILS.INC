;            ษอออออออออออออออออออออออออออออออออออออออออออออออออออป
;            บ     ๗๗๗๗๗๗๗๗๗๗๗๗๗๗ UTILS.INC ๗๗๗๗๗๗๗๗๗๗๗๗๗๗       บ
;            บ                                                   บ
;            บ              Useless misc routines                บ
;            บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบ
;            บ   By Freddy Vtel (FreddyV/Useless)              บ
;            บ                                                   บ
;            บ   Code Starts .................. 03/04/1996       บ
;            บ   Last Update .................. 10/08/1996       บ
;            ศอออออออออออออออออออออออออออออออออออออออออออออออออออผ

ifndef _OS_
display 'OS.INC must be included before UTILS.INC'
Endif

Global Print_Str  :Near
Global Print_Dec  :Near
Global Print_Hex  :Near

Global _DPrint_char :Near
Global _DPrint_str  :Near
Global _DPrint_Dec  :Near
Global _DPrint_Hex  :Near

Stop MACRO
        mov ax,4c00h
        int 21h
ENDM

showborder = 0           ; 'Raster' pour le %machine
setborder MACRO no
      if showborder
      PUSH dx ax
      MOV  dx,03dah
      IN   al,dx
      MOV  dx,03c0h
      MOV  al,31h
      OUT  dx,al
      MOV  al,no
      OUT  dx,al
      POP  ax dx
      endif
ENDM

Dwritech MACRO Char
	 push edx
	 mov dl,Char
	 call _DPrint_char
	 pop edx
EndM

DWrite MACRO STRING_
LOCAL TEXT5_T , skip_wrln
        jmp skip_wrln

        IFB <STRING_>
TEXT5_T DB 0
        ELSE
TEXT5_T DB STRING_,0
        ENDIF
skip_wrln:

	push ecx
	push esi
        mov esi,OFFSET TEXT5_T
	mov ecx,40
	call _DPrint_str
	pop esi
	pop ecx
ENDM

if (OS EQ DJGPP)

extrn printf:proc

Write MACRO STRING_
LOCAL TEXT5_T , skip_wrln
        push  eax
        push  edx
        jmp skip_wrln

        IFB <STRING_>
TEXT5_T DB 0
        ELSE
TEXT5_T DB STRING_,0
        ENDIF
skip_wrln:

        push OFFSET TEXT5_T
        call printf
        add  sp,4

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
TEXT3_S DB 13,10,0
        ELSE
TEXT3_S DB STRING_,13,10,0
        ENDIF
skip_wrln:

        push offset TEXT3_S
        call printf
        add  sp,4
	
        pop edx
        pop eax
ENDM

else

Write MACRO STRING_
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

        MOV EDX,OFFSET TEXT5_T
        mov ah,9
        int 21h
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

Endif

; UTILS.INC (c) 1997 FreddyV/Useless