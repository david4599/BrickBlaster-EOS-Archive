;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Diamond Player                                                      Ver 2.00á
; copyright (c) 1996 Eclipse
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Locals
.386p
.model flat
.data
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Vbl=Off
INCLUDE DIAMOND.INC
INCLUDE ..\RESOURCE\EOS.INC
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
INCLUDE PLAY_MOD.ASM
INCLUDE EFFECT.ASM
INCLUDE MIXING.ASM
INCLUDE SFX.ASM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;INCLUDE MONO.ASM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Max_Sample  = 256
Max_Pattern = 256
Max_Order_Pattern   = 256
Freq_min    = 28
Freq_max    = 3437
Const_Mod   = 369de4h   ; 9DE4h
Max_Channel = 32

.data
            Begin_Save_Diamond      equ $
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Variable Mixing.asm
DMA_Size            label dword
_DMA_Size            dd 32768
Linear_Addr_Dma1    dd 0
Linear_Addr_Dma2    dd 0
Size_Addr_Dma1      dd 0
Size_Addr_Dma2      dd 0
Next_Dma_Value     label dword
_Next_Dma_Value      dd 0
Current_Dma_Value   dd 0



Mixing_Real_Stereo  label byte
_Mixing_Real_Stereo  db Off
Mixing_Stereo       label byte
_Mixing_Stereo       db On
Mixing_16           label byte
_Mixing_16           db On
Mixing_Size_Buffer  label dword
_Mixing_Size_Buffer  dd 0
Mixing_Size_Buffer_Full     label dword
_Mixing_Size_Buffer_Full     dd 0
Current_DMA_Position        label dword
_Current_DMA_Position        dd 0
Addr_Volume_Table   label dword
_Addr_Volume_Table   dd 0
Addr_Buffer_Mixing  label dword
_Addr_Buffer_Mixing  dd 0


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Variable Globale des Cartes sond
Replay_Rate         label dword
_Replay_Rate         dd 44100                ; Defaults Value


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Variable Globale des Players
Addr_Module         label dword             ; Module Address
_Addr_Module         dd 0                    ; Module Address
Size_Module         label dword             ; Taille du Module en Ram
_Size_Module         dd 0                    ; Taille du Module en Ram
Master_Volume      label byte
_Master_Volume      db 40h
Master_Volume_Sfx  label byte
_Master_Volume_Sfx  db 40h
Number_Pattern      dd 0
_Number_Channel     label byte
Number_Channel      dd 4
_Number_Channel_Sfx  label byte
Number_Channel_Sfx  dd 0
Song_Lenght            label byte              ; Number of position
_Song_Lenght            db 0                    ; Number of position
Song_Restart        label byte              ; Song restart position
_Song_Restart        db 0                    ; Song restart position
Module_Playing      label byte
_Module_Playing      db Off


Current_Pattern     label byte
_Current_Pattern     db 0
Current_Note        label byte
_Current_Note        db 0
Current_BPM         label byte
_Current_BPM         db 0
Current_Speed       label byte
_Current_Speed       db 0
Compt_Speed         db 0
Pattern_Delay       db 0
Next_Current_Note   db 0
Do_Break            db Off
Index_Pattern_Order label dword
_Index_Pattern_Order dd 0



_List_Addr_Sample    label dword
List_Addr_Sample    label dword
                    dd Max_Sample dup (0)
List_Lenght_Sample  dd Max_Sample dup (0)
List_Loop_St_Sample dd Max_Sample dup (0)
List_Loop_Ln_Sample dd Max_Sample dup (0)
List_Volume_Sample  dd Max_Sample dup (0)
List_FineTune_Sample dd Max_Sample dup (0)
_Pattern_Order       Label Byte
Pattern_Order       Label Byte
                    db Max_Order_Pattern dup (0)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
set_channel macro x
 Channel&x  MS      <>
endm

i=1
Diamond_Channel     Label MS
rept Max_Channel
 set_channel %i
 i=i+1
endm

            End_Save_Diamond      equ $

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
List_Drivers        Label Dword
                    dd 0

List_Players        Label Dword
                    dd O List_Functions_Mod
                    dd 0

Addr_Current_Drivers        dd O List_Functions_Direct_Sound
Addr_Current_Player         dd 0

List_Functions_Direct_Sound   Label Dword
                    dd O Null_Func
                    dd O Null_Func
                    dd O Null_Func
                    dd O Load_Sample_Mixing
                    dd O Clear_Memory_Mixing
                    dd O Null_Func
                    dd O Null_Func
                    dd O Null_Func
                    dd O Channel_Mixing
                    dd O Set_BPM_Mixing
                    dd O Get_Frequence_Mixing
                    dd O Buffer_To_DMA_Mixing
                    dd 0

.code
Null_Func:
            ret


_Reset_Player:
Reset_Player:
            pushad
            mov edi,O Channel1
            mov ecx,Max_Channel*(Size MS/4)
            xor eax,eax
            rep stosd
            mov edi,O List_Addr_Sample
            mov ecx,Max_Sample*6
            rep stosd
            mov esi,O Channel1
            mov ecx,Max_Channel
@@Ok1:
            mov [esi.MS.Current_Sample],(Max_Sample-1)*4
            add esi,Size Channel1
            dec ecx
            jne @@Ok1
            popad
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Initialise Player
;
;   Enter   :
;           EAX = Number Sfx Channel
;           EBX = Replay Rate
;           ECX = Size of Module
;           ESI = Linear Address of Module
;
;   Return  :
;           Carry Off
;           EAX = Module Type
;           EBX = Nb Channel
;
;           Carry On
;           Not a module
;           EAX = 0
;           EBX = 0
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Initialise_Diamond_Player:
Initialise_Diamond_Player:
            xor edi,edi
@@Ok10:
            push edi
            push esi
            call Reset_Player
            mov edi,[List_Players+edi]
            mov ecx,[_Size_Module]
            mov esi,[_Addr_Module]
            call [edi.Player_Func.Detect_]
            pop esi
            pop edi
            jnc @@Ok20
            add edi,4
            cmp [List_Players+edi],0
            jne @@Ok10
@@Ok15:
            mov [_Addr_Module],0
            stc
            ret
@@Ok20:
            mov edi,[List_Players+edi]
            mov [Addr_Current_Player],edi
            clc
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Init_Diamond:                                       ; Prend Les infos
_Init_Diamond:                                      ; Prend Les infos
            pushad
            call Make_Volume_Table
            call Initialise_Diamond_Player
            call Init_Mixing_Data
            popad
            ret

Process_Diamond:
_Process_Diamond:
            pushad
            mov esi,[Addr_Current_Player]
            call [esi.Player_Func.Next_Tick_]
            popad
            ret

Mix_Data:
_Mix_Data:
            push D [esp+16]                         ; Get the Dma Addr
            pop [Size_Addr_Dma2]
            push D [esp+12]                         ; Get the Dma Addr
            pop [Linear_Addr_Dma2]
            push D [esp+08]                         ; Get the Dma Addr
            pop [Size_Addr_Dma1]
            push D [esp+04]                         ; Get the Dma Addr
            pop [Linear_Addr_Dma1]
;            Send [Linear_Addr_Dma1],0,0
;            Send [Linear_Addr_Dma2],0,1
            pushad
            mov edi,[Addr_Current_Drivers]
            call [edi.Dev_Func.Mix_Data_]
            cmp [Addr_Module],0
            je @@Skip
            cmp [Module_Playing],Off
            je @@Skip
            call Play_Sample_Sfx
@@Skip:
            popad
@@Ok100:
            ret

       END