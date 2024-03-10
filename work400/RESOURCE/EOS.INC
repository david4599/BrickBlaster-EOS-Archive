
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º EOS.INC (Tabs : 13 21 29 37)                                             º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º EOS Variables                                                            º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Unpack_From_Memory  = 16h

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; MASM Declarations
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

IFNDEF  ??version
     Global EQU  Externdef
ENDIF

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Version
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Ver_EOS             equ db '4.00 Alpha'


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Key_Map (Azerty)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

All         = 0
Escape      = 1
Return      = 28
Alt         = 56
Space       = 57
Left        = 75
Right       = 77
Up          = 72
Down        = 80
Plus        = 78
Moins       = 74
Ctrl        = 29
Num_1       = 79
Num_2       = 80
Num_3       = 81
Num_4       = 75
Num_5       = 76
Num_6       = 77
Num_7       = 71
Num_8       = 72
Num_9       = 73
Num_0       = 82
Key_1       = 02
Key_2       = 03
Key_3       = 04
Key_4       = 05
Key_5       = 06
Key_6       = 07
Key_7       = 08
Key_8       = 09
Key_9       = 10
Key_0       = 11
Key_A       = 16
Key_Z       = 17
Key_E       = 18
Key_R       = 19
Key_T       = 20
Key_Y       = 21
Key_U       = 22
Key_I       = 23
Key_O       = 24
Key_P       = 25
Key_Q       = 30
Key_S       = 31
Key_D       = 32
Key_F       = 33
Key_G       = 34
Key_H       = 35
Key_J       = 36
Key_K       = 37
Key_L       = 38
Key_M       = 39
Key_W       = 44
Key_X       = 45
Key_C       = 46
Key_V       = 47
Key_B       = 48
Key_N       = 49
Key_F1      = 59
Key_F2      = 60
Key_F3      = 61
Key_F4      = 62
Key_F5      = 63
Key_F6      = 64
Key_F7      = 65
Key_F8      = 66
Key_F9      = 67
Key_F10     = 68
Key_F11     = 87
Key_F12     = 88

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Others
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Impossible  = 0     ; For the cut and paste (Ever 0)

On          = 1
Off         = 0

vbl         = On

ifndef WIN32
 Int_Val_EOS = 61h
 Int_EOS     Equ Int Int_Val_EOS
 SMODEL     macro
            CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
            ASSUME CS:CODE32,DS:CODE32,ES:CODE32,FS:CODE32,GS:CODE32,SS:CODE32
            endm

 SDATA      equ
 SCODE      equ
else
 Global Interrupt_EOS : proc
 Int_Val_EOS = 61h
 Int_EOS     equ call Interrupt_EOS
 SMODEL     equ .model flat
 SDATA      equ .data
 SCODE      equ .code
endif

ifdef WIN32
 Global Interrupt_EOS : proc
 Global Simulate_Int : proc
 Global _Set_Palette : proc
 Global _Get_Palette : proc
endif

CAPI        macro x
global      _&x : proc
x           equ _&x
            endm

_int macro x
ifndef WIN32
     int x
else
     db 68h                 ; Push
     dd x
     call Simulate_Int
endif
     endm

ifndef WIN32
 Set_Carry  equ or byte ptr [esp+4*2],1             ; Set the Carry flag
 Clear_Carry equ and byte ptr [esp+4*2],0FEh        ; Clear the Carry flag
 mIRETD     equ iretd
 LoadDS     equ mov ds,_CS[Data32_Sel]
 LoadES     equ mov es,_CS[Data32_Sel]
 PushDS     equ push ds
 PushES     equ push es
 PopDS      equ pop ds
 PopES      equ pop es
 _CS        equ cs:
 _DS        equ ds:
 _ES        equ es:
 DISABLE    equ cli
 ENABLE     equ sti
else
 Set_Carry  equ stc
 Clear_Carry equ clc
 mIRETD     equ ret
 LoadDS     equ
 LoadES     equ
 PushDS     equ
 PushES     equ
 PopDS      equ
 PopES      equ
 _CS        equ
 _DS        equ
 _ES        equ
 DISABLE    equ
 ENABLE     equ
endif


B Equ Byte Ptr
W Equ Word Ptr
D Equ Dword Ptr
F Equ Fword Ptr
O Equ Offset

RAW         equ 01h
XMS         equ 02h
VCPI        equ 04h
DPMI        equ 08h
WINDOWS     equ 10h


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º EOS Macros                                                               º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


Border      macro color
            if vbl
	push eax edx
            mov dx,03dah
            in al,dx
            nop
            nop
            nop
            mov dx,03c0h
            mov al,11h+32
            out dx,al
            mov al,color
            out dx,al
	pop edx eax
            endif
            endm

Color       macro c,x,y,z
            if vbl
            pushfd
            push edx
            push eax
	mov dx,3c8h
            mov al,c
	out dx,al
	inc dx
            mov al,x
	out dx,al
            mov al,y
	out dx,al
            mov al,z
	out dx,al
            pop eax
            pop edx
            popfd
            endif
	endm

Send        macro value,x,y
            pushad
            pushfd
            mov edx,value
            mov bx,x
            mov cx,y
            mov ah,Set_Value_Mono
            Int_EOS
            popfd
            popad
            endm

Get_Param   macro name
local @@no_path
local @@end
ifndef WIN32
            push ds
            mov ds,cs:[PSP_Sel]
            mov esi,80h
            mov cl,byte ptr [esi]
            and ecx,0ffh
            mov byte ptr [esi],0
            je @@no_path
            lea edi,name
            add esi,2
            rep movsb
            mov Byte ptr es:[edi-1],0
            clc
            jmp @@end
@@no_path:
            stc
@@end:
            pop ds
else
endif
            endm

Break_Point macro
            int 3
            endm


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º EOS Functions                                                            º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º                                System                                    º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Exit Error   Restore initial Video mode , interrupts , free all reserved  ³
;³             memory ,stop music if played and exit (with error code 1)    ³
;³             with a error message                                         ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Exit_Error                                                   ³
;³    DS:EDX = Offset message to display                                    ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Exit_Error = 1h
If Impossible
            mov ah,Exit_Error
            mov edx,Offset Error_Txt
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Use Int 08   Use Int 08 (IRQ 0) to count frame rate and have a stable     ³
;³             vertical retrace                                             ³
;³             Defaults frequency is 70Hz                                   ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Use_Int_08                                                   ³
;³        BX = On Enable Int 08                                             ³
;³           = Off Disable Int 08                                           ³
;³                                                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Use_Int_08          = 02h
If Impossible
            mov ah,Use_Int_08
            mov bx,On
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Change Synchro Int 08   Change frequency for Interupt 08                  ³
;³                        Defaults frequency is 70Hz                        ³
;³                                                                          ³
;³In :                                                                      ³
;³        BX = frequency                                                    ³
;³        AH = Change_Synchro_Int_08                                        ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Change_Synchro_Int_08      = 03h
If Impossible
            mov bx,70                   ; 70hz
            mov ah,Change_Synchro_Int_08
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Use Int 09   Use Internal Keyboard handler to use keyboard                ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Use_Int_09                                                   ³
;³        BX = On Enable Int 09                                             ³
;³           = Off Disable Int 09 (Default setting)                         ³
;³                                                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³      EAX = Physical address of the key_map array (for watcom users)      ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Global Key_Map      : Byte  ; Offset of the Key_Mapping

Use_Int_09          = 04h
If Impossible
            mov ah,Use_Int_09
            mov bx,On
            Int_EOS

            ...

@@Pause:                            ; Test if key pressed
            cmp Key_Map[All],Off
            je @@Pause
            mov Key_Map[All],Off

            ...

@@Pause:                            ; Test if the Esc key is pressed
            cmp Key_Map[Escape],On  ; Actually
            jne @@Pause

            ...

@@Pause:                            ; Test if the ESC key have been pressed
            cmp Key_Map[All],Escape
            jne @@Pause
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Restore Video Mode   Restore the inital video which is be active at the   ³
;³                     start of the program                                 ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Restore_Video_Mode                                           ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Restore_Video_Mode  = 07h
If Impossible
            mov ah,Restore_Video_Mode
            Int_EOS
EndIF

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Detect Windows       Detect If Windows is running                         ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Detect_Windows                                               ³
;³                                                                          ³
;³Out :                                                                     ³
;³        AL = Windows version                                              ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Detect_Windows      = 0Ah
Windows_3x          = 3
Windows_95          = 4
If Impossible
            lea edx,Windows_Txt
            mov ah,Detect_Windows
            Int_EOS
            or al,al
            jnz Error

            ...

Windows_Txt         db "    ş Sorry, but this program can not run under Microsoft Windows (tm)",13,10,36
EndIF

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Direct Send          Write a text directly to video ram . Color allowed   ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Direct_Send                                                  ³
;³       EDX = Offset message to Display                                    ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³Command : 0,0      = end                                                  ³
;³          0,1..255 = color                                                ³
;³          13       = first colonne                                        ³
;³          10       = next ligne                                           ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Direct_Send         = 0Eh
If Impossible
            lea edx,Message
            mov ah,Direct_Send
            Int_EOS

            ...

Message             db "    ",0,1,"ş Color Blue ",0,4,"Red ",13,10,0,0
EndIF


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º                                 Files                                    º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load Internal File   Load a file which is link with LLINK                 ³
;³                     if the file is not present the program stop and      ³
;³                     display a error message                              ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Load_Internal_File                                           ³
;³       EDX = Offset of file name                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³       EAX = Logical address of buffer (work with Data32_Sel)             ³
;³       ECX = Number of bytes read                                         ³
;³       ESI = Physical address of buffer (work with Flat_Data_Sel)         ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Load_Internal_File  = 10h
If Impossible
            mov ah,Load_Internal_File
            mov edx,O File_name
            Int_EOS
            mov [File_Buffer],eax
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load External File   Load a external file and uncompress it if it has     ³
;³                     been compress with Diet 1.44                         ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Load_External_File                                           ³
;³       EDX = Offset of file name                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = Logical address of buffer (work with Data32_Sel)             ³
;³       ECX = Number of bytes read                                         ³
;³       ESI = Physical address of buffer (work with Flat_Data_Sel)         ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³       EAX = 1 File Not Found                                             ³
;³             2 Not Enough Memory                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Load_External_File  = 11h
If Impossible
            mov ah,Load_External_File
            mov edx,O File_name
            Int_EOS
            jc Error_File
            mov [File_Buffer],eax
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load Internal File Handle  Load a file which is link with LLINK           ³
;³                           if the file is not present the program stop and³
;³                           display a error message                        ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Load_Internal_File_Handle                                    ³
;³       EDX = Offset of file name                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³       EAX = Logical address of buffer (work with Data32_Sel)             ³
;³       ECX = Number of bytes read                                         ³
;³       ESI = Physical address of buffer (work with Flat_Data_Sel)         ³
;³       EDI = Handle of Memory                                             ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Load_Internal_File_Handle  = 12h
If Impossible
            mov ah,Load_Internal_File_Handle
            mov edx,O File_name
            Int_EOS
            mov [File_Buffer],eax
            mov [Handle_Memory],edi
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load External File Handle  Load a external file and uncompress it if it   ³
;³                           has been compress with Diet 1.44               ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Load_External_File_Handle                                    ³
;³       EDX = Offset of file name                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = Logical address of buffer (work with Data32_Sel)             ³
;³       ECX = Number of bytes read                                         ³
;³       ESI = Physical address of buffer (work with Flat_Data_Sel)         ³
;³       EDI = Handle of Memory                                             ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³       EAX = 1 File Not Found                                             ³
;³             2 Not Enough Memory                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Load_External_File_Handle  = 13h
If Impossible
            mov ah,Load_External_File_Handle
            mov edx,O File_name
            Int_EOS
            jc Error_File
            mov [File_Buffer],eax
            mov [Handle_Memory],edi
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Write External File  Save a File on a Disk                                ³
;³                                                                          ³
;³Entree :                                                                  ³
;³        AH = Write_External_File                                          ³
;³       ECX = Size Of File                                                 ³
;³       EDX = Offset of file name                                          ³
;³       ESI = Buffer address                                               ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³       Carry = 0                                                          ³
;³        Tout Va Bien                                                      ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Erreur  Can't write file                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Write_External_File  = 14h
If Impossible
            mov ah,Write_External_File
            mov edx,O File_name
            mov esi,[Buffer]
            mov ecx,[Size_Buffer]
            Int_EOS
            jc Error_File
EndIf


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º                              Synchronization                             º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Synchronization Declaration
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Global       Nb_Vbl                 : Dword
global Timer_Value :dword

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Wait Vbl   Wait the vertical retrace                                      ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³       EAX = Number of Vbl lost since the last call                       ³
;³             (work only when the Int 08 is on)                            ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Wait_Vbl            = 20h
If Impossible
            mov ah,Wait_Vbl
            Int_EOS
EndIf

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get Nb Vbl   Return the number of VBL Without waiting the VBL             ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³       EAX = Number of Vbl lost since the last call                       ³
;³             (work only when the Int 08 is on)                            ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_Nb_Vbl          = 21h
If Impossible
            mov ah,Get_Nb_Vbl
            Int_EOS
EndIf

;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º                              Diamond Player                              º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Diamond Player Declaration
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  Global    Sound_Card_Type         : Byte
  Global    Sound_Card_Port         : Word
  Global    Sound_Card_Irq          : Byte
  Global    Sound_Card_Dma          : Byte
  Global    Master_Volume           : Byte
  Global    Master_Volume_Sfx       : Byte
  Global    Current_Pattern         : Byte
  Global    Current_Note            : Byte
  Global    Current_Speed           : Byte
  Global    Current_BPM             : Byte
  Global    Index_Pattern_Order     : Dword
  Global    Pattern_Order           : Byte
  Global    Number_Channel          : Dword
  Global    Diamond_Channel         : MS


  No_Card    = 0
  Sb_10      = 01h
  Sb_15      = 02h
  Sb_20      = 03h
  Sb_Pro     = 04h
  Sb_16      = 05h
  Sb_Awe     = 06h
  Gravis     = 10h
  Gravis_Max = 11h
  Gravis_Ace = 12h
  Gravis_Pnp = 13h
  WSS        = 20h

MS                  struc
Current_Sample      dd      0
Porta               dw      ?
Tremelo             db      ?
Current_Position    dd      ?
Current_Low_Position dd     ?               ; Low Frac of the Current Position
Jump_0e6            db      ?
Compt_jump_0e6      db      ?
Flags_0e6           db      ?
Porta_Freq          dw      ?
Porta_To            dw      ?
Vibrato             db      ?
Vibrato_Pos         db      ?
FineTune            dw      ?
Last_Effect         dd      0
Voice               db      ?               ; Soit 1 ou 16 Soit 2 ou 17 etc ....
Sample_Volume       db      ?
Base_Sample_Volume  db      ?
Mute                db      ?               ; On Arrete la voie
Frequence           dw      ?
Compt_Frequence     dd      ?
New_Sample          db      ?
Arp                 dw      ?,?,?
Arp_Counter         dw      ?
Slide_volume        dw      ?
Panning             db      ?
Retrig_Note         db      ?
Retrig_Note_Val     db      ?
Cut_Note            db      ?
Delay_Note          db      ?
                    db      0
Delay_Note_Offset   dd      ?
Addr_Read_Again     dd      ?               ; Addresse pour la routine Delay
MS                  ends

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Detect Sound Card   Detect with the environment variable the sound        ³
;³                    card installed                                        ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Detect_Sound_Card                                            ³
;³        CX = 1  Display result of Searching                               ³
;³                                                                          ³
;³Out :                                                                     ³
;³        AX = 0  No_Card                                                   ³
;³           = 1  Sound Blaster 1.0                                         ³
;³           = 2  Sound Blaster 1.5                                         ³
;³           = 3  Sound Blaster 2.0                                         ³
;³           = 4  Sound Blaster Pro                                         ³
;³           = 5  Sound Blaster 16                                          ³
;³           = 6  Sound Blaster Awe 32                                      ³
;³           = 10h  Gus                                                     ³
;³           = 11h  Gus Max                                                 ³
;³           = 12h  Gus Ace                                                 ³
;³           = 13h  Gus Pnp                                                 ³
;³           = 20h  WSS                                                     ³
;³        BX = Port                                                         ³
;³        CX = Irq                                                          ³
;³        DX = Dma                                                          ³
;³        SI = Dsp Version (For Sb) ou                                      ³
;³             Size of RAM of the Gravis                                    ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Detect_Sound_Card   = 30h
If Impossible
            mov ah,Detect_Sound_Card
            mov cx,1
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load Module   Load a module & initialize into the memory                  ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Load_Module                                                  ³
;³        AL = Bit 0 = 1  Load a internal module (can be compress and link  ³
;³                        with LLINK)                                       ³
;³           = Bit 1 = 1  Load module  from memory                          ³
;³           = Bit 2 = 1  Force old mod Loading (15 instr)                  ³
;³        BX = Replay rate (16000 to 44100 Hz)                              ³
;³        CX = Number of Sfx Channel                                        ³
;³        DS:EDX = Offset of Module name or                                 ³
;³                 Offset into the memory of the beginning of the module    ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Can't Load Module                                            ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Load_Module         = 32h
If Impossible
            mov ah,Load_Module
            mov al,4+1
            mov bx,22000
            xor ecx,ecx
            mov edx,O Module_Name
            Int_EOS
            jc Error_Loading_Module
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Play Module   Start playing the module                                    ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Play_Module                                                  ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Can't Play Module                                            ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Play_Module         = 34h
If Impossible
            mov ah,Play_Module
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Stop Module   Stop playing module                                         ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Stop_Module                                                  ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Stop_Module         = 35h
If Impossible
            mov ah,Stop_Module
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Clear Module   Unload the module from memory                              ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Clear_Module                                                 ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Clear_Module        = 36h
If Impossible
            mov ah,Clear_Module
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Manual Setup Sound Card                                                   ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Manual_Setup                                                 ³
;³        AL = Type                                                         ³
;³        BX = Port                                                         ³
;³        CL = Irq1                                                         ³
;³        CH = Irq2      ; Irq Gus 2                                        ³
;³        DL = Dma1      ; Dma Gus 1 or Dma 8 Bits for SB                   ³
;³        DH = Dma2      ; Dma Gus 2 or Dma 16 Bits for SB                  ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry Off                                                         ³
;³        Init Ok                                                           ³
;³                                                                          ³
;³        Carry On                                                          ³
;³        No Sound Card Found                                               ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Manual_Setup        = 37h
If Impossible
            mov ah,Manual_Setup
            mov al,Gravis
            mov bx,220h
            mov cl,7
            mov ch,7
            mov dl,1
            mov dh,1
            Int_EOS
            ...
            mov ah,Manual_Setup
            mov al,Sb_16
            mov bx,220h
            mov cl,7
            mov dl,1
            mov dh,5
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set Volume   Set the master volume of the module                          ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Set_Volume                                                   ³
;³        BL = Volume (0 to 63)                                             ³
;³        CL = Sfx Volume (0 to 63)                                         ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set_Volume          = 3ah
If Impossible
            mov ah,Set_Volume
            mov bl,[New_Volume]
            mov cl,[New_Volume_Sfx]
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Play Sample   Play a sample include into the module                       ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Play_Sample                                                  ³
;³        BX = Sample numbers                                               ³
;³        CX = Sample Frequency                                             ³
;³        DX = voice of sample                                              ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Play_Sample         = 3bh
If Impossible
            mov ah,Play_Sample
            mov bx,10
            mov cx,15fh
            mov dx,4
            Int_EOS
EndIf

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load Sample   Load a IFF 8 Bits Mono Sample into Memory                   ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Load_Sample                                                  ³
;³        AL = Bit 0 = 1  Load a internal module (can be compress and link  ³
;³                        with LLINK)                                       ³
;³        DS:EDX = Offset of Sample name or                                 ³
;³                 Offset into the memory of the beginning of the sample    ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³        EAX = Sample Number (use with Play_Sample)                        ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Can't Load Module                                            ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Load_Sample         = 3ch
If Impossible
            mov ah,Load_Sample
            mov bx,10
            mov cx,15fh
            mov dx,4
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get Info   Get information about the module when playing                  ³
;³                                                                          ³
;³In:                                                                       ³
;³        AH = Get_Info                                                     ³
;³                                                                          ³
;³Out:                                                                      ³
;³        AH = Position                                                     ³
;³        AL = Pattern                                                      ³
;³        BX = Note                                                         ³
;³        CL = Master Volume                                                ³
;³        DL = Master Volume Sfx                                            ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_Info            = 3eh
If Impossible
            mov ah,Get_Info
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set Pattern  Set the current position of the playing module               ³
;³                                                                          ³
;³In:                                                                       ³
;³        AH = Set_Pattern                                                  ³
;³        BX = New_Position                                                 ³
;³        CX = New_Note                                                     ³
;³                                                                          ³
;³Out:                                                                      ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set_Pattern         = 3fh
If Impossible
            mov ah,Set_Pattern
            mov bx,[New_Position]
            mov cx,[New_Note]
            Int_EOS
EndIf


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º                     Interrupt & Irq Functions                            º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get_Int       Get protected mode interrupt vector                         ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Get_Int                                                      ³
;³        BX = Interrupt number                                             ³
;³                                                                          ³
;³Out :                                                                     ³
;³    CX:EDX = Selector:Offset of interrupt                                 ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_Int             = 50h
If Impossible
            mov ah,Get_Int
            mov bx,10h
            Int_EOS
            mov [Old_Int_10_Selector],cx
            mov [Old_Int_10_Offset],edx
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set_Int       Set protected mode interrupt vector                         ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Get_Int                                                      ³
;³        BX = Interrupt number                                             ³
;³    CX:EDX = Selector:Offset of interrupt                                 ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set_Int             = 51h
If Impossible
            mov ah,Set_Int
            mov bx,10h
            mov cx,cs
            mov edx,O New_Int_10
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get_Irq       Get protected mode irq vector                               ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Get_Irq                                                      ³
;³        BX = Irq number                                                   ³
;³                                                                          ³
;³Out :                                                                     ³
;³    CX:EDX = Selector:Offset of irq                                       ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_Irq             = 52h
If Impossible
            mov ah,Get_Irq
            mov bx,1h                               ; Keyboard
            Int_EOS
            mov [Old_Irq_01_Selector],cx
            mov [Old_Irq_01_Offset],edx
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set_Irq       Set protected mode irq vector                               ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Get_Irq                                                      ³
;³        BX = Irq number                                                   ³
;³    CX:EDX = Selector:Offset of irq                                       ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set_Irq             = 53h
If Impossible
            mov ah,Set_Irq
            mov bx,1h                               ; Keybord
            mov cx,cs
            mov edx,O New_Irq_01
            Int_EOS
EndIf

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get_Exception Get protected mode exception vector                         ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Get_Exception                                                ³
;³        BX = Exception number                                             ³
;³                                                                          ³
;³Out :                                                                     ³
;³    CX:EDX = Selector:Offset of exception                                 ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_Exception       = 54h
If Impossible
            mov ah,Get_Exception
            mov bx,10h
            Int_EOS
            mov [Old_Exception_10_Selector],cx
            mov [Old_Exception_10_Offset],edx
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set_Exception Set protected mode exception vector                         ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Get_Exception                                                ³
;³        BX = Exception number                                             ³
;³    CX:EDX = Selector:Offset of exception                                 ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set_Exception       = 55h
If Impossible
            mov ah,Set_Exception
            mov bx,10h
            mov cx,cs
            mov edx,O New_Exception_10
            Int_EOS
EndIf

;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º                           Memory Allocation                              º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Allocate Memory   Allocate Upper memory                                   ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Allocate_Memory                                              ³
;³       EDX = Size of memory block to allocate in bytes                    ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³       EAX = Physical address of the block (work with Flat_Data_Sel)      ³
;³       EDX = Logical address of the block (work with Data32_Sel)          ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Can't allocate memory                                        ³
;³       EAX = Largest available free memory                                ³
;³       EDX = Total available memory                                       ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Allocate_Memory   = 40h
If Impossible
            mov ah,Allocate_Memory
            mov edx,[Allocation_Size]
            Int_EOS
            jc Not_Enough_Memory
            mov [Physical_Address_Of_Block],eax     ; Work with Flat_Data_Sel
            mov [Logical_Address_Of_Block],edx      ; Work with Data32_Sel
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³DeAllocate Memory   Free the last allocate memory                         ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = DeAllocate_Memory                                            ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DeAllocate_Memory = 41h
If Impossible
            mov ah,DeAllocate_Memory
            Int_EOS
EndIf

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Allocate Memory Handle  Allocate Upper memory with handle                 ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Allocate_Memory                                              ³
;³       EDX = Size of memory block to allocate in bytes                    ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³       EAX = Physical address of the block (work with Flat_Data_Sel)      ³
;³       EDX = Logical address of the block (work with Data32_Sel)          ³
;³       EDI = Handle of Memory                                             ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Can't allocate memory                                        ³
;³       EAX = Largest available free memory                                ³
;³       EDX = Total available memory                                       ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Allocate_Memory_Handle = 42h
If Impossible
            mov ah,Allocate_Memory_Handle
            mov edx,[Allocation_Size]
            Int_EOS
            jc Not_Enough_Memory
            mov [Physical_Address_Of_Block],eax     ; Work with Flat_Data_Sel
            mov [Logical_Address_Of_Block],edx      ; Work with Data32_Sel
            mov [Memory_Handle],edi
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³DeAllocate Memory Handle  Free the allocate memory with this handle       ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = DeAllocate_Memory                                            ³
;³       EDI = Handle of Memory                                             ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Invalid handle                                               ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DeAllocate_Memory_Handle = 43h
If Impossible
            mov ah,DeAllocate_Memory_Handle
            mov edi,[Memory_Handle]
            Int_EOS
            jc Invalid_Handle
EndIf

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Resize Memory Handle    Resize the allocate memory with this handle       ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Resize_Memory_Handle                                         ³
;³       ECX = New Size of the memory block                                 ³
;³       EDI = Handle of Memory                                             ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³       EAX = Physical address of the block (work with Flat_Data_Sel)      ³
;³       EDX = Logical address of the block (work with Data32_Sel)          ³
;³       EDI = New Handle of Memory                                         ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Invalid handle                                               ³
;³             Not Enough Memory                                            ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Resize_Memory_Handle = 44h
If Impossible
            mov ah,Resize_Memory_Handle
            mov edi,[Memory_Handle]
            Int_EOS
            jc Invalid_Handle
            mov [Memory_Handle],edi
            mov [Addr_Memory],edx
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Allocate Selector   Create a new selector (Data type)                     ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Allocate_Selector                                            ³
;³       ESI = Physical base address of the new selector                    ³
;³       EDI = Size of the new selector modulo 4096                         ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³        BX = New selector                                                 ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Can't create selector                                        ³
;³                                                                          ³
;³Other Registers Change : EAX                                              ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Allocate_Selector   = 45h
If Impossible
            mov ah,Allocate_Selector
            mov esi,0a0000h
            mov edi,0fh         ; 64ko (0000-ffff)
            Int_EOS
            jc No_Free Selector
            mov [_0a0000h_Sel],bx
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³DeAllocate Selector   Free a Selector                                     ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = DeAllocate_Selector                                          ³
;³        BX = Selector                                                     ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Can't deallocate selector                                    ³
;³                                                                          ³
;³Other Registers Change :  EAX,EBX                                         ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DeAllocate_Selector = 46h
If Impossible
            mov ah,DeAllocate_Selector
            mov bx,[_0a0000h_Sel]
            Int_EOS
            jc Invalid_Selector
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Physical Address Mapping                                                  ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Physical_Address_Mapping                                     ³
;³       ECX = Size Of region                                               ³
;³       ESI = Physical address of memory                                   ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³       ESI = Linear Address of the region                                 ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             No Room free                                                 ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Physical_Address_Mapping = 47h
If Impossible
            mov ah,Physical_Address_Mapping
            mov ecx,1024*1024
            mov esi,[Vesa_Linear_Address]
            Int_EOS
            jc Not_Enough_Memory
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Free Physical Address Mapping      Free the allocate memory mapping       ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Free_Address_Mapping                                         ³
;³       ESI = Address of the block to free                                 ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Invalid address                                              ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Free_Physical_Address_Mapping = 48h
If Impossible
            mov ah,Free_Physical_Address_Mapping
            mov esi,[Vesa_Linear_Address]
            Int_EOS
            jc Invalid_Address
EndIf




;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º                      Monochrome Display                                  º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set Mono   Force On/Off the display of all the Monochrome Function        ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Set_Mono                                                     ³
;³        BX = On  Force Monochrome Off                                     ³
;³             Off Force Monochrome On                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set_Mono            = 0e0h
If Impossible
            mov ah,Set_Mono
            mov bx,On
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set String Mono   Display a string on the Monochrome adapter              ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Set_String_Mono                                              ³
;³        BX = Coordonate  X                                                ³
;³        CX = Coordonate  Y                                                ³
;³       EDX = Address of text ending by $                                  ³
;³                                                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set_String_Mono     = 0e1h
If Impossible
            mov ah,Set_String_Mono
            mov bx,1
            mov cx,10
            mov edx,offset text_mono
            Int_EOS
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set Value Mono   Display A Word in Hexadecimal on the Monochrome adapter  ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Set_Value_Mono                                               ³
;³        BX = Coordonate X                                                 ³
;³        CX = Coordonate Y                                                 ³
;³        EDX = Value to be display                                         ³
;³                                                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set_Value_Mono      = 0e2h
If Impossible
            mov ah,Set_Value_Mono
            mov bx,1
            mov cx,10
            mov dx,1234h
            Int_EOS
EndIf


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º EOS Library                                                              º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º VESA                                                                     º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

CAPI   Detect_Vesa_Mode
CAPI   Init_Vesa
CAPI   Init_Vesa2
CAPI   Set_Bank
CAPI   Next_Bank
Global Vesa_Current_Bank    : Byte

global direct_x_pitch :dword

CAPI   Init_Vesa_Bank
CAPI   Close_Vesa_Bank

Global Vesa_Clear_Palette   : Byte

; ------------ VBE v1.0  ------------------
Mode640x400x256             = 100h
Mode640x480x256             = 101h
Mode800x600x16              = 102h
Mode800x600x256             = 103h
Mode1024x768x16             = 104h
Mode1024x768x256            = 105h
Mode1280x1024x16            = 106h
Mode1280x1024x256           = 107h
Mode80x60                   = 108h
Mode132x25                  = 109h
Mode132x43                  = 10ah
Mode132x50                  = 10bh
Mode132x60                  = 10ch
; ------------ VBE v1.2+ ------------------
Mode320x200x32k             = 10dh
Mode320x200x64k             = 10eh
Mode320x200x16M             = 10fh
Mode640x480x32k             = 110h
Mode640x480x64k             = 111h
Mode640x480x16M             = 112h
Mode800x600x32k             = 113h
Mode800x600x64k             = 114h
Mode800x600x16M             = 115h
Mode1024x768x32k            = 116h
Mode1024x768x64k            = 117h
Mode1024x768x16M            = 118h
Mode1280x1024x32k           = 119h
Mode1280x1024x64k           = 11ah
Mode1280x1024x16M           = 11bh


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Detect Vesa Mode   Detect if the video card support the request video mode³
;³                                                                          ³
;³In :                                                                      ³
;³      EAX = Screen Size X                                                 ³
;³      EBX = Screen Size Y                                                 ³
;³      ECX = Number of bits per pixel (8 15 16 24 32)                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³      EAX = Request Video mode                                            ³
;³                                                                          ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Mode Vesa not supported or Vesa driver not found             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            mov eax,640
            mov ebx,480
            mov ecx,8
            call Detect_Vesa_Mode
            jc Error_Vesa
            call Init_Vesa
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Init Vesa   Initialize A Vesa 1.x or 2.0 to use automatic bank switching  ³
;³                                                                          ³
;³In :                                                                      ³
;³        EAX = Vesa mode                                                   ³
;³                                                                          ³
;³Out :                                                                     ³
;³        EAX = VRAM address                                                ³
;³                                                                          ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Mode Vesa not supported or Vesa driver not found             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            mov eax,Mode640x480x256
            call Init_Vesa
            jc Error_Vesa

            ...

Vesa_Txt            db '    ş Mode SVGA not supported or VESA not found !',13,10
                    db '      To install a vesa driver, refer to your video card documentation.',13,10,36
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Init Vesa2  Initialize A Vesa 2.0 to use linear frame buffer              ³
;³                                                                          ³
;³In :                                                                      ³
;³        EAX = Vesa mode                                                   ³
;³        ECX = Video buffer size                                           ³
;³                                                                          ³
;³Out :                                                                     ³
;³        EAX = Linear buffer address                                       ³
;³                                                                          ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Mode Vesa not supported or Vesa driver not found             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            mov eax,Mode640x480x256
            mov ecx,640*480
            call Init_Vesa2
            jc Error_Vesa
            mov [Screen],eax

            ...

Vesa_Txt            db '    ş Mode SVGA not supported or VESA not found !',13,10
                    db '      To install a vesa driver, refer to your video card documentation.',13,10,36
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Init Vesa Bank  Init the Automatic Bank Switching                         ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³       BX = New selector for addressing the video ram                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Can't allocate selector                                      ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            call Init_Vesa_Bank
            jc Error_Sel
            mov [screen_selector],bx

            ...

            mov edx,edi     ; EDI Address of first pixel to be display
            shr edx,16
            call Set_Bank
            and edi,0ffffh

            ...

            call Close_Vesa_Bank
EndIf

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set Bank        Set the Current Bank                                      ³
;³                                                                          ³
;³In :                                                                      ³
;³      EDX = New Bank                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            mov edx,1
            call Set_Bank
EndIf


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º SNAP                                                                     º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Snap        Grab a 256 Colors screen in Non-Mode and save it in IFF format³
;³            Scroll Lock to lunch it                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Init Snap   Initialize the screen grabber . (You can change the int 09    ³
;³            function Use_Int_09 after this Init                           ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CAPI Init_Snap


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Snap IFF    Grab the current Screen from Video RAM                        ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CAPI Snap_Iff


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Save IFF    Save a buffer to IFF                                          ³
;³                                                                          ³
;³In :                                                                      ³
;³        AX = Screen Size X                                                ³
;³        BX = Screen Size Y                                                ³
;³       EDX = Offset of File Name                                          ³
;³       ESI = Address to save in IFF                                       ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CAPI Save_Iff


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º JOYSTICK                                                                 º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

Analog_A            = 1h
Analog_B            = 2h
Lpt_A               = 10h
Lpt_B               = 20h

Lpt1                = 1h
Lpt2                = 2h
Lpt3                = 3h
Lpt4                = 4h

joy_                Struc
J_Type              db 0
J_Addr              dw 0
J_Value_X           dd 0
J_Value_Y           dd 0
J_Min_X             dd 0
J_Max_X             dd 0
J_Min_Y             dd 0
J_Max_Y             dd 0
J_Center_X          dd 0
J_Center_Y          dd 0
J_Calibrate_Left    dd 0
J_Calibrate_Right   dd 0
J_Calibrate_Up      dd 0
J_Calibrate_Down    dd 0
J_Current_Left      db 0
J_Current_Right     db 0
J_Current_Up        db 0
J_Current_Down      db 0
J_Fire_1            db 0
J_Fire_2            db 0
J_Fire_3            db 0
J_Fire_4            db 0
                    ends

Global joy1         : joy_
Global joy2         : joy_
Global joy3         : joy_
Global joy4         : joy_
Global joy5         : joy_
Global joy6         : joy_

;WIN32 Definition
DIJOYSTATE  struc
jlX         dd 0             ; x-axis position
jlY         dd 0             ; y-axis position
jlZ         dd 0             ; z-axis position
jlRx        dd 0             ; x-axis rotation
jlRy        dd 0             ; y-axis rotation
jlRz        dd 0             ; z-axis rotation
jrglSlider  dd 0,0           ; extra axes positions
jrgdwPOV    dd 0,0,0,0       ; POV directions
jrgbButtons db 32 dup (0)    ; 32 buttons
            ends


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Init_Joystick  Init all port en address                                   ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CAPI      Init_Joystick


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Detect_Joystick  Find if an analogic joystick is plug in port 1 ,2 or     ³
;³Both                                                                      ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³       EAX = 1 A joystick is plug in port 1                               ³
;³             2 A joystick is plug in port 2                               ³
;³             3 2 joystick is plug in port 1 and 2                         ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             No Joystick                                                  ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CAPI      Detect_Joystick


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Add_Joystick   Add a new joystick to be use by the library                ³
;³                                                                          ³
;³In :                                                                      ³
;³        AX = Type Of joystick                                             ³
;³             Analog_A                                                     ³
;³             Analog_B                                                     ³
;³             Lpt_A                                                        ³
;³             Lpt_B                                                        ³
;³        BX = Address of port                                              ³
;³           = 1 Lpt1                                                       ³
;³           = 2 Lpt2                                                       ³
;³           = 3 Lpt3                                                       ³
;³           = 4 Lpt4                                                       ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³       ESI = Address of structure of joystick                             ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             No Joystick Available                                        ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CAPI      Add_Joystick


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Update_Joystick  Must be called often to update all structure of all      ³
;³Joystick                                                                  ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CAPI      UpDate_Joystick


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Sub_Joystick   Delete a Joystick create by Add_Joystick                   ³
;³                                                                          ³
;³In :                                                                      ³
;³       ESI = Address of structure to be delete                            ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Structure not found                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CAPI      Sub_Joystick


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Upper_Left     Take Value For Upper Left Joystick's Coordonate            ³
;³                                                                          ³
;³In :                                                                      ³
;³       ESI = Address of structure                                         ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             No Fire Press                                                ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CAPI      Upper_Left


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Lower_Right    Take Value For Lower Right Joystick's Coordonate           ³
;³                                                                          ³
;³In :                                                                      ³
;³       ESI = Address of structure                                         ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             No Fire Press                                                ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CAPI      Lower_Right


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Center         Take Value For Center Joystick's Coordonate                ³
;³                                                                          ³
;³In :                                                                      ³
;³       ESI = Address of structure                                         ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             No Fire Press                                                ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CAPI      Center


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º MEMORY                                                                   º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Init_Memory    Turn the display memory on                                 ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CAPI      Init_Memory


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º RS232                                                                    º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

CAPI        Serial_Open
CAPI        Serial_Close
CAPI        Serial_Read
CAPI        Serial_Read_Block
CAPI        Serial_Write
CAPI        Serial_Write_Block
CAPI        Serial_Clear_Buffer
CAPI        Serial_Status
CAPI        Serial_Set_Dtr
CAPI        Serial_Reset_Dtr
CAPI        Serial_Set_Rts
CAPI        Serial_Reset_Rts

global      Serial_Buffer_Full      : Byte
global      Serial_Stand_By         : Dword

COM_1               =       3F8h    ; base port address of port 0
COM_2               =       2F8h    ; base port address of port 1

SER_BAUD_300        =       384     ;    300 bauds
SER_BAUD_1200       =       96      ;   1200 bauds
SER_BAUD_2400       =       48      ;   2400 bauds
SER_BAUD_4800       =       24      ;   4800 bauds
SER_BAUD_9600       =       12      ;   9600 bauds
SER_BAUD_14400      =       8       ;  14400 bauds
SER_BAUD_19200      =       6       ;  19200 bauds
SER_BAUD_28800      =       4       ;  28800 bauds
SER_BAUD_38400      =       3       ;  38400 bauds
SER_BAUD_57600      =       2       ;  57600 bauds
SER_BAUD_115200     =       1       ; 115200 bauds

SER_STOP_1          =       0       ; 1 stop bit per character
SER_STOP_2          =       4       ; 2 stop bits per character

SER_BITS_5          =       0       ; send 5 bit characters
SER_BITS_6          =       1       ; send 6 bit characters
SER_BITS_7          =       2       ; send 7 bit characters
SER_BITS_8          =       3       ; send 8 bit characters

SER_PARITY_NONE     =       0       ; no parity
SER_PARITY_ODD      =       8       ; odd parity
SER_PARITY_EVEN     =       24      ; even parity


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Serial_Open         this function sets the serial port up.               ³
;³                                                                          ³
;³In :                                                                      ³
;³       EDX = base port address                                            ³
;³       EAX = speed                                                        ³
;³       ECX = config                                                       ³
;³       EDI = buffer size                                                  ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³       EAX = Circular buffer adrs                                         ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Not Enough Memory                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            mov edx,COM_1
            mov eax,SER_BAUD_115200
            mov ecx,SER_PARITY_NONE
            or  ecx,SER_BITS_8
            or  ecx,SER_STOP_1
            mov edi,1024
            call Serial_Open
            jc @@not_enough_memory
endif


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Serial_Close       This procedure closes the serial port.                ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            call Serial_Close
endif


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Serial_Read        This procedue reads a character in the circular buffer³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³       al : char                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
@@wait:
            cmp Serial_Stand_By,0
            je @@wait
            call Serial_Read
endif


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Serial_Read_Block                                                        ³
;³                                                                          ³
;³In :                                                                      ³
;³       EDI = Buffer adrs                                                  ³
;³       ECX = Nbs char to read                                             ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            mov ecx,10
            lea edi,[Buffer]
            call Serial_Read_Block
endif


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Serial_Write       This procedure sends characters.                      ³
;³                                                                          ³
;³In :                                                                      ³
;³       bl  = char to write                                                ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Error To Write                                               ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            mov bl,'a'
            call Serial_Write
            jc @@error
endif


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Serial_Write_Block                                                       ³
;³                                                                          ³
;³In :                                                                      ³
;³       ESI = Buffer adrs                                                  ³
;³       ECX = Nbs char to write                                            ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Error To Write                                               ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            mov ecx,10
            lea esi,[Buffer_To_Send]
            call Serial_Write_Block
            jc @@error
endif


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Serial_Clear_Buffer This procedure clears the circular buffer.           ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            call Serial_Clear_Buffer
endif


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Serial_Status      This procedure gets the status of the modem.          ³
;³                                                                          ³
;³Out :                                                                     ³
;³       al = status                                                        ³
;³                                                                          ³
;³         7    6     5     4      3     2      1      0                    ³
;³     ÚÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄ¿                  ³
;³     ³ DCD ³ RI ³ DSR ³ CTS ³ dDCD ³ dRI ³ dDSR ³ dCTS ³                  ³
;³     ÀÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÙ                  ³
;³                                                                          ³
;³     Bit 0 (dCTS): Change in CTS                                          ³
;³     Bit 1 (dDSR): Change in DSR                                          ³
;³     Bit 2 (dRI): Change in RI                                            ³
;³     Bit 3 (dDCD): Change in DCD                                          ³
;³     Bit 4 (CTS): Clear To Send. Modem sets this line indicating that     ³
;³             it is ready for data, after computer indicates that it       ³
;³             is ready for data with an RTS. It used to be a signal        ³
;³             that the local modem has connected with a remote modem       ³
;³             too, in the olden days.                                      ³
;³     Bit 5 (DSR): Data Set Ready. This is the completing signal in a      ³
;³             DTR-DSR pair. Computer sends DTR to modem, saying it         ³
;³             wants to connect with it. Modem sends DSR back to            ³
;³             computer, saying that connection has been established.       ³
;³     Bit 6 (RI): Ring Indicator. Indicates that there is remote modem     ³
;³             attempting to call your local modem.                         ³
;³     Bit 7 (DCD): Data Carrier Detect. Indicates that the remote          ³
;³             modem has established connection with local modem.           ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            call Serial_Status
endif


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Serial_Set_Dtr     sets the DTR bit to 1                                 ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            call Serial_Set_Dtr
endif


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Serial_Reset_Dtr   sets the DTR bit to 0                                 ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            call Serial_Reset_Dtr
endif

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Serial_Set_Rts     sets the RTS bit to 1                                 ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            call Serial_Set_Rts
endif

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Serial_Reset_Rts   sets the RTS bit to 0                                 ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            call Serial_Reset_Rts
endif



;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º GIF                                                                      º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

global Load_External_Gif_Handle     :proc
global Load_Internal_Gif_Handle     :proc
global gif_palette                  :dword
global gif_handle                   :dword
global gif_y                        :word
global gif_x                        :word

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load External Gif Handle   Load and uncompress a external GIF file.       ³
;³                                                                          ³
;³In :                                                                      ³
;³       EDX = Offset of file name                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = Logical (tasm) or physical (watcom) address of buffer        ³
;³       EDI = Handle of Memory                                             ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            mov edx,O File_name
            Call Load_External_Gif_Handle
            jc Error_File
            mov [File_Buffer],eax
            mov [Handle_Memory],edi
EndIf


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load Internal Gif Handle   Load and uncompress a internal GIF file.       ³
;³                                                                          ³
;³In :                                                                      ³
;³       EDX = Offset of file name                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = Logical (tasm) or physical (watcom) address of buffer        ³
;³       EDI = Handle of Memory                                             ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Impossible
            mov edx,O File_name
            Call Load_Internal_Gif_Handle
            mov [File_Buffer],eax
            mov [Handle_Memory],edi
EndIf



;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º CDROM                                                                    º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

_Track_Info Struc
_adr        db 0
_track      db 0
_index      db 0
_min        db 0
_sec        db 0
_frame      db 0
_zero       db 0
_amin       db 0
_asec       db 0
_aframe     db 0
            ends

Global Track_Info   : _Track_Info

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Detect CDROM  Detect is a cdrom is connected to the system using the      ³
;³              MSCDEX functions                                            ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = 0                                                            ³
;³        BX = Number of CDROM present                                      ³
;³        CX = Drive of the First CDROM                                     ³
;³        DX = MSCDEX version                                               ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³       EAX = 1 No CDROM detected                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CAPI        Detect_CDROM
Global      First_CDROM     : word
Global      Number_CDROM    : word
Global      Version_MSCDEX  : word


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Play a Track  Play a track from the CDROM                                 ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³       EAX = Track number                                                 ³
;³       EBX = 0 this track only                                            ³
;³             1 all tracks follow                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = 0                                                            ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³       EAX = 1 Error on playing                                           ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CAPI        Play_Track


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Open CDROM   Open the CDROM door                                          ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = 0                                                            ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³       EAX = 1 Error on command                                           ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CAPI        Open_CDROM


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Close CDROM   Close the CDROM door                                        ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = 0                                                            ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³       EAX = 1 Error on command                                           ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CAPI        Close_CDROM


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Stop CDROM stop the music from the CDROM                                  ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = 0                                                            ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³       EAX = 1 Error on command                                           ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CAPI        Stop_CDROM


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Resume CDROM  Resume the music from the CDROM                             ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = 0                                                            ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³       EAX = 1 Error on command                                           ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CAPI        Resume_CDROM


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get Nb Tracks Get the number of Tracks in the CDROM                       ³
;³              (Will also reload all the database all track a bit slow)    ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = 0                                                            ³
;³       EBX = Number of Track                                              ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³       EAX = 1 Error on command                                           ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CAPI        Get_Nb_Tracks
Global      Track_Nbs     : dword


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get Track Info  Get the Track info on the CDROM                           ³
;³                                                                          ³
;³In :                                                                      ³
;³       EAX = Track number                                                 ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = 0                                                            ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³       EAX = 1 Error on command                                           ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CAPI        Get_Track_Info


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get Current Track Info  Get the current Track info on the CDROM           ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = 0                                                            ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³       EAX = 1 Error on command                                           ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CAPI        Get_Current_Track_Info


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º Macros used for calling the real mode                                    º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
ifndef WIN32

Global     Real_GS                 :dword
Global     Real_FS                 :dword
Global     Real_DS                 :dword
Global     Real_ES                 :dword
Global     Real_SS                 :dword
Global     Real_SP                 :dword

endif

Int_Val_DOS = 62h
Int_Val_Call= 63h

DosInt     macro Int_Number
            push Int_Number
            int Int_Val_DOS
           endm

DosCall    macro _Seg_,_Ofs_
           IFB <_Ofs_>
            push D _Seg_
           ELSE
            push W _Seg_
            push W _Ofs_
           ENDIF
            int Int_Val_Call
           endm

Init_es_di  macro Adrs
            mov edi,[Code32_Addr]
            add edi,O Adrs
            shr edi,4
            mov Real_ES,edi
            lea edi,Adrs
            and edi,0fh
            endm

Init_ds_dx  macro Adrs
            mov edx,[Code32_Addr]
            add edx,O Adrs
            shr edx,4
            mov Real_DS,edx
            lea edx,Adrs
            and edx,0fh
            endm


;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º Miscellaneous                                                            º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

Global       Code32_Sel              :word
Global       Data32_Sel              :word
Global       Flat_Data_Sel           :word
Global       Flat_Code_Sel           :word
Global       Environment_Sel         :word
Global       Environment_Addr        :dword
Global       PSP_Sel                 :word
Global       PSP_Addr                :dword
Global       _0b0000h                :dword
Global       _0b8000h                :dword
Global       _0a0000h                :dword
Global       Code32_Addr             :dword
Global       Zero_Addr               :dword
Global       Start32                 :proc
Global       _Start32                :proc
Global       Server_Type             :Byte

;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º The 32bit debugger                                                       º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
;Parameter use for Add_Log function

_Address        equ 0
_String         equ 1

_Log_Byte           equ 1
_Log_Word           equ 2
_Log_Dword          equ 3
_Log_Byte_Array     equ 4
_Log_Word_Array     equ 5
_Log_Dword_Array    equ 6
_Log_String         equ 7
_Log_Float4         equ 8
_Log_Float8         equ 9


CAPI         Debug
CAPI         Debug_Back

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Add Log  Add in the log windows a address or a expression to keep track   ³
;³                                                                          ³
;³In :                                                                      ³
;³       EAX = Type (_Log_Byte,..)                                          ³
;³       EBX = Address (_Address or _String)                                ³
;³       ECX = Offset to data or expression                                 ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Global       Add_Log                 :proc

AddLog      macro Param,Type,Address
            push eax
            push ebx
            push ecx
            if Param eq _Address
             mov ebx,Address
            else
             mov ebx,O Address
            endif
            mov ecx,Param
            mov eax,Type
            call Add_Log
            pop ecx
            pop ebx
            pop eax
            endm

;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º The EOS Emutation when using WATCON                                      º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

CAPI         Init_EOS