;            ษอออออออออออออออออออออออออออออออออออออออออออออออออออป
;            บ      ๗๗๗๗๗๗๗๗๗๗๗๗๗๗ PLAY.ASM ๗๗๗๗๗๗๗๗๗๗๗๗๗๗       บ
;            บ                                                   บ
;            บ               Useless Player V1.0a                บ
;            บ                  (EOS Version)                    บ
;            บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบ
;            บ   by Freddy Vtel (FreddyV/Useless)              บ
;            บ                                                   บ
;            บ   Code Starts .................. 13/03/1996       บ
;            บ   Last Update .................. 12/04/1997       บ
;            ศอออออออออออออออออออออออออออออออออออออออออออออออออออผ
.386
INCLUDE OS.INC

CODE32 SEGMENT PUBLIC USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

USE_PARAMETER EQU 1

INCLUDE ERR_CODE.INC
INCLUDE HARDWARE.INC

;** Files Loaders **

INCLUDE USMLOAD.INC
INCLUDE XMLOAD.INC
INCLUDE MODLOAD.INC
INCLUDE STMLOAD.INC

INCLUDE USMPLAY.INC ; USM Player
INCLUDE USS.INC     ; Useless Sound System
INCLUDE USSVAR.INC

INCLUDE MEMORY.INC  ; For the maxavail function
INCLUDE UTILS.INC   ; Display macros (write, writeln)

;=============================================================================

FileNameOffset DD 0

USMOffset DD 0

StartMSG DB 'Useless Player v1.0 (STM/MOD/XM/USM).',13,10
         DB 'By FreddyV/Useless',13,10,36

;=============================================================================

; ********************
; *** Player Start ***
; ********************

Start32:
; ** "Hardware" Init **

        call HardwareInit

; ** get program parameter **

if USE_Parameter eq 1

        mov esi,PSPOffset
        add esi,80h
        movzx eax,byte Ptr [esi]
        cmp eax,0
        je _USMPHelp
        inc esi
        mov byte ptr [esi+eax],0
        inc esi
        mov FileNameOffset,esi
endif

; ** Sound system Setup **

;       call USS_AutoSetup      ; Auto setup
;       jc _USMPEnd

       call USS_Setup          ; Menu setup
       jc _USMPEnd

; ** Player Start

        writeln

        mov edx,Offset StartMSG
        mov ah,9
        int 21h

        Maxavail

        Write 'Free memory: '
        call Print_Dec
        Writeln ' bytes'

        write 'Device: '

        mov edx,_DEV_Name
        mov ah,9
        int 21h

        writeln

; ** Load the file **

if USE_PARAMETER Eq 1
        mov esi,FileNameOffset
else
        mov esi,Offset Module
endif

        call LoadFile
        jc _USMPError

        mov USMOffset,esi

; ** Start the output **

        mov edx,0
        call USMP_StartPlay
        jc _USMPError

        writeln 'Left  : Previous pattern.'
        writeln 'Right : Next pattern.'
        writeln 'O     : Oversampling On/Off. (On mixed devices)'

        writeln 'Press Escape to stop.'

        mov ah,Use_Int_09
        mov bx,On
        Int_EOS

Wait_Key:
        cmp Key_Map[Escape],On
        je Key_Esc
        cmp Key_Map[Left],On
        je Key_Left
        cmp Key_Map[Right],On
        je Key_Right
        cmp Key_Map[Key_O],On
        je Switch_Oversampling

        jmp Wait_Key

Key_Left:
        mov Key_Map[Left],Off
        call USMP_PrevOrder
        jmp Wait_Key

Key_Right:
        mov Key_Map[Right],Off
        call USMP_NextOrder
        jmp Wait_Key

Switch_OverSampling:
        mov Key_Map[Key_O],Off
        xor _Dev_Mode,DM_Interp
        jmp Wait_Key

Key_Esc:
        mov Key_Map[Escape],Off

        mov ah,Use_Int_09
        mov bx,Off
        Int_EOS

; ** Stop the output **

        call USMP_StopPlay

; ** Free the memory **

        mov esi,USMOffset
        call USMP_FreeModule

        jmp _USMPEnd

_USMPError:
        call Display_Error_
        jmp _USMPEnd

_USMPHelp:
        writeln

        mov edx,Offset StartMSG
        mov ah,9
        int 21h

        write 'Usage:  PLAY filename'

_USMPEnd:

        mov   ax,4C00h
        int   21h

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณ LoadFile: Load a music file.                                            ณ
;ณ                                                                         ณ
;ณ Input: ESI File Name.                                                   ณ
;ณ                                                                         ณ
;ณ Output: ESI Pointer to the loaded file.                                 ณ
;ณ         CF Set => Error number in EAX.                                  ณ
;ณ                                                                         ณ
;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

LoadFile Proc
        
        call DetectFileExtention
        jc _USMPHELP

        push esi
        write 'Loading '
        mov ecx,80
        call print_str
        writeln
        pop esi

        dec eax
        call LoadersOffset[4*eax]

        ret
LoadFile Endp

;ีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
;ณ DetectFileExtention                                                     ณ
;ณ                                                                         ณ
;ณ Input: ESI File Name                                                    ณ
;ณ                                                                         ณ
;ณ Output: al, file type (MOD, XM or USM)                                  ณ
;ณ                                                                         ณ
;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Nb_Ext EQU 4
ModExt DB 'MOD ','XM  ','USM ','STM ',0

LoadersOffset DD Offset MOD_Load
              DD Offset XM_Load
              DD Offset USM_Load
              DD Offset STM_Load

DetectFileExtention Proc

        push esi

DFELoop:
        lodsb
        cmp al,'.'
        je CheckExt
        cmp al,0
        je NotFound
        jmp DFELoop
CheckExt:
        lodsb
        cmp al,'.'
        je DFELoop
        dec esi

; File extention is in [esi]
        mov edi,esi

        xor eax,eax
DoNextExtention:
        inc eax
        mov edx,eax
        dec edx
        shl edx,2
        mov bl,ModExt[edx]
        cmp bl,0
        je NotFound

        mov ecx,0
        mov esi,edi
CompExtLoop:
        mov bl,ModExt[edx]
        cmp bl,' '
        jne NotExtEnd
        cmp Byte Ptr [esi],' '
        je CheckOk
        cmp Byte Ptr [esi],0
        je CheckOk
        jmp DoNextExtention
NotExtEnd:
        mov bh,[esi]
        and bh,not 20h    ; convert to uppercase (Letters)
        cmp bl,bh
        jne DoNextExtention
        inc esi
        inc edx
        inc ecx
        cmp ecx,(Nb_Ext-1)
        jne CompExtLoop	

CheckOk:
        pop esi
        clc
        ret

NotFound:
        pop esi
        stc
        ret

DetectFileExtention Endp

CODE32 ENDS
;=============================================================================
END
; PLAY.ASM (c) 1997 FreddyV/Useless
