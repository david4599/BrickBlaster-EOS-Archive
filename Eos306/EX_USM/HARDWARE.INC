;            ษอออออออออออออออออออออออออออออออออออออออออออออออออออป
;            บ    ๗๗๗๗๗๗๗๗๗๗๗๗๗๗ HARDWARE.INC ๗๗๗๗๗๗๗๗๗๗๗๗๗๗     บ
;            บ                                                   บ
;            บ           Hardware functions (DMA/IRQ)            บ
;            บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบ
;            บ   By Freddy Vtel (FreddyV/Useless)              บ
;            บ                                                   บ
;            บ   Code Starts .................. 05/09/1996       บ
;            บ   Last Update .................. 16/02/1997       บ
;            ศอออออออออออออออออออออออออออออออออออออออออออออออออออผ
; Advice: It's used only in the SB driver.

Ifndef _OS_
display 'OS.INC must be included before HARDWARE.INC'
Endif

DMAAutoinit   EQU 8+16+64
DMANoAutoinit EQU 8+64

; ** Hardware functions **

if _WATCOM
Global HardwareInit_ :Near
Global HardwareEnd_  :Near
else
Global HardwareInit  :Near
Global HardwareEnd   :Near
endif

Global IRQ_Enable    :Near
Global IRQ_Disable   :Near

Global GetEnvOffset  :Near

Global DMA_Setup     :Near

; ** Public var **

If ((OS EQ EOS) OR (OS EQ EOS3))

ZeroOffset EQU Zero_Addr
PSPOffset  EQU PSP_Addr
EnvOffset  EQU Environment_Addr

Else

Global ZeroOffset :DWORD  ; Zero base Offset
Global PSPOffset  :DWORD  ; PSP Offset
Global EnvOffset  :DWORD  ; Offset to the environment variables

EndIf

Global DMABuffer      :DWORD
Global DMARealAddress :DWORD

; IRQ MACROS

;******************** DPMI ***********************
;*  DOS32 and PMODE/W uses DPMI IRQ functions    *
;*************************************************

If  ( (OS EQ DOS32) or (OS EQ PMODEW_ASM) or (OS EQ PMODEW_C) )
;display 'IRQ DPMI'

DPMI_GetInt EQU 204h
DPMI_SetInt EQU 205h

GetInt Macro Inter,_Ptr
        mov bl,Inter

        mov ax,DPMI_GetInt
        int 31h
        mov DWORD PTR _Ptr,edx  ; Save Int offset
        mov WORD PTR _Ptr[4],cx ; Save Int selector	
Endm

RestInt Macro Inter,_Ptr
        mov bl,Inter
        mov cx,WORD PTR _Ptr[4]
        mov edx,DWORD PTR _Ptr

        mov ax,DPMI_SetInt
        int 31h
Endm

SetInt Macro Inter,Select,Offs
        mov bl,Inter
        mov cx,Select
        mov edx,Offset Offs

        mov ax,DPMI_SetInt
        int 31h
Endm

GetIRQ Macro IRQ,_Ptr
Local SmallIRQ

        mov bl,IRQ
        cmp bl,7
        jbe SmallIRQ
        add bl,60h           ;Interrupt = IRQ+68h
SmallIRQ:
        add bl,8             ;Interrupt = IRQ+8

        mov ax,DPMI_GetInt
        int 31h
        mov DWORD PTR _Ptr,edx  ; Save IRQ offset
        mov WORD PTR _Ptr[4],cx ; Save IRQ selector	
Endm

RestIRQ Macro IRQ,_Ptr
Local SmallIRQ

        mov bl,IRQ
        cmp bl,7
        jbe SmallIRQ
        add bl,60h           ;Interrupt = IRQ+68h
SmallIRQ:
        add bl,8             ;Interrupt = IRQ+8

        mov cx,WORD PTR _Ptr[4]
        mov edx,DWORD PTR _Ptr

        mov ax,DPMI_SetInt
        int 31h
Endm

SetIRQ Macro IRQ,Select,Offs
Local SmallIRQ
;writeln 'SetIRQ...'
        mov bl,IRQ
        cmp bl,7
        jbe SmallIRQ
        add bl,60h           ;Interrupt = IRQ+68h
SmallIRQ:
        add bl,8             ;Interrupt = IRQ+8

        mov cx,Select
        mov edx,Offset Offs

        mov ax,DPMI_SetInt
        int 31h
Endm

Endif

;***************** DOS4G/W *******************

If (OS EQ DOS4GW_ASM)
;display 'IRQ DOS4GW !!'
GetInt Macro Inter,_Ptr
        mov al,Inter

        push es
        mov ah,35h
        int 21h	
        mov DWORD PTR _Ptr,ebx  ; Save Int offset
        mov WORD PTR _Ptr[4],es ; Save Int selector
        pop es
Endm

RestInt Macro Inter,_Ptr
        mov al,Inter
        mov cx,WORD PTR _Ptr[4]
        mov edx,DWORD PTR _Ptr

        push ds
        push cx
        pop ds
        mov ah,25h
        int 21h
        pop ds
Endm

SetInt Macro Inter,Select,Offs
        mov al,Inter
        mov edx,Offset Offs

        push ds
        push Select
        pop ds
        mov ah,25h      ; DS:EDX, New IRQ pointer
        int 21h
        pop ds
Endm

GetIRQ Macro IRQ,_Ptr
Local SmallIRQ

        mov al,IRQ
        cmp al,7
        jbe SmallIRQ
        add al,60h           ;Interrupt = IRQ+68h
SmallIRQ:
        add al,8             ;Interrupt = IRQ+8

        push es
        mov ah,35h
        int 21h
        mov DWORD PTR _Ptr,ebx  ; Save IRQ offset
        mov WORD PTR _Ptr[4],es ; Save IRQ selector
        pop es
Endm

RestIRQ Macro IRQ,_Ptr
Local SmallIRQ

        mov al,IRQ
        cmp al,7
        jbe SmallIRQ
        add al,60h           ;Interrupt = IRQ+68h
SmallIRQ:
        add al,8             ;Interrupt = IRQ+8

        mov cx,WORD PTR _Ptr[4]
        mov edx,DWORD PTR _Ptr

        push ds
        push cx
        pop ds
        mov ah,25h
        int 21h
        pop ds
Endm

SetIRQ Macro IRQ,Select,Offs
Local SmallIRQ
        mov al,IRQ
        cmp al,7
        jbe SmallIRQ
        add al,60h           ;Interrupt = IRQ+68h
SmallIRQ:
        add al,8             ;Interrupt = IRQ+8

        mov edx,Offset Offs

        push ds
        push Select
        pop ds
        mov ah,25h
        int 21h
        pop ds
Endm
EndIf

;******************* EOS *********************

If ((OS EQ EOS) OR (OS EQ EOS3))
;display 'IRQ EOS'

GetInt Macro Inter,_Ptr
        mov bl,Inter
        mov ah,Get_Int
        int_EOS

        mov DWORD PTR _Ptr,edx  ; Save Int offset
        mov WORD PTR _Ptr[4],cx ; Save Int selector	
Endm

RestInt Macro Inter,_Ptr
        mov bl,Inter
        mov cx,WORD PTR _Ptr[4]
        mov edx,DWORD PTR _Ptr

        mov ah,Set_Int
        int_EOS
Endm

SetInt Macro Inter,Select,Offs
        mov bl,Inter
        mov cx,Select
        mov edx,Offset Offs

        mov ah,Set_Int
        int_EOS
Endm

GetIRQ Macro IRQ,_Ptr
        mov bl,IRQ
        mov ah,Get_Irq
        int_EOS

        mov DWORD PTR _Ptr,edx  ; Save IRQ offset
        mov WORD PTR _Ptr[4],cx ; Save IRQ selector	
Endm

RestIRQ Macro IRQ,_Ptr
        mov bl,IRQ
        mov cx,WORD PTR _Ptr[4]
        mov edx,DWORD PTR _Ptr

        mov ah,Set_Irq
        int_EOS
Endm

SetIRQ Macro IRQ,Select,Offs
        mov bl,IRQ
        mov cx,Select
        mov edx,Offset Offs

        mov ah,Set_Irq
        int_EOS
Endm

Endif
; HARDWARE.INC (c) 1997 FreddyV/Useless
