;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÚÄÄÄÄÄÄÄÄÄ¿ ÚÄÄÄÄÄÄÄÄÄ¿ ÚÄÄÄÄÄÄÄÄÄ¿
;À¿  ÚÄÄÄ¿ ³ ³  ÚÄÄÄ¿  ³ ³  ÚÄÄÄÄ¿ ³
; ³  ³   ÀÄÙ ³  ³   ³  ³ ³  ³    ÀÄÙ
; ³  ÀÄÄ¿    ³  ³   ³  ³ ³  ÀÄÄÄÄÄÄ¿
; ³  ÚÄÄÙ    ³  ³   ³  ³ ÀÄÄÄÄÄÄ¿  ³
; ³  ³   ÚÄ¿ ³  ³   ³  ³ ÚÄ¿    ³  ³
;ÚÙ  ÀÄÄÄÙ ³ ³  ÀÄÄÄÙ  ³ ³ ÀÄÄÄÄÙ  ³
;ÀÄÄÄÄÄÄÄÄÄÙ ÀÄÄÄÄÄÄÄÄÄÙ ÀÄÄÄÄÄÄÄÄÄÙ        Eclipse Operating System
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Diss    macro po
	    x=po*160
	push eax
	push edi
	push es
	mov ax,cs:[DAta32_Sel]
	mov es,ax
            mov edi,es:[_0b0000h]
	mov Byte ptr es:[edi+x],01h
	pop es
	pop edi
	pop eax
	endm

unDiss    macro po
	    x=po*160
	push eax
	push edi
	push es
	mov ax,DAta32_Desc-GDT
	mov es,ax
            mov edi,es:[_0b0000h]
	mov Byte ptr es:[edi+x],0h
	pop es
	pop edi
	pop eax
	endm

Dissr   macro po
	push ax
	push es
            mov ax,0b800h
	mov es,ax
	mov W es:[10+160*po],0101h
	pop es
	pop ax
	endm

UnDissr   macro po
	push ax
	push es
            mov ax,0b800h
	mov es,ax
	mov W es:[10+160*po],0h
	pop es
	pop ax
	endm
Locals
.386p

INCLUDE ..\RESOURCE\EOS.INC

Global      Free_Sel        : Word
Global      Free_Sel_Offset : Dword

V86_Stack_Size      equ 300h                ; Size of stack for V86 calls

Nested_V86_switches equ 5

The_Stack_Size      equ  2000h

Pic1        = 80h                           ; Pic1 Base
Pic2        = 88h                           ; Pic2 Base

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                                                                          ³
;³                                                                          ³
;³  la Tss TASK STATE SEGMENT VCPI Only                                     ³
;³  Format of a 386DX Tss (Permet le passage en mode V86 et vice-versa)     ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                Tss struc
Tss_prev            dw 0,0                  ; back link to previous Tss
Tss_esp0            dd 0                    ; Priv. 0 ESP
Tss_ss0             dw 0,0                  ; Priv. 0 SS
Tss_esp1            dd 0                    ; Priv. 1 ESP
Tss_ss1             dw 0,0                  ; Priv. 1 SS
Tss_esp2            dd 0                    ; Priv. 2 ESP
Tss_ss2             dw 0,0                  ; Priv. 2 SS
Tss_cr3             dd 0                    ; PDBR
Tss_eip             dd 0
Tss_eflags          dd 0
Tss_eax             dd 0
Tss_ecx             dd 0
Tss_edx             dd 0
Tss_ebx             dd 0
Tss_esp             dd 0
Tss_ebp             dd 0
Tss_esi             dd 0
Tss_edi             dd 0
Tss_es              dw 0,0
Tss_cs              dw 0,0
Tss_ss              dw 0,0
Tss_ds              dw 0,0
Tss_fs              dw 0,0
Tss_gs              dw 0,0
Tss_ldt             dw 0,0
Tss_t               dw 0                    ; if bit 0 set, exception on task switch
Tss_iobase          dw 068h                 ; points to beg. of I/O permission map
Tss_iomap           db 2000h dup (0)        ; I/O permission bit map
Tss_ioend           db 11111111b            ; I/O map trailer
Tss_ends            db ?
	    ends

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                                                                          ³
;³                                                                          ³
;³  Format pour l'appel du fonction en mode reel via le serveur DPMI        ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DPMI_Real_mode_Call_Struct STRUC
V86_EDI         dd      ?
V86_ESI         dd      ?
V86_EBP         dd      ?
		dd      ?
V86_EBX         dd      ?
V86_EDX         dd      ?
V86_ECX         dd      ?
V86_EAX         dd      ?
V86_flags       dw      ?
V86_ES          dw      ?
V86_DS          dw      ?
V86_FS          dw      ?
V86_GS          dw      ?
V86_IP          dw      ?
V86_CS          dw      ?
V86_SP          dw      ?
V86_SS          dw      ?
	    ENDS




Kernel_Setup   SEGMENT PUBLIC USE16 'CODE'
ASSUME CS:Kernel_Setup


Msg_eos             db 'F/P/T!Fdmjqtf!Pqfsbujoh!Tztufn!!Wfstjpo!'
                        Ver_EOS,13,10
                    db 'Copyright (c) Eclipse 1995-99',13,10,36

Msg_V86_mode        db '    ş CPU already in V86 mode, and no DPMI or VCPI found.',13,10,36
Msg_A20             db '    ş Can not enable the A20 line.',13,10,36
Msg_dpmi_16         db '    ş DPMI host is not 32bit',13,10,36
Msg_dpmi_Pmode      db '    ş Cannot initialise DPMI protected mode',13,10,36
Msg_dpmi_Pmode2     equ $
Msg_386             db '    ş This program requires a 386 or better',13,10,36
Msg_dos_Ver         db '    ş This program requires DOS 3.00 or higher',13,10,36
Msg_dos_Mem         db '    ş Not enough memory to initialise protected mode',13,10,36
Msg_LoadHigh        db '    ş Please don''t use LoadHigh command to run this program',13,10,36
Msg_System          db '    ş System ',36
Msg_DPMI            db 'DPMI',36
Msg_VCPI            db 'VCPI',36
Msg_XMS             db 'XMS',36
Msg_Raw             db 'Top Down',13,10,36
Msg_Ver             db ' Version X.XX',13,10,36


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Nb_Free_Desc = 256

align 4
IDT_Base            dd 0
GDTR_Value          DW (Nb_Free_Desc*8+GDT_Ends)-1
                    DD 0

IDTR_Value          DW 07ffh,0,0
DOS_IDT_value       dw 03ffh,0,0
XMS_Code            dd 12345678h
                    db 0
XMS_Driver_DOS      dd 0
Old_21h             db 0
Old_a1h             db 0
Old_1718h           dw 0
Ser_Version         dw 0                    ; Version du Serveur
Config_Mem          dw 0,0
Psp_Segment         dw 0


EMM_Name1           db 'EMMXXXX0',0         ; device name for EMM
EMM_Name2           db 'EMMQXXX0',0         ; device name for EMM
					    ; With NOEMS Option
EMM_Name3           db '$MMXXXX0',0         ; device name for EMM
					    ; With NOEMS and NOVCPI Option
align 4
EMM_Handle          dw 0
Addr_System         dw 0            ; Adresse ou est construit la Tss idt etc
Addr_Stack          dw 0            ; Adresse de la memoire de la pile
Addr_Int            dw 0            ; Adresse de toutes les Int
Addr_Buffer         dw 0            ; Adresse du buffer des fichier
Addr_Exception      dw 0            ; Adresse Exception
Addr_GDT            dw 0

Vcpi_Sys            dd  O Vcpi_CR3
Vcpi_CR3            dd  0
Vcpi_GDTR           dd  O GDTR_Value
Vcpi_IDTR           dd  O IDTR_Value
Vcpi_LDTR           dw  0
Vcpi_TT             dw  MyMain_Tss_Desc - GDT
Vcpi_EIP            dd  O Setup_Pmode
Vcpi_CS             dw  Code32_Desc - GDT


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                                                                          ³
;³                                                                          ³
;³  la GDT GLOBAL DESCRIPTOR TABLE   (Decrit tous les Selecteurs du PRG)    ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
align 8
GDT         Label Near
	    dd 0,0

s_ACCESS record d_P:1,d_DPL:2,d_S:1,d_TYPE:4
s_INFO     record d_G:1,d_D:1,d_nul:1,d_avl:1,d_lim:4


;           16bit data and code DESCRIPTORS for real mode ( DOS )

Code16_Desc         dw 0ffffh                       ; Limit[15..0]
                    db ?,?,?                        ; Base[23..0]
                    s_ACCESS <1,00,1,0ah>           ; P,DPL,1,type[E=1,C,R,A ]
                    s_INFO <1,0,0,0,0fh>            ; G,D,0,avl,Limit[19..16]
                    db 0                            ; Base[31..24]

Data16_Desc         dw 0ffffh                       ; Limit[15..0]
                    db ?,?,?                        ; Base[23..0]
                    s_ACCESS <1,00,1,2h>            ; P,DPL,1,type[E=0,ED,W,A ]
                    s_INFO <1,0,0,0,0fh>            ; G,B,0,avl,Limit[19..16]
                    db 0                            ; Base[31..24]


;           DATA and CODE  DESCRIPTORS for the DOS extender kernel

Code32_Desc         dw 0ffffh                       ; Limit[15..0]
                    db ?,?,?                        ; Base[23..0]
                    s_ACCESS <1,00,1,0ah>           ; P,DPL,1,type[E=1,C,R,A ]
                    s_INFO <1,1,0,0,0fh>            ; G,D,0,avl,Limit[19..16]
                    db 0                            ; Base[31..24]

Data32_Desc         dw 0ffffh                       ; Limit[15..0]
                    db ?,?,?                        ; Base[23..0]
                    s_ACCESS <1,00,1,2h>            ; P,DPL,1,type[E=0,ED,W,A ]
                    s_INFO <1,1,0,0,0fh>            ; G,B,0,avl,Limit[19..16]
                    db 0                            ; Base[31..24]

;           Data and CODE DESCRIPTOR for a FLAT memory model

Flat_Code_Desc      dw 0ffffh                       ; Limit[15..0]
                    db 0,0,0                        ; Base[23..0]
                    s_ACCESS <1,00,1,0ah>           ; P,DPL,1,type[E=1,C,R,A ]
                    s_INFO <1,1,0,0,0fh>            ; G,D,0,avl,Limit[19..16]
                    db 0                            ; Base[31..24]

Flat_Data_Desc      dw 0ffffh                       ; Limit[15..0]
                    db 0,0,0                        ; Base[23..0]
                    s_ACCESS <1,00,1,2h>            ; P,DPL,1,type[E=0,ED,W,A ]
                    s_INFO <1,1,0,0,0fh>            ; G,B,0,avl,Limit[19..16]
                    db 0                            ; Base[31..24]


;           A SYSTEM Descriptor for the Tss needed for VCPI

MyMain_Tss_Desc     dw Size Tss                     ; Limit[15..0]
                    db ?,?,?                        ; Base[23..0]
                    s_ACCESS <1,00,0,09h>           ; P,DPL,0,(type  = avalaible 386 Tss )
                    s_INFO <0,0,0,0,00h>            ; G,0,0,0,Limit[19..16]
		db 0                            ; Base[31..24]

Data40h_Desc        dw 002ffh                       ; Limit[15..0]
                    db 00,4h,00                     ; Base[23..0]
                    s_ACCESS <1,00,1,2h>            ; P,DPL,1,type[E=0,ED,W,A ]
                    s_INFO <1,1,0,0,0ffh>           ; G,B,0,avl,Limit[19..16]
                    db 0                            ; Base[31..24]

Psp_Desc            dw 0ffffh                       ; Limit[15..0]
                    db 0,0,0                        ; Base[23..0]
                    s_ACCESS <1,00,1,2h>            ; P,DPL,1,type[E=0,ED,W,A ]
                    s_INFO <1,1,0,0,0fh>            ; G,B,0,avl,Limit[19..16]
                    db 0                            ; Base[31..24]

Environment_Desc    dw 0ffffh                       ; Limit[15..0]
                    db 0,0,0                        ; Base[23..0]
                    s_ACCESS <1,00,1,2h>            ; P,DPL,1,type[E=0,ED,W,A ]
                    s_INFO <1,1,0,0,0fh>            ; G,B,0,avl,Limit[19..16]
                    db 0                            ; Base[31..24]




VCPI_descriptors:

vcpi_code   Label qword
                dd 0,08*65536*256                   ; VCPI code descriptor

vcpi_data1  Label qword
                dd 0,08*65536*256                   ; VCPI data descriptor 1

vcpi_data2  Label qword
                dd 0,08*65536*256                   ; VCPI data descriptor 2


;Free_Desc   label Word
;                Rept Nb_Free_Desc
;                  dd 0,08*65536*256                 ; Set Free Bit
;                endm



GDT_Ends  equ  $ - GDT

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                                                                          ³
;³                                                                          ³
;³Debut Du KERNEL  avec test dur Processeur etc ..                          ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


.8086
ASSUME DS:Kernel_Setup

Display_String_Dos:
            push dx
            push ds
            push es
            push cs
            push cs
            pop ds
            pop es
            mov di,dx
            mov cx,-1
            mov ax,40h*256+'$'
            repne scasb
            neg cx
            sub cx,2
            mov bx,1
            Int 21h
            pop es
            pop ds
            pop dx
            ret

DosStart:
            cld
            push cs
            pop ds

            mov si,O Msg_eos
            mov cx,40
            @@decod:
            dec Byte ptr [si]
            inc si
            dec cx
            jnz @@decod

            mov dx,O Msg_eos
            call Display_String_Dos
            call Test_386
.386p
            mov bx,Seg END_SEG
            mov [Psp_Segment],es
            mov ax,es
            sub bx,ax
            add bx,small (((256*4)+(V86_Stack_Size*Nested_V86_switches+The_Stack_Size+15)+(Size_Memoy_Handle+Size_File_Block_Buffer+Size_ASCIIZ_Buffer+Size_ASCIIZ_Buffer2+Size_DTA+15)+(2000h+800h+Size Tss+1000h)+(Size_E+16)*32+15+(Nb_Free_Desc*8+GDT_Ends))/16)
            mov ah,4Ah
            int 21h
            mov dx,O Msg_dos_Mem
            jc Init_Pmode_Error
            mov ebx,Seg END_SEG
            mov [Addr_Int],bx
            add bx,(256*4)/16
            mov [Addr_Stack],bx
            add bx,(V86_Stack_Size*Nested_V86_switches+The_Stack_Size+15)/16
            mov [Addr_Buffer],bx
            add bx,(Size_Memoy_Handle+Size_File_Block_Buffer+Size_ASCIIZ_Buffer+Size_ASCIIZ_Buffer2+Size_DTA+15)/16
            mov [Addr_System],bx
            add bx,(2000h+800h+Size Tss+1000h)/16
            mov [Addr_Exception],bx
            add bx,small (((Size_E+16)*32+15)/16)
            mov [Addr_GDT],bx
            shl ebx,4
            mov D [GDTR_Value+2],ebx
            mov ah,30h
            int 21h
            mov dx,O Msg_dos_Ver
            cmp al,3h
            jb Init_Pmode_Error
            in al,21h
            mov [Old_21h],al
            in al,0a1h
            mov [Old_a1h],al
            push ds
            push 40h
            pop ds
            mov ax,ds:[17h]
            mov cs:[Old_1718h],ax
            pop ds
            call Allocate_Stack
            call Get_Ram
ASSUME DS:CODE32
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                                                                          ³
;³   Finit la Construction de la GDT + Mise a jour de quelques variables    ³
;³   qui ne peuvent etre definit a la compilation                           ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            mov eax,CODE32
            mov ds,ax
            mov ax,es
            shl eax,4
            mov [PSP_Addr],eax
            mov W [Psp_Desc+2],ax
            shr eax,16
            mov B [Psp_Desc+4],al
            mov ax,es:[2ch]
            shl eax,4
            mov [Environment_Addr],eax
            mov W [Environment_Desc+2],ax
            shr eax,16
            mov B [Environment_Desc+4],al


            mov eax,Kernel_Setup
            shl eax,4
            mov W [Code16_Desc+2],ax
            mov W [Data16_Desc+2],ax
            add [Vcpi_Sys],eax
            add [Vcpi_IDTR],eax
            add [Vcpi_GDTR],eax
            shr eax,16
            mov B [Code16_Desc+4],al
            mov B [Data16_Desc+4],al

            mov ax,CODE32
            shl eax,4
            mov [Code32_Addr],eax
            sub [_0a0000h],eax
            sub [_0b8000h],eax
            sub [_0b0000h],eax
            sub [Zero_Addr],eax
            sub [PSP_Addr],eax
            sub [Environment_Addr],eax
            mov W [Code32_Desc+2],ax
            mov W [Data32_Desc+2],ax
            shr eax,16
            mov B [Code32_Desc+4],al
            mov B [Data32_Desc+4],al

ASSUME DS:Kernel_Setup
            push cs
            push cs
            push cs
            push cs
            pop ds
            pop es
            pop fs
            pop gs
            call Save_All_Int
            call Read_Config
            call Detect_XMS
            push cs
            pop ax
            cmp ax,9000h
            mov dx,O Msg_LoadHigh
            jae Init_Pmode_Error
            call Init_Buffer
            call Test_VCPI
            call Test_DPMI
            call Test_RAW
            mov dx,O Msg_V86_mode
.8086
Init_Pmode_Error:
            call Display_String_Dos
            mov ax,4c01h
            int 21h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                        DPMI,VCPI,XMS,RAW                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Test la Presence d'un processeur 386 ou superieur                         ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : EAX EDX                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Test_386:
            mov ax,07000h
            push ax
            popf
            pushf
            pop ax
            and ax,07000h
            mov dx,O Msg_386
            je Init_Pmode_Error
            ret


.386p
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                        DPMI,VCPI,XMS,RAW                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Sauvegarde Toutes les Interruptions                                       ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Save_All_Int:
            mov es,cs:[Addr_Int]
            xor di,di
            xor si,si
            mov ds,si
            mov cx,256*2
            cli
            rep movsw
            sti
            push cs
            push cs
            pop ds
            pop es
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                        DPMI,VCPI,XMS,RAW                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Sauvegarde Toutes les Interruptions                                       ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Restore_Int:
            mov ds,cs:[Addr_Int]
            xor di,di
            xor si,si
            mov es,si
            mov cx,256*2
            rep movsw
            push cs
            push cs
            pop ds
            pop es
            ret



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                        DPMI,VCPI,XMS,RAW                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Allocate Stack Alloue la memoire pour la pile                             ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Allocate_Stack:
            xor eax,eax
            push es
            mov es,cs:[Addr_Stack]
            xor di,di
            mov cx,V86_Stack_Size*Nested_V86_switches+The_Stack_Size
            xor ax,ax
            rep stosb
            mov ax,es
            pop es
            push ds
            push CODE32
            pop ds
ASSUME DS:CODE32
            mov W [Real_SS],ax
            sub ax,CODE32
            shl eax,4
            add eax,V86_Stack_Size*Nested_V86_switches+The_Stack_Size-4
            and eax,0fffffffbh              ; Dword Align
            mov [Pmode_Stack],eax
ASSUME DS:Kernel_Setup
            pop ds
            ret


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                        DPMI,VCPI,XMS,RAW                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get Ram   Cherche la taille totale de RAM accessible                      ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_Ram:
            push ds
            push CODE32
            pop ds
ASSUME DS:CODE32
            push ax
            push ebx
            xor ebx,ebx
            mov al,30h
            out 70h,al
            in al,71h
            mov bl,al
            mov al,31h
            out 70h,al
            in al,71h
            mov bh,al
            shl ebx,10
            mov [ExtMem_Free],ebx           ; save amount of ext ram avalibe
            shr ebx,12
            add bh,1                        ; Add 1024 Ko of Base Memory
            test bx,3ffh
            je @@Ok1
            add ebx,03ffh                   ; align number of pages to 1024
            and bx,NOT 03ffh
@@Ok1:
            mov [NumOfPages],ebx            ; save Number of pages used
            pop ebx
            pop ax
            pop ds
ASSUME DS:Kernel_Setup
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                        DPMI,VCPI,XMS,RAW                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Display Type de System + version                                          ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie :                                                  ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Adjust_Hex macro x
Local aaaa
            cmp x,'9'
            jbe aaaa
            add x,'A'-'9'-1
aaaa:
	   endm


Display_Infos:
            pusha
            push ds
            push es
            push cs
            pop ds
            mov dx,O Msg_System
            call Display_String_Dos
            push CODE32
            pop es
ASSUME ES:CODE32
            mov dx,O Msg_Raw
            mov al,[Server_Type]
            cmp al,DPMI
            jne @@Ok1
            mov dx,O Msg_DPMI
@@Ok1:
            cmp al,VCPI
            jne @@Ok2
            mov dx,O Msg_VCPI
@@Ok2:
            cmp al,XMS
            jne @@Ok3
            mov dx,O Msg_XMS
@@Ok3:
            call Display_String_Dos
            cmp dx,O Msg_Raw
            je Affiche_Infos2
            mov ax,[Ser_Version]
            mov bx,ax
            mov ah,al
            and ax,0ff0h
            and bh,0fh
            shr al,4
            add ax,'00'
            add bh,'0'
            Adjust_Hex al
            Adjust_Hex ah
            Adjust_Hex bh
            mov [Msg_Ver+9],bh
            mov W [Msg_Ver+11],ax
            mov dx,O Msg_Ver
            call Display_String_Dos
Affiche_Infos2:
            pop es
            pop ds
ASSUME DS:Kernel_Setup,ES:Kernel_Setup
            popa
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                        DPMI,VCPI,XMS,RAW                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Detecte si une Driver XMS est present                                     ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Detect_XMS:
            mov ax,4300h                    ; Look for XMS driver installation
            int 2fh
            cmp al,80h
            jne No_XMS_Driver
            mov ax,4310h
            push es
            int 2fh
            mov W [XMS_Driver_DOS],bx
            mov W [XMS_Driver_DOS+2],es
ASSUME ES:CODE32
            push CODE32
            pop es
            xor ah,ah                       ; Get Version
            call [XMS_Driver_DOS]
            mov eax,[XMS_Driver_DOS]
            mov [XMS_Driver],eax
            mov [Ser_Version],bx
            mov [Server_Type],XMS           ; Show that we are running XMS
            cmp bx,300h
            jl @@Ok1
            or [XMS_Version_Poke1+1],80h
            or [XMS_Version_Poke2+1],80h
@@Ok1:
            mov ax,4309h
            int 2fh
            cmp word ptr es:[bx],0a01h
            jne @@Exit
            push ds
            mov cx,es:[bx+2]                ; Num hanlde
            mov si,es:[bx+4]
            mov ds,es:[bx+6]
            mov eax,1024*1024               ; 1first MB
@@Loop:
            cmp byte ptr ds:[si],4
            je @@Skip
            mov edx,ds:[si+6]
            shl edx,10
            add eax,edx
@@Skip:
            add si,10
            loop @@Loop
            pop ds
            push CODE32
            pop es
            add eax,4095
            shr eax,12
            mov [NumOfPages],eax            ; save Number of pages used
@@Exit:
            pop es
No_XMS_Driver:
            ret

ASSUME ES:Kernel_Setup

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                        DPMI,VCPI,XMS,RAW                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Read Config   Lit La config dans le fichier exe pour savoir la taille     ³
;³              Maxi de ram a alloue                                        ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Read_Config:
            pusha
            push ds
            push es
            mov ah,51h
            int 21h
            mov ds,bx
            mov ds,ds:[2ch]
            xor si,si
            mov cx,128
@@Ok1:
            lodsb
            dec al
            jne @@Ok1
            lodsb
            mov dx,si
            mov ax,3d00h
            int 21h
            jc @@Ok10
            mov bx,ax
            mov ax,4200h
            xor cx,cx
            mov dx,1ch
            int 21h
            jc @@Ok9
            push cs
            pop ds
            mov ah,3fh
            mov cx,4
            mov dx,O Config_Mem
            int 21h
            jc @@Ok9
            mov si,dx
            cmp W [si],'SL'
            jne @@Ok9
            movsx eax,W [si+2]
            cmp eax,512
            jb @@Ok9
ASSUME DS:CODE32
            push CODE32
            pop ds
            mov [Maximum_Allocate],eax
ASSUME DS:Kernel_Setup

@@Ok9:
            mov ah,3eh
            int 21h
@@Ok10:
            pop es
            pop ds
            popa
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                              DPMI                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Teste la Presence d'un serveur DPMI 0.90 ou 1.00                          ³
;³Si trouve DPMI init les Descipteurs et Init Pmode                         ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Test_DPMI:
            mov ax,1687h
            int 2Fh
            test ax,ax                      ; ax = 0 if DPMI is installed
            jne No_DPMI_Server              ; Jump to the code which enters p.mode
            mov ax,dx
            aam
            aad 16
            mov ah,dh
            test bl,1
            mov dx,O Msg_dpmi_16
            je Init_Pmode_Error
            mov [DPMI_Addr],di
            mov [DPMI_Addr+2],es
            mov [Ser_Version],ax
            mov bx,Seg END_SEG
            sub bx,[Psp_Segment]
            add bx,small (((256*4)+(V86_Stack_Size*Nested_V86_switches+The_Stack_Size+15)+(Size_Memoy_Handle+Size_File_Block_Buffer+Size_ASCIIZ_Buffer+Size_ASCIIZ_Buffer2+Size_DTA+15))/16)
            mov ah,4Ah
            int 21h
ASSUME ES:CODE32
            push CODE32
            pop es
            mov [Server_Type],DPMI          ; Show that we are running DPMI
            push cs
            pop es
ASSUME ES:Kernel_Setup
            test si,si
            je No_mem                       ; Test si le Serveur a Besoin
            mov bx,si                       ; de RAM pour son Init
            mov ah,48h
            int 21h
            mov dx,O Msg_dos_Mem
            jc Init_Pmode_Error
            mov es,ax
No_mem:
            call Display_Infos
            mov ax,0001h
            db 9ah
DPMI_Addr   Label Word
            dw 0,0
            jc Init_Pmode_Error

            push ds                         ; Push Data16_Sel
            push es                         ; Push Psp_Sel
            push W es:[2ch]                 ; Push Environment_Sel

            push ds                         ; load ES as data selector
            pop es

            mov ax,cs
            lar ax,ax                       ; this one puts accsess rights in AX
            xor si,si
            and ah,01100000b                ; we just want the DPL field.
@@Ok1:
            or B [Code32_Desc+si+5],ah
            add si,8
            cmp si,4*8
            jne @@Ok1


            xor ax,ax
            mov cx,1
            int 31h
            jc Print_DPMI_Error
            mov edi,O Data32_Desc
            mov bx,ax
            mov ax,0ch
            int 31h
            jc Print_DPMI_Error
ASSUME  DS:CODE32
            mov ds,bx
            mov [Data32_Sel],bx
            mov bp,3
            dw 6866h
            dd O Code32_Sel
            dw 6866h
            dd O Code32_Desc
            dw 6866h
            dd O Flat_Data_Sel
            dw 6866h
            dd O Flat_Data_Desc
            dw 6866h
            dd O Flat_Code_Sel
            dw 6866h
            dd O Flat_Code_Desc
@@Ok10:
            xor ax,ax
            mov cx,1
            int 31h
            jc Print_DPMI_Error
            pop edi
            pop esi
            mov ds:[esi],ax
            mov bx,ax
            mov ax,0ch
            int 31h
            jc Print_DPMI_Error
            dec bp
            jne @@Ok10
            pop [Environment_Sel]           ; Restore Environment_Sel
            pop [PSP_Sel]                   ; Restore Psp_Sel
            pop [Data16_Sel]                ; Restore Data16_Sel
            push bx                         ; BX = Code32_Sel
            mov bx,[PSP_Sel]
            mov ax,8
            mov cx,-1
            mov dx,cx
            int 31h                         ; Set Max size
            mov bx,[Environment_Sel]
            int 31h                         ; Set Max size
            mov ax,0204h
            mov bl,21h                      ; Save INT 21h
            int 31h
            mov W [old_DPMI_int21h+4],cx
            mov D [old_DPMI_int21h],edx
            pop cx
            inc al                          ; AX=0205h
            mov edx,O Int_21h
            int 31h
            mov bl,Int_Val_DOS
            mov edx,O DPMI_Emulate_Int
            int 31h
            mov bl,Int_Val_Call
            mov edx,O DPMI_Emulate_Call
            int 31h
            mov bl,Int_Val_EOS              ; Int EOS
            mov edx,O Interrupt_EOS
            int 31h
            mov bl,33h                      ; Int 33h
            mov edx,O Int_33h
            int 31h
            push es
            push ds
            pop es
            mov ds,cx                       ; DS=CX=Code32_Sel
            mov ax,0303h
            mov esi,O Int_06h
            mov edi,O Free_32h
            int 31h
            push es
            pop ds
            pop es
            mov es:[Call_Back_DPMI],dx
            mov es:[Call_Back_DPMI+2],cx
            mov ax,0400h
            int 31h
            mov W [Pic2_Base],dx
            push D [Code32_Sel]             ; Go in Pmode 32Bits
            dw 6866h
            dd O Setup_Pmode
            db 66h
            retf
ASSUME DS:Kernel_Setup
No_DPMI_Server:
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                              DPMI                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Affiche un message d'erreur en DPMI 16 Bits et retourne au DOS            ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Print_DPMI_Error:
            sub sp,Size DPMI_Real_mode_Call_Struct
            push ss
            pop es
            mov di,sp
            mov bp,sp
            mov W [bp+V86_EDX],O Msg_dpmi_Pmode
            mov B [bp+V86_EAX+1],40h
            mov W [bp+V86_EBX],1
            mov W [bp+V86_ECX],O Msg_dpmi_Pmode2-O Msg_dpmi_Pmode-1
            mov W [bp+V86_DS],Kernel_Setup
            mov ax,0300h
            mov bx,0021h
            xor cx,cx
            int 31h
            mov ax,4c01h
            int 21h


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                         DPMI,VCPI,XMS,RAW                                ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Alloue de la Memoire pour les differents buffer de passage du mode       ³
;³    proteger en mode reel (buffer de fichier,memory handles ....)         ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Init_Buffer:
            push CODE32
            pop ds
ASSUME DS:CODE32
            mov ax,cs:[Addr_Buffer]
            pushad
            push es
            mov es,ax
            xor di,di
            xor ax,ax
            mov cx,Size_Memoy_Handle+Size_File_Block_Buffer+Size_ASCIIZ_Buffer+Size_ASCIIZ_Buffer2+Size_DTA
            rep stosb
            pop es
            popad
            push ax
            movzx eax,ax
            mov [Seg_Buffer],eax
            sub eax,large CODE32
            shl eax,4
            add [Addr_List_Handle_Mem],eax
            add [Addr_List_Mem],eax
            add [Addr_List_Handle_Mapping],eax
            add [File_Block_Buffer_Addr],eax
            add [ASCIIZ_Buffer_Addr],eax
            add [ASCIIZ_Buffer2_Addr],eax
            add [Dta_Addr],eax
            pop ds
            mov dx,Size_Memoy_Handle+Size_File_Block_Buffer+Size_ASCIIZ_Buffer+Size_ASCIIZ_Buffer2
            mov ah,1ah
            int 21h                         ; Set New DTA
            push cs
            pop ds


ASSUME DS:Kernel_Setup
            ret
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Build GDT        Finish to Set-up the GDT                                 ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Build_GDT:
            push ds
            push es
            push cs
            pop ds
            mov es,cs:[Addr_GDT]
            xor di,di
            mov si,O GDT
            mov cx,GDT_Ends
            rep movsb
            mov cx,Nb_Free_Desc*8/4
            mov eax,08*65536*256
            rep stosd
ASSUME DS:CODE32
            push CODE32
            pop ds
            mov eax,es
            sub ax,CODE32
            shl eax,4
            add eax,large (GDT_Ends)
            mov [Free_Sel_Offset],eax
            pop es
            pop ds
ASSUME DS:Kernel_Setup
            ret


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Build Excpetions Met en place toutes les exceptions du mode proteger      ³
;³                 Compatible avec le DPMI 0.9                              ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;Common_Exception_Handling:
;            add esp,0
;            push ebx
;            mov bl,0
;            db 0e9h
;            dd 0
;
;Common_Exception_Exit:
;            mov dx,small (O exc_reserved)
;            mov bl,0
;            db 0eh
;            dd 0


Build_Exceptions:
            push ds
            push es
            mov es,cs:[Addr_Exception]
ASSUME DS:CODE32
            push CODE32
            pop ds
            xor edi,edi
            xor bx,bx
            xor ax,ax
            mov bp,es
            sub bp,CODE32
            neg bp
            movsx ebp,bp
            shl ebp,4
            lea edx,[ebp+6+5+Exception_Handling-Size_E]
@@Ok1:
            mov si,small (O Common_Exception_Handling)
            mov cx,Size_E
            rep movsb
            mov es:[di+4-Size_E],al         ; Numero de l'exception
            mov es:[di+6-Size_E],edx        ; Jump Relatif
            add edx,Close_Exception-Exception_Handling-11
            mov es:[di+0fh-Size_E],al       ; Numero de l'exception
            mov es:[di+11h-Size_E],edx      ; Jump Relatif
            sub edx,Size_E+Close_Exception-Exception_Handling-11
            inc ax
            cmp ax,32
            jne @@Ok1
            push es
            pop ds
            mov al,4
            mov B [bx+8*Size_E+2],al
            mov B [bx+10*Size_E+2],al
            mov B [bx+11*Size_E+2],al
            mov B [bx+12*Size_E+2],al
            mov B [bx+13*Size_E+2],al
            mov B [bx+14*Size_E+2],al
            mov W [bx+0*Size_E+0ch],small (O Exc_0)
            mov W [bx+1*Size_E+0ch],small (O Exc_1)
            mov W [bx+3*Size_E+0ch],small (O Exc_3)
            mov W [bx+4*Size_E+0ch],small (O Exc_4)
            mov W [bx+5*Size_E+0ch],small (O Exc_5)
            mov W [bx+6*Size_E+0ch],small (O Exc_6)
            mov W [bx+7*Size_E+0ch],small (O Exc_7)
            mov W [bx+8*Size_E+0ch],small (O Exc_8)
            mov W [bx+9*Size_E+0ch],small (O Exc_9)
            mov W [bx+10*Size_E+0ch],small (O Exc_10)
            mov W [bx+11*Size_E+0ch],small (O Exc_11)
            mov W [bx+12*Size_E+0ch],small (O Exc_12)
            mov W [bx+13*Size_E+0ch],small (O Exc_13)
            mov W [bx+14*Size_E+0ch],small (O Exc_14)
            mov W [bx+16*Size_E+0ch],small (O Exc_16)
            mov W [bx+17*Size_E+0ch],small (O Exc_17)
            mov W [bx+18*Size_E+0ch],small (O Exc_18)
            xor eax,eax
            movzx edi,di
            mov ax,ds
            sub ax,CODE32
            shl eax,4
            add eax,edi
            push CODE32
            pop ds
            mov [Addr_Exception_Tbl],eax
            add eax,32*8
            mov [Addr_Int_0_32_Tbl],eax
            sub eax,32*8
            sub eax,edi
            push es
            pop ds
            xor bx,bx
            add eax,Common_Exception_Exit-Common_Exception_Handling
@@Ok2:
            mov [bx+di],eax
            mov D [bx+di+4],Code32_Desc-GDT
            mov D [bx+di+8*32],O Simulate_V86_Int_0_32
            mov D [bx+di+4+8*32],Code32_Desc-GDT
            add eax,Size_E
            add bl,8
            jne @@Ok2

ASSUME DS:Kernel_Setup
            pop es
            pop ds
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Build Page Table Met en place la page 0th ,  la directory table           ³
;³                   la table de Tss (Task Switch) et IDT                   ³
;³           Offset 0 IDT                                                   ³
;³           Offset 800h Tss                                                ³
;³           Offset 800h+Size Tss   PageDirectory                           ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Build_Pmode:
            push ds
            push es
            mov ax,cs:[Addr_System]
            test ax,0ffh
            je @@Ok1
            add ax,0ffh                     ; align the address on 4KB boundry
@@Ok1:
            and eax,0ff00h
            mov cs:[Addr_System],ax
            mov es,ax
            shl eax,4                       ; Convert EAX into physical address of
ASSUME DS:CODE32,ES:Nothing
            mov edi,CODE32                  ; let  EDI = offset relative to
            mov ds,di                       ; CODE32 of the allocated memory
            shl edi,4
            sub edi,eax
            neg edi

            mov [PageDirectory_PhysAddr],eax ; Save the directory address
            mov [Vcpi_CR3],eax
            lea ecx,[eax+1000h+7]           ; Get physical address of the 0th page table
            mov es:[0],ecx                  ; Enter first directory entry
            add eax,2000h
            add edi,2000h

            mov D [IDTR_Value+2],eax        ; Set IDT Reg base address.
            mov [IDT_Addr],edi              ; Set the main IDT pointer
            add eax,800h

            mov W [MyMain_Tss_Desc+2],ax    ; This pointer is also used later when calling the V86 mode switch
            shr eax,16                      ; services so the Tss fields can be easily modified.
            mov B [MyMain_Tss_Desc+4],al
            mov B [MyMain_Tss_Desc+7],ah

            mov di,1000h
            mov eax,7h                      ; Set fields:   P=1 , R/W =1, U/S=1
            mov cx,1024                     ; Do the full 1024 entries.
@@Ok3:
            stosd
            add eax,1000h                   ; Increament page address by 4KB
            dec cx
            jne @@Ok3

            mov di,2000h                    ; Adresse de la IDT
            call Build_IDTR
            mov di,2800h                    ; Adresse de la Tss
            mov cx,(Size Tss+1)/2
            xor ax,ax
            rep stosw
            mov di,2800h                    ; Build the Tss
            mov es:[di.Tss_iobase],068h     ; Short No ?!?!?
            mov es:[di.Tss_ioend],11111111b

            pop es
            pop ds
ASSUME DS:Kernel_Setup,ES:Kernel_Setup
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Build IDTR  table construit la table d'interruptions                      ³
;³                                                                          ³
;³Entree :                                                                  ³
;³     ES:EDI = Adresse du la table IDT                                     ³
;³         DS = Segment CODE32                                              ³
;³                                                                          ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous  Sauf DS et ES                              ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ASSUME ES:CODE32,ds:Nothing
Build_IDTR:
            push ds
            push es
            pop ds
            pop es
            mov ax,Code32_Desc-GDT          ; Selector
            xor edx,edx                     ; 0,0,0,WordCnt[4..0]
            shl eax,16
            mov dh,s_ACCESS <1,00b,0,0Eh>   ; P,DPL,0,type = 386 interrupt
            mov ax,small (O Unhandled_Interrupt)
            xor bx,bx
            xor cl,cl
@@Ok1:
            mov [bx+di],eax                 ; offset 15..0
            mov [bx+di+4],edx               ; offset 31..16 & info
            add bx,8
            dec cl
            jne @@Ok1
            mov dx,[Addr_Exception]
            sub dx,CODE32
            movsx edx,dx
            shl edx,4
            xor bx,bx
@@Ok2:
            mov [bx+di],dx
            rol edx,16
            mov [bx+di+6],dx
            rol edx,16
            add edx,Size_E
            add bl,8
            jne @@Ok2
            mov W [di+8*21h],small (O Int_21h)      ; Int 21h
            mov W [di+8*23h],small (O Int_23h)      ; Int 23h
            mov W [di+8*24h],small (O Int_24h)      ; Int 24h
            mov W [di+8*33h],small (O Int_33h)      ; Int 33h
            mov W [di+8*Int_Val_EOS],small (O Interrupt_EOS)        ; Int EOS
            mov W [di+8*Int_Val_DOS],small (O Emulate_Int)          ; Int 62h
            mov W [di+8*Int_Val_Call],small (O Emulate_Call)        ; Int 63h

            mov dx,small (O IRQ0)
            mov bl,[Pic1_Base]              ; IRQ 0..7
            mov cx,0808h
            shl bx,3
@@Ok4:
            mov [bx+di],dx
            add bx,8
            add dx,small (IRQ1-IRQ0)
            dec cl
            jne @@Ok4
            xor bx,bx
            mov bl,[Pic2_Base]              ; IRQ 8..15
            shl bx,3
@@Ok5:
            mov [bx+di],dx
            add bx,8
            add dx,small (IRQ1-IRQ0)
            dec ch
            jne @@Ok5
@@Ok100:
            push ds
            push es
            pop ds
            pop es
ASSUME DS:Kernel_Setup,ES:Kernel_Setup
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                              VCPI                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Test la Presence d'un serveur VCPI version 1.00                           ³
;³                si trouve init Registres et Pmode                         ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Test_VCPI:
            push cs
            pop ds
            lea dx,EMM_Name1                ; open EMM device, read-only
            mov ax,3D00h
            int 21h
            jnc @@Ok10
            lea dx,EMM_Name2                ; open EMM device, read-only
            mov ax,3D00h                    ; With NOEMS option
            int 21h
            jnc @@Ok10
            lea dx,EMM_Name3                ; open EMM device, read-only
            mov ax,3D00h                    ; With NOEMS option & NOVCPI
            int 21h
            jc No_VCPI
@@Ok10:
            mov bx,ax                       ; get device information
            mov ax,4400h
            int 21h
            jc No_VCPI                      ; branch if error
            test dx,80h                     ; branch if file (not device)
            je No_VCPI
            mov ax,4407h                    ; check output status
            int 21h
            push ax                         ; save return code from IOCTL call
            mov ah,3Eh                      ; close file
            int 21h
            pop ax                          ; restore IOCTL return code
            cmp al,0FFh                     ; branch if status not device ready
            jne No_VCPI

            mov ax,0de00h                   ; is VCPI there?
            int 67h
            test ah,ah
            je Found_Vcpi

            mov ah,43h
            mov bx,1                        ; allocate 1 EMS page
            int 67h

            mov [EMM_Handle],dx

            mov ax,0de00h                   ; is VCPI there?
            int 67h
            test ah,ah
            jne No_VCPI

Found_Vcpi:
            push CODE32
            pop es
ASSUME ES:CODE32
            mov [Ser_Version],bx            ; Save Version
            mov [Server_Type],VCPI          ; Show that we are using VCPI

            call Display_Infos
            call Check_Free_IRQ
            call Build_Exceptions
            call Build_Pmode
            cli
            call Hook_Int_23h
            call Hook_Int_24h
            call Save_IRQ

            mov bl,es:[Pic1_Base]           ; Set these vectors
            mov bh,es:[Pic2_Base]
            call Set_8259intvec
            mov ax,0de0bh                   ; Set 8259A Interrupt Vector Mappings.
            movzx bx,es:[Pic1_Base]
            movzx cx,es:[Pic2_Base]
            int 67h

;            mov ax,0de0ah                   ; Get 8259A Interrupt Vector Mappings.
;            int 67h                         ; To be sure
;            mov [Pic1_Base],bl
;            mov [Pic2_Base],cl


            mov es,[Addr_System]
            mov di,1000h                    ; ES:DI =  0th page table.
            mov si,O VCPI_descriptors       ; DS:SI =  three descriptors.
            mov ax,0de01h
            int 67h
            push CODE32
            pop es
            mov D [VCPI_Addr],ebx           ; Entry Point
ASSUME ES:Kernel_Setup
            call Build_GDT
            mov eax,O Setup_Pmode
            jmp VCPI_Switch_PMODE

No_VCPI:
            ret


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                              VCPI                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³VCPI Switch Pmode  Saute en PMODE via le serveur VCPI                     ³
;³                                                                          ³
;³Entree :                                                                  ³
;³        EAX = Adresse Lineaire dans le Segment CODE32 de la routine a     ³
;³              appele                                                      ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : EAX ESI                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ASSUME DS:Kernel_Setup
VCPI_Switch_PMODE:
            cli
            mov D cs:[Vcpi_EIP],eax
            mov esi,cs:[Vcpi_Sys]
            mov ax,0de0ch
            int 67h


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                              VCPI                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³VCPI Terminate Program  Retour de Pmode avec la fonction 4ch Int 21h      ³
;³                   Restaure les IRQs et Retourne au DOS                   ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VCPI_Terminate_Program:
            cli
            call Restore_Int
            mov bx,7008h
            call Set_8259intvec
            mov ax,0de0bh                   ; Set 8259A Interrupt Vector Mappings.
            mov bx,08h
            mov cx,70h
            int 67h
            mov ah,45h
            mov bx,1                        ; Deallocate the EMS page
            mov dx,[EMM_Handle]
            test dx,dx
            je Exit_to_DOS                  ; Return to DOS
            int 67h
            jmp Exit_to_DOS                 ; Return to DOS




;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                             XMS,RAW                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Verifie que le Processeur soit bien en mode reel et                       ³
;³                si OK init Registres et Pmode                             ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Test_RAW:
            smsw ax
            test al,1
            je Raw_Ok
            ret
Raw_Ok:
            call Hook_Int_15h
            call Display_Infos
            call Check_Free_IRQ
            call Build_GDT
            call Build_Exceptions
            call Build_Pmode
            call Enable_A20
            cli
            call Hook_Int_23h
            call Hook_Int_24h
            push CODE32
            pop es
ASSUME ES:CODE32
            mov bl,es:[Pic1_Base]                     ; Set these vectors
            mov bh,es:[Pic2_Base]
            call Set_8259intvec
            call Save_IRQ
            mov [V86_Exit_XMS_RAW],O Raw_Switch_Pmode; for Return to V86
            mov [V86_Irq_XMS_RAW],O Raw_Switch_Pmode; for Return to V86
            mov [V86_Call_XMS_RAW],O Raw_Switch_Pmode; for Return to V86
            mov eax,O Setup_Pmode
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                             XMS,RAW                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Raw Switch Pmode  en Mode protege avec l'addresse passe dans EAX          ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Raw_Switch_Pmode:
            cli
            lidt F cs:[IDTR_Value]
            lgdt F cs:[GDTR_Value]
            push  eax
            push CODE32
            pop ds
ASSUME DS:CODE32
            mov eax,[PageDirectory_PhysAddr]     ; Reload the TLB
            mov CR3,eax                     ;(before setting PE)
            mov eax,CR0
            or eax,80000001h                ; Set the PE bit
            mov CR0,eax
ASSUME DS:Kernel_Setup
            pop eax
            db 0eah
            dw Small Do_Jump_EAX,Code32_Desc-GDT

ASSUME ES:Kernel_Setup
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                             XMS,RAW                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Go_REAL_Mode Retourne an mode reel restaure la pile etc et va au dos      ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Go_Real_Mode:
            mov ds,cs:[Data16_Sel]
            mov ds:[Jump_Real],ax
            jmp $+2                         ; Clear Prefetch
            mov ax,Data16_Desc - GDT        ; Must Load Valid Value Selector
            mov ss,ax
            mov es,ax
            mov fs,ax
            mov gs,ax
            lidt F [DOS_IDT_value]
            mov eax,CR0
            and eax,7fffffFEh               ; Clear both PE & PG bits
            mov CR0,eax
            xor eax,eax
            mov CR3,eax
            db 0eah
Jump_Real   dw 0
            dw Kernel_Setup


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                             XMS,RAW                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Exit To Dos Raw Retourne au en restaure IRQ                               ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Exit_To_DOS_Raw:
            cli
            mov ax,STACK32
            mov ss,ax
            mov esp,V86_Stack_Size
            push cs
            pop ds
            cmp [XMS_Driver_DOS],0
            je @@Ok1
            call Set_Real_XMS
@@Ok1:
            call Restore_Int
            mov bx,7008h
            call Set_8259intvec
            jmp Exit_to_DOS

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                             XMS,RAW                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Enable A20  Active la Ligne A20                                           ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³        A20 Active Sinon sortie avec message d'erreur                     ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Enable_A20:
            mov dx,O Msg_A20
            cmp [XMS_Driver_DOS],0
            je EnableA20_directly
            mov ah,03h
            call cs:[XMS_Driver_DOS]
            test ax,ax
            je Init_Pmode_Error
            call TestA20
            je Init_Pmode_Error
            cli
            les si,[XMS_Driver_DOS]         ;  Save the first 5 bytes of
            mov eax,es:[si]                 ;  the XMS driver's entry point
            mov [XMS_Code],eax
            mov al,es:[si+4]
            mov B [XMS_Code+4],al
            call Set_Fake_XMS               ; Replace them with our jump instruction.
            db 066h,0b8h
            dw O XMS_Fake
            dw Kernel_Setup
            push ds
            push CODE32
            pop ds
ASSUME DS:CODE32
            mov [XMS_Driver],eax
            pop ds
ASSUME DS:Kernel_Setup
            jmp A20_enabled

EnableA20_directly:
            call TestA20
            jne A20_enabled
            in al,92h                       ; Enable A20 gate for PS2 computers
            or al,2
            jmp $+2
            jmp $+2
            jmp $+2
            out 92h,al
            call TestA20
            jne A20_enabled
            call Wait_A20
            xor cx,cx                       ; Suppost to wait around until it the
@@Ok1:                                      ; bit gets enabled.
            in al,92h
            test al,00000010b
            loopz @@Ok1
            je Try_A20_via_8042
            call TestA20                    ; If it failed then try AT method
            jne A20_enabled
Try_A20_via_8042:                           ; Enable A20 gate for AT computers
            call Wait_A20
            mov al,0D1h                     ; write output port command ( 0D1h )
            out 64h,al
            call Wait_A20
            mov al,0DFh                     ; write data to the output port
            out 60h,al                      ; seting bit 1 enables the A20 gate
            call Wait_A20
            mov al,0FFh                     ; Send FFh ( Pulse output port )
            out 64h,al
            call Wait_A20
            call TestA20
            je Init_Pmode_Error
A20_enabled:
            sti
            ret



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                             XMS,RAW                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Test si la Ligne A20 est activee ou non                                   ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³        Zero Flags = 0 Ligne A20 Activee                                  ³
;³                     1 Ligne A20 DesActivee                               ³
;³                                                                          ³
;³Autre Registre Modifie : AX                                               ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TestA20:
            push es
            push ds
            xor ax,ax
            mov ds,ax
            dec ax
            mov es,ax
            mov ah,12h
            mov al,ds:[0]
            cmp al,es:[10h]
            jne @@Ok1
            push W ds:[0]
            mov B ds:[0],ah
            cmp B es:[10h],ah
            pop W ds:[0]
@@Ok1:
            pop ds
            pop es
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                             XMS,RAW                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Wait_A20  Attend que le 8042 soit pres a recevoir un commande             ³
;³          si Toujours OQP sortie avec message d'erreur                    ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³        Zero Flags = 0 Ligne A20 Activee                                  ³
;³                     1 Ligne A20 DesActivee                               ³
;³                                                                          ³
;³Autre Registre Modifie : AX DX                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Wait_A20:
            xor cx,cx
@@Ok1:
            jmp $+2
            jmp $+2
            jmp $+2
            in al,64h
            test al,2
            loopnz @@Ok1
            jne Init_Pmode_Error
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                                 XMS                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set_Real_XMS  Remet en Place les Vecteurs detournes de la routine XMS     ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set_Real_XMS:
            push eax
            push si
            push ds
            lds si,cs:[XMS_Driver_DOS]
            mov eax,cs:[XMS_Code]
            mov ds:[si],eax
            mov al,B cs:[XMS_Code+4]
            mov ds:[si+4],al
            pop ds
            pop si
            pop eax
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                                 XMS                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set_Fake_XMS  Remplace les 5 premiers octects de la routine XMS par une   ³
;³              routine detournee par la KERNEL                             ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set_Fake_XMS:
            push si
            push ds
            lds si,cs:[XMS_Driver_DOS]
            mov B ds:[si],0EAh
            db 66h,0c7h,44h,01h             ; mov D [si+1],O XMS_Fake
            dw O XMS_Fake
            dw Kernel_Setup
            pop ds
            pop si
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                                 XMS                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Fake_XMS  Remplace la fonction 4 et 6 de l'XMS pour eviter que la A20 ne  ³
;³          soit Desactive                                                  ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
XMS_Fake:
            cmp ah,4
            je @@Ok1
            cmp ah,6
            je @@Ok1
            call Set_Real_XMS
            call cs:[XMS_Driver_DOS]
            call Set_Fake_XMS
            retf
@@Ok1:
            mov bl,94h                      ; Retour avec une BELLE erreur :
            xor ax,ax                       ; 94h Ligne A20 toujours valide
            retf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                              RAW                                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Hook Int15h  Detourne Int15 pour dire qu'il n'y a plus de memoire         ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : EAX                                              ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Hook_Int_15h:
            cmp [XMS_Driver_DOS],0          ; XMS ???
            jne @@Ok10
            push es
            xor eax,eax
            mov es,ax
            mov ah,88h
            int 15h
            db 066h,0bbh
            dw O New_Int_15h
            dw Kernel_Setup
            xchg ebx,es:[4*15h]
            mov [Old_Int_15h],ebx
Assume ES:CODE32
            push CODE32
            pop es
            mov bx,ax
            shl eax,10
            sub bx,W [Maximum_Allocate]
            mov [ExtMem_Free],eax
            jle @@Ok1
            mov [Memory_Int_15h],bx
@@Ok1:
            pop es
@@Ok10:
Assume ES:Kernel_Setup
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                              RAW                                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³New Int15h  Nouvelle Int15 pour dire qu'il n'y a plus de memoire          ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : AX                                               ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
New_Int_15h:
            pushf
            cmp ah,88h                      ; Size memory ?
            je New_Int_15h_2
            popf
            db 0eah
Old_Int_15h dd 0

New_Int_15h_2:
            popf
            db 0b8h
Memory_Int_15h dw 0                         ;  memory left
            iret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Init Int 23h Hook the 23h Interrupt for pmode support                     ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : EAX                                              ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Hook_Int_23h:
            push ds
            push 0
            pop ds
            db 066h,0b8h
            dw O New_Int_23h
            dw Kernel_Setup
            mov ds:[4*23h],eax
            pop ds
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³New Int 23h                                                               ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie :                                                  ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
New_Int_23h:
            mov cs:[Real_Int],23h*8
            jmp Do_Call_Back_Pmode

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Init Int 24h Hook the 24h Interrupt for pmode support                     ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : EAX                                              ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Hook_Int_24h:
            push ds
            push 0
            pop ds
            db 066h,0b8h
            dw O New_Int_24h
            dw Kernel_Setup
            xchg eax,ds:[4*24h]
            mov cs:[Old_Int_24h],eax
Assume DS:CODE32
            push CODE32
            pop ds
            mov [New_Int_24h_Pmode+4],Code32_Desc-GDT
Assume DS:Kernel_Setup
            pop ds
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³New Int 14h                                                               ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie :                                                  ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
New_Int_24h:
            mov cs:[Real_Int],24h*8
            jmp Do_Call_Back_Pmode
            iret

Old_Int_24h dd 0

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                      DPMI,VCPI,XMS,RAW                                   ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Function 000ch of the 33h Interrupt for pmode support                     ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : EAX                                              ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Assume DS:CODE32
New_000ch:
            cli
            mov cs:[Tmp_EAX],eax
            mov cs:[Tmp_EBX],ebx
            mov cs:[Tmp_ECX],ecx
            mov cs:[Tmp_EDX],edx
            mov cs:[Tmp_ESI],esi
            mov cs:[Tmp_EDI],edi
            push ds
            push CODE32
            pop ds
;            mov [Set_Function_000ch],On
Addr_000ch_Offset:
            mov D [Addr_Call],12345678h
Addr_000ch_Selector:
            mov W [Addr_Call+4],1234h
            cmp [Server_Type],DPMI
            je Test0
            pop ds
            jmp Do_Call_Back_Pmode_Call

Test0:
            push CODE32
            pop ds
            mov [Set_Function_000ch],On
            pop ds
            db 0eah
Call_Back_DPMI dw 0,0
@@Ok0:
            retf

Tmp_EAX     dd 0
Tmp_EBX     dd 0
Tmp_ECX     dd 0
Tmp_EDX     dd 0
Tmp_ESI     dd 0
Tmp_EDI     dd 0

Assume DS:Kernel_Setup
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Check Free IRQ   Recherche dans la table de vecteurs des INT libres pour  ³
;³                 Rediriger les IRQ                                        ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ASSUME ES:CODE32
Check_Free_IRQ:
            push es
            push ds
            push CODE32
            pop es
            xor si,si
            mov ds,si
            mov cx,8
            xor bx,bx
@@SearchBase1:
            mov ax,[bx+si]
            or ax,[bx+si+2]
            jne @@Next_8BlockBase1
            add si,4
            loop @@SearchBase1
            cmp bx,(Int_Val_EOS and 0f8h) shl 2
            je @@Next_8BlockBase1
            add bx,bx
            mov cs:[Change_IRQ1_7+5],bx
            shr bx,3
            mov cx,8
            mov es:[Pic1_Base],bl
            shl bx,2
            add bx,8*4
            cmp bx,256*4
            jae @@End
            jmp @@SearchBase2
@@Next_8BlockBase1:
            xor si,si
            add bx,8*4
            mov cx,8
            cmp bx,256*4
            jae @@End
            jmp @@SearchBase1


@@SearchBase2:
            mov ax,[bx+si]
            or ax,[bx+si+2]
            jne @@Next_8BlockBase2
            add si,4
            loop @@SearchBase2
            cmp bx,(Int_Val_EOS and 0f8h) shl 2
            je @@Next_8BlockBase2
            add bx,bx
            mov cs:[Change_IRQ8_15+5],bx
            shr bx,3
            mov es:[Pic2_Base],bl
            jmp @@End
@@Next_8BlockBase2:
            xor si,si
            add bx,8*4
            mov cx,8
            cmp bx,256*4
            jb @@End
@@End:
            pop ds
            pop es
            ret



ASSUME ES:Kernel_Setup
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Save Irq   Sauvegarde toutes les IRQ des Pics et prepare pour le call-back³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : AX BX BP SI ECX EDX                              ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ASSUME DS:CODE32
Save_IRQ:
            cli
            push ds
            push CODE32
            pop ds
            movzx bx,[Pic1_Base]
            movzx bp,[Pic2_Base]
            shl bx,2
            shl bp,2
            cli                             ; No interrupts when setting vectors
ASSUME DS:Nothing
            xor si,si
            mov ds,si
            db 066h,0b9h
            dw O V86_Irq0
            dw Kernel_Setup
            db 066h,0bah
            dw O V86_Irq8
            dw Kernel_Setup
@@Ok20:
            mov ds:[bx+si],ecx
            mov ds:[bp+si],edx
            add cx,(O V86_Irq1-O V86_Irq0)
            add dx,(O V86_Irq1-O V86_Irq0)
            add si,4
            cmp si,4*8
            jne @@Ok20
            pop ds
            ret
ASSUME DS:Kernel_Setup

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set_8259   Change l'adresse des IRQ en mode reel                          ³
;³                                                                          ³
;³Entree :                                                                  ³
;³        BL = IRQ 0..7 Base                                                ³
;³        BH = IRQ 8..15 Base                                               ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : AX                                               ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Wait_ macro
	    jmp $+2
      endm
Set_8259intvec:
            in al,0A1h                      ; Save the MASK 2 register
            mov ah,al
            in al,21h                       ; Save the MASK 1 register
            push ax
            mov al,00010001b                ; ICW1 (icw4 is needed)
            out 20h,al
            Wait_
            mov al,00010001b                ; ICW1 (icw4 is needed)
            out 0A0h,al
            Wait_
            mov al,bl                       ; ICW2
            out 21h,al                      ; (Set PIC 1 Base interrupt number )
            Wait_
            mov al,bh                       ; ICW2
            out 0A1h,al                     ; (Set PIC 2 Base interrupt number )
            Wait_
            mov al,000000100b               ; ICW3
            out 21h,al
            Wait_
            mov al,00000010b                ; ICW3
            out 0a1h,al
            Wait_
            mov al,00000001b                ; ICW4
            out 21h,al
            Wait_
            mov al,00000001b                ; ICW4
            out 0A1h,al
            Wait_
            pop ax                          ; return IRQ mask bits
            out 21h,al
            mov al,ah
            out 0A1h,al
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Exit To Dos Restaure le timer les mask d'irq et met une pile correct      ³
;³            puis retourne au bon vieux DOS                                ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Exit_to_DOS:
            cli
            push cs
            push cs
            push cs
            push cs
            pop ds
            pop es
            pop fs
            pop gs
            mov al,36h
            out 43h,al
            xor al,al
            out 40h,al
            out 40h,al
            in al,60h
            mov al,20h
            out 20h,al
            out 0A0h,al
            mov al,[Old_21h]
            out 21h,al
            mov al,[Old_a1h]
            out 0a1h,al
            push ds
            push 40h
            pop ds
            mov W ds:[17h],0
            mov ah,1
            int 16h                 ; Restore Leds
            mov ax,cs:[Old_1718h]
            mov W ds:[17h],ax
            mov ah,1
            int 16h                 ; Restore Leds
            pop ds
            movzx esp,sp
            xor eax,eax
            xor ebx,ebx
            xor ecx,ecx
            xor edx,edx
            xor esi,esi
            xor edi,edi
            xor ebp,ebp
            sti
Code_Erreur Label Byte
            mov ax,4C00h
            int 21h




;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Emulate Real Int Call                                                     ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
align 4
Save_EAX    dd 0                            ; Save EAX and ESI for swithing
Save_ESI    dd 0
Save_Flags  dw 0                            ; in Pmode

Emulate_Real_Int_Call:
ASSUME DS:CODE32
            mov ax,CODE32
            mov ds,ax
            mov ax,W [Real_DS]
            mov es,W [Real_ES]
            mov fs,W [Real_FS]
            mov gs,W [Real_GS]
            mov ss,W [Real_SS]
            movzx esp,W [Real_SP]
            mov ds,ax
Emulate_Real_Int_Call_VCPI:
            mov eax,cs:[Save_EAX]           ; get eax
            push cs:[Save_Flags]
            popf
V86_Int     db 90h
            db 9Ah                          ; op code for Call Instruction
V86_Instruction     Label Word
            dd 0                            ; offset, segment
            pushf
            cli
            mov cs:[Save_ESI],esi
            mov cs:[Save_EAX],eax
            pop cs:[Save_Flags]             ; Save Flags
            push ds
            push CODE32
            pop ds
            pop W [Real_DS]
            mov W [Real_ES],es
            mov W [Real_FS],fs
            mov W [Real_GS],gs
            db 0beh
V86_Exit_XMS_RAW Label Word                 ; Poke Jmp if XMS or RAW
            dw O VCPI_Switch_PMODE          ; return to protected mode
            mov eax,O Return_From_V86
            jmp si


ASSUME ds:Kernel_Setup



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³VCPI V86 Irq  ces routines servent quand une irq a ete                    ³
;³              declencher en mode V86 pour faire un call back en Pmode     ³
;³                                                                          ³
;³Entree :                                                                  ³
;³        EAX = Adresse Lineaire dans le Segment CODE32 de la routine a     ³
;³              appele                                                      ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : EAX ESI                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

align 4
V86irq_SS_save      dw 0
V86irq_SP_save      dw 0
Real_Int            dw 0

V86_Irq0:
            push 00*8
            jmp Short Do_V86_IRQ1_7
V86_Irq1:
            push 01*8
            jmp Short Do_V86_IRQ1_7
V86_Irq2:
            push 02*8
            jmp Short Do_V86_IRQ1_7
V86_Irq3:
            push 03*8
            jmp Short Do_V86_IRQ1_7
V86_Irq4:
            push 04*8
            jmp Short Do_V86_IRQ1_7
V86_Irq5:
            push 05*8
            jmp Short Do_V86_IRQ1_7
V86_Irq6:
            push 06*8
            jmp Short Do_V86_IRQ1_7
V86_Irq7:
            push 07*8
            jmp Short Do_V86_IRQ1_7
V86_Irq8:
            push 00*8
            jmp Short Do_V86_IRQ8_15
V86_Irq9:
            push 01*8
            jmp Short Do_V86_IRQ8_15
V86_Irq10:
            push 02*8
            jmp Short Do_V86_IRQ8_15
V86_Irq11:
            push 03*8
            jmp Short Do_V86_IRQ8_15
V86_Irq12:
            push 04*8
            jmp Short Do_V86_IRQ8_15
V86_Irq13:
            push 05*8
            jmp Short Do_V86_IRQ8_15
V86_Irq14:
            push 06*8
            jmp Short Do_V86_IRQ8_15
V86_Irq15:
            push 07*8
            jmp Short Do_V86_IRQ8_15

Do_V86_IRQ1_7:
            pop cs:[Real_Int]
Change_IRQ1_7 label word
            add cs:[Real_Int],Pic1*8
            jmp Do_Call_Back_Pmode
Do_V86_IRQ8_15:
            pop cs:[Real_Int]
Change_IRQ8_15 label word
            add cs:[Real_Int],Pic2*8
Do_Call_Back_Pmode:
            cli
            mov cs:[Tmp_EAX],eax            ; Save the destroyed registers
            mov cs:[Tmp_ESI],esi            ; EAX & ESI use for Int 24h
            push ds
            push es                         ; Save all segment registers
            push fs
            push gs
            push cs:[V86irq_SS_save]
            push cs:[V86irq_SP_save]
            mov cs:[V86irq_SS_save],ss
            mov cs:[V86irq_SP_save],sp
            db 0beh
V86_Irq_XMS_RAW Label Word                  ; Poke Jmp if XMS or RAW
            dw O VCPI_Switch_PMODE          ; return to protected mode
            mov eax,O Pmode_V86irqs_Handler
            jmp si
Handle_V86_Irqs:
            mov ss,cs:[V86irq_SS_save]
            movzx esp,cs:[V86irq_SP_save]
            pop cs:[V86irq_SP_save]
            pop cs:[V86irq_SS_save]
            pop gs
            pop fs
            pop es
            pop ds
            mov eax,cs:[Tmp_EAX]
            mov esi,cs:[Tmp_ESI]
            iret


Do_Call_Back_Pmode_Call:
            pushad                          ; Save the destroyed registers
            push ds
            push es                         ; Save all segment registers
            push fs
            push gs
            push cs:[V86irq_SS_save]
            push cs:[V86irq_SP_save]
            mov cs:[V86irq_SS_save],ss
            mov cs:[V86irq_SP_save],sp
            db 0beh
V86_Call_XMS_RAW Label Word                 ; Poke Jmp if XMS or RAW
            dw O VCPI_Switch_PMODE          ; return to protected mode
            mov eax,O Pmode_V86calls_Handler
            jmp si
Handle_V86_Calls:
            mov ss,cs:[V86irq_SS_save]
            movzx esp,cs:[V86irq_SP_save]
            pop cs:[V86irq_SP_save]
            pop cs:[V86irq_SS_save]
            pop gs
            pop fs
            pop es
            pop ds
            popad
            retf

Kernel_Setup ENDS




;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                        DPMI,VCPI,XMS,RAW                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;ºThe 32bits Code                                                           º
;º                                                                          º
;º                                                                          º
;º                                                                          º
;º                                                                          º
;º                                                                          º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Nb_Handle_Mem               = 128 ; MUST BE EQUAL
Nb_Handle_Mapping           = 128 ;       "
Size_Memoy_Handle0          = 128*4
Size_Memoy_Handle           = Size_Memoy_Handle0*6
Size_File_Block_Buffer      = 8192*2
Size_ASCIIZ_Buffer          = 128*2
Size_ASCIIZ_Buffer2         = 128*2
Size_DTA                    = 128

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME    CS:CODE32,ds:CODE32,ES:CODE32,FS:CODE32,GS:CODE32,SS:CODE32
Maximum_Allocate            dd -1 ;16384
Addr_List_Handle_Mem        dd 0                    ; Dup (0,0)
Addr_List_Mem               dd Size_Memoy_Handle0*2 ; Dup (0)     Sans Handle
Addr_List_Handle_Mapping    dd Size_Memoy_Handle0*3 ; Dup (0,0,0) Sans Handle
File_Block_Buffer_Addr      dd Size_Memoy_Handle
ASCIIZ_Buffer_Addr          dd Size_Memoy_Handle+Size_File_Block_Buffer
ASCIIZ_Buffer2_Addr         dd Size_Memoy_Handle+Size_File_Block_Buffer+Size_ASCIIZ_Buffer
Dta_Addr                    dd Size_Memoy_Handle+Size_File_Block_Buffer+Size_ASCIIZ_Buffer+Size_ASCIIZ_Buffer2
Seg_Buffer                  dd 0
O_File_Block_Buffer         dd Size_Memoy_Handle
O_ASCIIZ_Buffer             dd Size_Memoy_Handle+Size_File_Block_Buffer
O_ASCIIZ_Buffer2            dd Size_Memoy_Handle+Size_File_Block_Buffer+Size_ASCIIZ_Buffer
O_DTA                       dd Size_Memoy_Handle+Size_File_Block_Buffer+Size_ASCIIZ_Buffer+Size_ASCIIZ_Buffer2
_0b0000h                    dd 0b0000h
_0b8000h                    dd 0b8000h
_0a0000h                    dd 0a0000h
Zero_Addr                   dd 0
Environment_Addr            dd 0
PSP_Addr                    dd 0
Code32_Addr                 dd 0
IDT_Addr                    dd 0
PageDirectory_PhysAddr      dd 0
Addr_PageTables             dd 0
Addr_MappingTables          dd 0
Addr_Exception_Tbl          dd 0
Addr_Int_0_32_Tbl           dd 0
Current_Addr_Mapping        dd 0
NumOfPages                  dd 0
Data16_Sel                  dw Data16_Desc - GDT
Code32_Sel                  dw Code32_Desc - GDT
Data32_Sel                  dw Data32_Desc - GDT
Flat_Data_Sel               dw Flat_Data_Desc - GDT
Flat_Code_Sel               dw Flat_Code_Desc - GDT
Free_Sel                    dw GDT_Ends
PSP_Sel                     dw Psp_Desc - GDT
Environment_Sel             dw Environment_Desc - GDT
Free_Sel_Offset             dd 0
XMS_Driver                  dd 0
Real_DS                     dd 0
Real_ES                     dd 0
Real_FS                     dd 0
Real_GS                     dd 0
Real_SS                     dd 0            ; Setup initial V86 stack
Real_SP                     dd V86_Stack_Size*Nested_V86_switches
Pmode_Stack                 dd 0
ESP_Save                    dd 0
SS_Save                     dw 0
ExtMem_Free                 dd 0
old_DPMI_int21h             df 0
Flags_Hold                  dw 0
VCPI_Addr                   Label Fword
                            dd 0
                            dw vcpi_code-GDT
Server_Type                 db RAW          ; default to custom
Pic2_Base                   db Pic2         ; address for the 8259s
Pic1_Base                   db Pic1         ; These Holds Base interrupt
Exc_                        db '    ş Error exception '
exc_Num                     db '00 : ',36

Exc_0                       db 'Divide error',13,10,36
Exc_1                       db 'Debug exceptions',13,10,36
Exc_3                       db 'Breakpoint',13,10,36
Exc_4                       db 'Overflow',13,10,36
Exc_5                       db 'Bounds check',13,10,36
Exc_6                       db 'Invalid opcode',13,10,36
Exc_7                       db 'Math unit not available',13,10,36
Exc_8                       db 'Double Fault',13,10,36
Exc_9                       db '387 overrun',13,10,36
Exc_10                      db 'Invalid TSS',13,10,36
Exc_11                      db 'Segment Not Present',13,10,36
Exc_12                      db 'Stack exception',13,10,36
Exc_13                      db 'General Protection',13,10,36
Exc_14                      db 'Page fault',13,10,36
Exc_16                      db 'Floating-point error',13,10,36
Exc_17                      db 'Alignment check',13,10,36
Exc_18                      db 'Machine check',13,10,36
Exc_reserved                db '    ş Unhandled Protected Mode Exception',13,10,36
Msg_Himem                   db '    ş Not enough Extended memory to initialise protected mode',13,10,36
Msg_23                      db '    ş User Break',13,10,36


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Do_Jump_EAX:
            jmp eax
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Disable Paging  Arrete la pagination                                      ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : CR0 CR3                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Disable_Paging Macro
            mov eax,CR0
            and eax,7fffffffh               ; Clear the PE bit
            mov CR0,eax
            xor eax,eax                     ; Flush the TLB
            mov CR3,eax                     ;( after clearing PE)
Endm

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Enable Paging  Autorise la pagination                                     ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : CR0 CR3                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Enable_Paging Macro
            mov eax,cs:[PageDirectory_PhysAddr]     ; Reload the TLB
            mov CR3,eax                     ;(before setting PE)
            mov eax,CR0
            or eax,80000000h                ; Set the PE bit
            mov CR0,eax
Endm

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                        DPMI,VCPI,XMS,RAW                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Setup_Pmode       initialise le Pmode + registre et une table de mapping  ³
;³             de taille de toute la RAM                                    ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Setup_Pmode:
            cli
            mov ax,cs:[Data32_Sel]
            mov ds,ax
            mov fs,ax
            mov gs,ax
            mov ss,ax
            mov esp,[Pmode_Stack]
            mov bx,[PSP_Sel]
            mov es,bx
            mov bx,[Environment_Sel]
            mov es:[2ch],bx
            mov es,ax
;            diss 1
            call Init_Memory_EOS
;            diss 2
            call Init_EOS
;            diss 3
            xor eax,eax
            xor ebx,ebx
            xor ecx,ecx
            xor edx,edx
            xor ebp,ebp
            xor esi,esi
            xor edi,edi
            sti
            jmp Start32

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Virtual Exeception Handlers                                               ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Common_Exception_Handling:
            add esp,0
            db 6ah,0
            db 0e9h
            dd 0
Common_Exception_Exit:
            mov dx,small (O Exc_reserved)
            mov bl,0
            db 0e9h
            dd 0
Size_E      equ $-Common_Exception_Handling

Exception_Handling:
            push eax
            push ds
            pushfd
            cmp D [esp+4*3],1
            je @@Ok2
            mov ds,[esp+4*5]
            mov eax,[esp+4*4]
            cmp B [eax-2],0cdh
            je Exception_Handling2
@@Ok2:
            popfd
            pop ds
            pop eax
            push ss
            push esp
            push D [esp+4*5]
            push D [esp+4*5]
            push D [esp+4*5]
            push D [esp+4*5]                ; Error Code
            push cs
            push O R_Exception
            push eax
            mov eax,[esp+4*9]
            shl eax,3
            add eax,cs:[Addr_Exception_Tbl]
            push D cs:[eax]
            mov eax,cs:[eax+4]
            xchg [esp+4],eax
            retf
R_Exception:
            cli
            add esp,4
            pop D [esp+4*5]
            pop D [esp+4*5]
            pop D [esp+4*5]
            pop esp
            pop ss
            add esp,4
            iretd

Exception_Handling2:
            popfd
            pop ds
            pop eax
            xchg eax,[esp]
            shl eax,3
            add eax,cs:[Addr_Int_0_32_Tbl]
            push D cs:[eax]
            mov eax,cs:[eax+4]
            xchg [esp+4],eax
            retf

Simulate_V86_Int_0_32:
            push ds
            push es
            push fs
            push gs
            mov fs,cs:[Data16_Sel]
ASSUME FS:Kernel_Setup
            mov [Save_EAX],eax
            mov ds,[esp+4*5]
            mov eax,[esp+4*4]
            movzx eax,B [eax-1]
            mov ds,cs:[Data32_Sel]
            shl eax,2
            add eax,[Zero_Addr]             ; Warning With WIN NT
            mov [V86_Int],9ch               ; Ask To Simulate a Int
            mov eax,[eax]
            push D [esp+4*6]
            call Go_To_V86
ASSUME FS:CODE32
            pop gs
            pop fs
            pop es
            pop ds
            retf 4



;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Close_Exception:
            mov bl,[esp+2*4]
            mov ax,cs:[Data32_Sel]
            mov ds,ax
            mov es,ax
            mov fs,ax
            mov gs,ax
            mov ss,ax
            mov esp,[Pmode_Stack]
            movzx edx,dx
            cmp edx,O Exc_reserved
            je @@Ok3
            mov al,bl
            aam
            xchg al,ah
            add ax,'00'
            mov W [exc_Num],ax
            push edx
            mov ah,Restore_Video_Mode
            Int_EOS
            mov ah,9
            mov edx,O Exc_
            Int 21h
            pop edx
@@Ok3:
            mov ah,Exit_Error
            Int_EOS

Unhandled_Interrupt:
            push eax
            push ds
            mov ds,[esp+4*3]
            mov eax,[esp+4*2]
ASSUME FS:Kernel_Setup
            push es
            push fs
            push gs
            mov fs,cs:[Data16_Sel]
            movzx eax,B [eax-1]
            push D [esp+4*4]
            pop [Save_EAX]
            mov ds,cs:[Data32_Sel]
            shl eax,2
            add eax,[Zero_Addr]             ; Warning WIN NT
            mov [V86_Int],9ch               ; Ask To Simulate a Int
            mov eax,[eax]
            push D [esp+4*7]
            call Go_To_V86
            mov [esp+4*4],eax
ASSUME FS:CODE32
            pop gs
            pop fs
            pop es
            pop ds
            pop eax
            retf 4


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³NMI_Irq   la NMI a rediriger vers le mode reel                            ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_exception_2:
            push eax
            push ds
            push es
            push fs
            push gs
ASSUME FS:Kernel_Setup
            mov ds,cs:[Data32_Sel]
            mov fs,[Data16_Sel]
            mov [V86_Int],9ch               ; Ask To Simulate a Int
            mov eax,[Zero_Addr]             ; !! Warning With WIN NT
            mov eax,[eax+2*4]
            pushfd
            call Go_To_V86
ASSUME FS:CODE32
            pop gs
            pop fs
            pop es
            pop ds
            pop eax
            retf




;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                              DPMI                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Emulate_Call  Emule un call far avec le DPMI                              ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DPMI_Emulate_Call:
            push ds
            mov ds,cs:[Data32_Sel]
            push es
            push ax                         ; Push 2 bytes to keep stack aligned.
            push W [Real_SS]                ; Push the real mode SS:SP.
            push W [Real_SP]
            push D [esp+4*6+2]              ; get dword that was passed on the stak
            push W [Real_GS]
            push W [Real_FS]
            push W [Real_DS]
            push W [Real_ES]
            db 66h
            pushf
            pushad
            mov ax,0301h
            jmp doDmpiModeSwitch


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                              DPMI                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Emulate_Int   Emule une Int far avec le DPMI                              ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DPMI_Emulate_Int:
            push ds
            mov ds,cs:[Data32_Sel]
            push es
            push ax                         ; Push 2 bytes to keep stack aligned.
            push W [Real_SS]                ; Push the real mode SS:SP.
            push W [Real_SP]
            push 0
            push W [Real_GS]
            push W [Real_FS]
            push W [Real_DS]
            push W [Real_ES]
            db 66h
            pushf
            pushad
            mov ax,0300h
            mov bl,[esp+4*18]               ; get the V86 int number that was pushed

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
doDmpiModeSwitch:
            sub [Real_SP],V86_Stack_Size    ; must leave room for another
            mov edi,esp                     ; V86 call
            push ss                         ; SET  es:edi = ss:esp
            pop es
            xor ecx,ecx
            xor bh,bh
            int 31h
            popad
            pop [Flags_Hold]                ; get flags and save
            and [Flags_Hold],0111111111111b ; only let legal FLAGS through
            pop W [Real_ES]
            pop W [Real_DS]
            pop W [Real_FS]
            pop W [Real_GS]
            add esp,10                      ; Ignore CS:IP ,SS:SP and 2 bytes.
            add [Real_SP],V86_Stack_Size
            push [Flags_Hold]               ; transfer in V86 flags
            db 66h
            popf
            pop es
            pop ds
            retf 8



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Irq       Routine en Pmode qui font le lien avec le mode reel pour les    ³
;³                call Back                                                 ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IRQ0:
            push 8
            jmp Short _Test_IRQ
IRQ1:
            push 9
            jmp Short _Test_IRQ
IRQ2:
            push 10
            jmp Short _Test_IRQ
IRQ3:
            push 11
            jmp Short _Test_IRQ
IRQ4:
            push 12
            jmp Short _Test_IRQ
IRQ5:
            push 13
            jmp Short _Test_IRQ
IRQ6:
            push 14
            jmp Short _Test_IRQ
IRQ7:
            push 15
            jmp Short _Test_IRQ
IRQ8:
            push 70h
            jmp Short _Test_IRQ
IRQ9:
            push 71h
            jmp Short _Test_IRQ
IRQ10:
            push 72h
            jmp Short _Test_IRQ
IRQ11:
            push 73h
            jmp Short _Test_IRQ
IRQ12:
            push 74h
            jmp Short _Test_IRQ
IRQ13:
            push 75h
            jmp Short _Test_IRQ
IRQ14:
            push 76h
            jmp Short _Test_IRQ
IRQ15:
            push 77h
            jmp Short _Test_IRQ

_Test_IRQ:
            cli
            xchg eax,[esp]
            push ds
            push es
            push fs
            push gs
ASSUME FS:Kernel_Setup
            shl eax,2
            mov ds,cs:[Data32_Sel]
            add eax,[Zero_Addr]             ; !! Warning Wiht WIN NT
            mov fs,[Data16_Sel]
            mov [V86_Int],9ch               ; Ask To Simulate a Int
            mov eax,[eax]
            pushfd
            call Go_To_V86
ASSUME FS:CODE32
            pop gs
            pop fs
            pop es
            pop ds
            pop eax
            iretd

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                              DPMI                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Int 08h   Special DPMI pour gere les fonction de la sourie                ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Free_32h    db 32h dup (0)

Int_06h:
            mov W es:[edi+2ch],Seg Kernel_Setup
            mov W es:[edi+2ah],O Call_Back_DPMI+4
            push ds
            push es
            push fs
            push gs
            mov ds,cs:[Data32_Sel]
            cmp [Set_Function_000ch],On
            jne @@Ok1
            mov [Set_Function_000ch],Off
            pushad
            push cs
            call New_Func_000ch
            popad
@@Ok1:
            pop gs
            pop fs
            pop es
            pop ds
            iretd

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Int 23h   Routine en Pmode pour emuler l'interruption 23h                 ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Int_23h:
            mov ds,cs:[Data32_Sel]
            mov ah,Exit_Error
            mov edx,O Msg_23
            Int_EOS

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Int 24h   Routine en Pmode pour emuler l'interruption 24h                 ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Int_24h:
            pushfd
            db 09ah
New_Int_24h_Pmode    dd O Int_24h_2,0
            cmp al,2
            je Terminate_Program            ; On appelle directement la fonction
            iretd                           ; pour finir le programme
Int_24h_2:
            push ds
            push es
            push fs
            push gs
ASSUME FS:Kernel_Setup
            mov ds,cs:[Data32_Sel]
            mov fs,[Data16_Sel]
            mov [Save_EAX],eax              ; save EAX
            mov [V86_Int],9ch               ; Ask To Simulate a Int
            mov eax,[Old_Int_24h]
            pushfd
            call Go_To_V86
ASSUME FS:CODE32
            pop gs
            pop fs
            pop es
            pop ds
            iretd


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Emulate_Call  Emule un call far en switchant en mode v86                  ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³               Ne doit pas modifier les Flags !!!!!                       ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ASSUME FS:Kernel_Setup
Emulate_Call:
            push ds
            push es
            push fs
            push gs
            mov ds,cs:[Data32_Sel]
            mov fs,[Data16_Sel]
            mov [Save_EAX],eax              ; save EAX
            mov [V86_Int],90h               ; Poke a Nop
            mov eax,[esp+4*7]               ; get dword passed via stack
            push D [esp+4*6]
            call Go_To_V86
            pop gs
            pop fs
            pop es
            pop ds
            retf 8


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Emulate_Int   Emule une int en switchant en mode v86                      ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³               Ne doit pas modifier les Flags !!!!!                       ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Emulate_Int:
            push ds
            push es
            push fs
            push gs
            mov ds,cs:[Data32_Sel]
            mov es,[Flat_Data_Sel]
            mov fs,[Data16_Sel]
            mov [Save_EAX],eax              ; save EAX
            movzx eax,B [esp+4*7]           ; get dword passed via stack
            mov [V86_Int],9ch               ; Poke a Pushf
            mov eax,es:[4*eax]              ; Get Int Addr
            push D [esp+4*6]                ; get dword passed via stack
            call Go_To_V86
            pop gs
            pop fs
            pop es
            pop ds
            retf 8




;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Go To v86     Routine qui initialise le mode V86 et switch                ³
;³                                                                          ³
;³Entree :                                                                  ³
;³        EAX = Valeur a Poker sur L'instruction Call en V86                ³
;³         DS = Data32_Sel                                                  ³
;³         FS = Dos_Data_Sel                                                ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
align 4
Go_To_V86:
            cli
            mov D [V86_Instruction],eax     ; Update far CALL
            mov eax,[esp+4]                 ; Get Flags
            push eax
            and ah,10111100b                ; Clear Nested Task, ( bit 14 )
            mov [Save_Flags],ax             ; Save Flags VCPI Doesn't Do It

            push [ESP_Save]                ; Save the stack
            push [SS_Save]                 ; for the previous nested V86 call
            mov [ESP_Save],esp             ; Update stack holding varibles
            mov W [SS_Save],ss             ; for the current V86 mode switch.

            mov eax,STACK32                 ; the stack Must be under 1Mb
            shl eax,4
            add eax,O Temp_stack-4
            mov ss,[Flat_Data_Sel]
            mov esp,eax
            cmp [Server_Type],VCPI
            je @@Ok1
            sub [Real_SP],V86_Stack_Size    ; Leave room for a nested V86 call.
            mov eax,O Emulate_Real_Int_Call
            db 0eah
            dd O Go_Real_Mode,Code16_Desc-GDT
@@Ok1:
            push [Real_GS]                  ; GS
            push [Real_FS]                  ; FS
            push [Real_DS]                  ; DS
            push [Real_ES]                  ; ES
            push [Real_SS]                  ; SS
            push [Real_SP]                  ; ESP
            sub [Real_SP],V86_Stack_Size    ; Leave room for a nested V86 call.
            db 68h                          ; IOPL = 3 , VM = 1
            dd 23000h                       ; EFLAGS
            db 68h
            dd seg Kernel_Setup             ; CS
            db 68h
            dd O Emulate_Real_Int_Call_VCPI
            mov ds,[Flat_Data_Sel]
            mov ax,0de0ch                   ; Enter V86 mode
            call cs:[VCPI_Addr]             ; via the VCPI server

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Return_From_V86  Retour du mode V86 apres l'emulation d'une int ou        ³
;³                 d'un call Far                                            ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return_From_V86:
            cli
            mov ax,Data32_Desc-GDT
            mov ds,ax
            mov es,ax
            mov gs,ax
            mov ax,Data16_Desc-GDT
            mov fs,ax
            lss esp,F [ESP_Save]
;            mov ss,[SS_SAVE]
;            mov esp,[ESP_SAVE]
            pop [SS_Save]                  ; Restore the stack
            pop [ESP_Save]                 ; for the previous nested V86 call.
            pop eax
            and ax,512

            add [Real_SP],V86_Stack_Size    ; Return the old V86 stack area.
            or ax,[Save_Flags]
            and ah,10111111b                ; Clear Nested Task, ( bit 14 )
            push ax
            mov eax,[Save_EAX]
            mov esi,[Save_ESI]
            db 066h
            popf
            ret 4


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Pmode_V86_Irq Handlers Routine qui est appele lorsqu'une IRQ a eu lieu    ³
;³                en V86 et Execute l'IRQ du Pmode                          ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : EAX ESI et Surtout Rien D'autre                  ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pmode_V86irqs_Handler:
            cli
            mov ax,Data32_Desc-GDT
            mov ds,ax
            mov es,ax
            mov gs,ax
            mov ax,Data16_Desc-GDT
            mov fs,ax
            lss esp,F [ESP_Save]
;            mov ss,[SS_SAVE]
;            mov esp,[ESP_SAVE]
            movzx eax,[Real_Int]
            add eax,[IDT_Addr]
            mov si,[eax+6]                  ; read offset 16..31
            shl esi,16
            mov si,[eax]                    ; read offset 0..15
            mov ax,[eax+2]                  ; read selector
            mov [Addr_Irq],esi
            mov W [Addr_Irq+4],ax
            mov eax,[Tmp_EAX]
            mov esi,[Tmp_ESI]
            jmp $+2                         ; Clear Prefetch
            pushfd
            and B [esp+1],10111101b         ; Stop NT & IF
            popfd
            pushfd
            db 09ah
Addr_Irq    Label Dword
            dd 0
            dw 0
            cli
            mov fs,cs:[Data16_Sel]
            mov [Tmp_EAX],eax
            mov [Tmp_ESI],esi
            mov ax,Flat_Data_Desc - GDT
            mov ss,ax
            mov ds,ax
            mov eax,STACK32                 ; the stack Must be under 1Mb
            shl eax,4
            add eax,O Temp_stack-4
            mov esp,eax
            cmp cs:[Server_Type],VCPI
            je @@Ok1
            mov eax,O Handle_V86_Irqs
            db 0eah
            dd O Go_Real_Mode,Code16_Desc-GDT
@@Ok1:
            sub esp,6*4                     ; GS & FS & DS & ES & SS & ESP
            db 68h                          ; IOPL = 3 , VM = 1
            dd 23000h                       ; EFLAGS
            db 68h
            dd seg Kernel_Setup             ; CS
            db 68h
            dd O Handle_V86_Irqs
            mov ax,0de0ch                   ; Enter V86 mode again
            call cs:[VCPI_Addr]

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                          VCPI,XMS,RAW                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Pmode_V86_call Handlers Routine qui est appele pour emule une far Call    ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : EAX ESI et Surtout Rien D'autre                  ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Pmode_V86calls_Handler:
            cli
            mov ax,Data32_Desc-GDT
            mov ds,ax
            mov es,ax
            mov gs,ax
            mov ax,Data16_Desc-GDT
            mov fs,ax
            mov ss,W [SS_Save]
            mov esp,[ESP_Save]
            jmp $+2                         ; Clear Prefetch
            pushfd
            and B [esp+1],10111101b         ; Stop NT & IF
            popfd
            db 09ah
Addr_Call   Label Dword
            dd 0
            dw 0
            mov ax,Flat_Data_Desc - GDT
            mov ss,ax
            mov ds,ax
            mov eax,STACK32                 ; the stack Must be under 1Mb
            shl eax,4
            add eax,O Temp_stack-4
            mov esp,eax
            cmp cs:[Server_Type],VCPI
            je @@Ok1
            mov eax,O Handle_V86_Calls
            db 0eah
            dd O Go_Real_Mode,Code16_Desc-GDT
@@Ok1:
            sub esp,6*4                     ; GS & FS & DS & ES & SS & ESP
            db 68h                          ; IOPL = 3 , VM = 1
            dd 23000h                       ; EFLAGS
            db 68h
            dd seg Kernel_Setup             ; CS
            db 68h
            dd O Handle_V86_Calls
            mov ax,0de0ch                   ; Enter V86 mode again
            call cs:[VCPI_Addr]

ASSUME FS:CODE32

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                              EOS                                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
INCLUDE EOS.ASM
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                              EOS                                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	    CODE32 ENDS

STACK32    SEGMENT PARA stack USE32 'stack'

            db 512 dup (?)
Temp_stack  Equ $


STACK32    ENDS




END_SEG SEGMENT PARA USE16 'ZzZzZz'
END_SEG ENDS

                END DosStart