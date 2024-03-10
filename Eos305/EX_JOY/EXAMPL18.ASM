;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ This example show how to use the Joystick library                        บ
;บ                                                                          บ
;บ                                                                          บ
;บ                                                                          บ
;บ Tabs : 13 21 29 37                                                       บ
;บ                                                                          บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

Wait_For_Fire_Up macro
local @@Wait
@@Wait:
            cmp [Key_Map+Escape],On
            je @@exit
            call UpDate_Joystick
            cmp [esi.joy_.J_Fire_1],On
            je @@Wait
            cmp [esi.joy_.J_Fire_2],On
            je @@Wait
            endm

Msg_Good    db '    þ Joystick detected',10,13,36
Msg_Bad     db '    þ Joystick not found',10,13,36
Msg_Upper   db '    þ Move joystick to UPPER LEFT and press FIRE',10,13,36
Msg_Lower   db '    þ Move joystick to LOWER RIGHT and press FIRE',10,13,36
Msg_Center  db '    þ Move joystick to CENTER and press FIRE',10,13,36

Flag        db '    þ Left=    Right=    Up=    Down=    Fire1=    Fire2=    - Press ESC to Quit',13,0,0

_fire1      = 47
_fire2      = 57
_left       = 11
_right      = 21
_up         = 28
_down       = 37

Addr_Joy1   dd 0

Start32:
            call Init_Joystick

            call Detect_Joystick
            test eax,Analog_A
            jne @@cont

            mov ah,Exit_Error
            mov edx,O Msg_Bad
            Int_EOS

@@cont:
            mov ah,9
            mov edx,O Msg_Good
            int 21h

            mov ax,Analog_A
            call Add_Joystick
            mov [Addr_Joy1],esi

@@calibrate:
            mov ah,Use_Int_09
            mov bx,On
            Int_EOS

            mov ah,9
            mov edx,O Msg_Upper
            int 21h
@@Upper_Left:
            cmp [Key_Map+Escape],On
            je @@exit
            mov esi,[Addr_Joy1]
            call Upper_Left
            jc @@Upper_Left

            Wait_for_Fire_Up

            mov ah,9
            mov edx,O Msg_Lower
            int 21h
@@Lower_Right:
            cmp [Key_Map+Escape],On
            je @@exit
            mov esi,[Addr_Joy1]
            call Lower_Right
            jc @@Lower_Right

            Wait_for_Fire_Up

            mov ah,9
            mov edx,O Msg_Center
            int 21h
@@Center:
            cmp [Key_Map+Escape],On
            je @@exit
            mov esi,[Addr_Joy1]
            call Center
            jc @@Center

            Wait_for_Fire_Up

@@again:
            call Update_Joystick

            mov D [flag+_fire1],'    '
            mov D [flag+_fire2],'    '
            mov D [flag+_left],'    '
            mov D [flag+_right],'    '
            mov D [flag+_up],'    '
            mov D [flag+_down],'    '
            mov esi,[Addr_Joy1]

            cmp [esi.joy_.J_Fire_1],On
            jne @@Ok102
            mov D [flag+_fire1],'  nO'
@@Ok102:
            cmp [esi.joy_.J_Fire_2],On
            jne @@Ok103
            mov D [flag+_fire2],'  nO'
@@Ok103:
            cmp [esi.joy_.J_Current_Left],On
            jne @@Ok104
            mov D [flag+_left],'  nO'
@@Ok104:
            cmp [esi.joy_.J_Current_Right],On
            jne @@Ok105
            mov D [flag+_right],'  nO'
@@Ok105:
            cmp [esi.joy_.J_Current_Up],On
            jne @@Ok106
            mov D [flag+_up],'  nO'
@@Ok106:
            cmp [esi.joy_.J_Current_Down],On
            jne @@Ok107
            mov D [flag+_down],'  nO'
@@Ok107:
            lea edx,Flag
            mov ah,Direct_Send
            Int_EOS

            cmp [Key_Map+Escape],On
            jne @@again

@@exit:
            mov ax,4c00h
            int 21h

            CODE32 ENDS
            END