;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                           บ
;บ LPT Digital Joystick tester by Credo <credo@bigfoot.com>                  บ
;บ                                                                           บ
;บ Use this one with the LPT Joystick cable available with some Amiga games  บ
;บ or with the LPT Joystick adapter designed by me                           บ
;บ                                                                           บ
;บ This little tester is using the first LPT port, but you can change it if  บ
;บ you want                                                                  บ
;บ                                                                           บ
;บ On the screen you see L1, R1, U1, D1, F1, L2, R2, U2, D2 and F2 these are บ
;บ the same as Joystick 1 Left ... Joystick 2 Fire but it is much more short บ
;บ                                                                           บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

Msg_first       db '    þ LPT Digital Joystick tester - Press ESC to Quit',10,13,36
Flag            db '    þ L1=    R1=    U1=    D1=    F1=    L2=    R2=    U2=    D2=    F2=    ',13,0,0

_left1          = 9
_right1         = 16
_up1            = 23
_down1          = 30
_fire1          = 37

_left2          = 44
_right2         = 51
_up2            = 58
_down2          = 65
_fire2          = 72

Addr_Joy1   dd 0
Addr_Joy2   dd 0

Start32:
            mov ah,9
            mov edx,O Msg_first
            int 21h

            call Init_Joystick

            mov ax,Lpt_A
            mov bx,1            ; change this if your LPT joy isn't on LPT1
            call Add_Joystick
            mov [Addr_Joy1],esi

            mov ax,Lpt_B
            mov bx,1            ; change this if your LPT joy isn't on LPT1
            call Add_Joystick
            mov [Addr_Joy2],esi

            mov ah,Use_Int_09
            mov bx,On
            Int_EOS

again:
            call Update_Joystick

            mov D [flag+_left1],'    '
            mov D [flag+_right1],'    '
            mov D [flag+_up1],'    '
            mov D [flag+_down1],'    '
            mov D [flag+_fire1],'    '

            mov D [flag+_left2],'    '
            mov D [flag+_right2],'    '
            mov D [flag+_up2],'    '
            mov D [flag+_down2],'    '
            mov D [flag+_fire2],'    '

            mov esi,[Addr_Joy1]

            cmp [esi.joy_.J_Current_Left],On
            jne L1
            mov D [flag+_left1],'  nO'
L1:
            cmp [esi.joy_.J_Current_Right],On
            jne R1
            mov D [flag+_right1],'  nO'
R1:
            cmp [esi.joy_.J_Current_Up],On
            jne U1
            mov D [flag+_up1],'  nO'
U1:
            cmp [esi.joy_.J_Current_Down],On
            jne D1
            mov D [flag+_down1],'  nO'
D1:
            cmp [esi.joy_.J_Fire_1],On
            jne F1
            mov D [flag+_fire1],'  nO'
F1:
            mov esi,[Addr_Joy2]

            cmp [esi.joy_.J_Current_Left],On
            jne L2
            mov D [flag+_left2],'  nO'
L2:
            cmp [esi.joy_.J_Current_Right],On
            jne R2
            mov D [flag+_right2],'  nO'
R2:
            cmp [esi.joy_.J_Current_Up],On
            jne U2
            mov D [flag+_up2],'  nO'
U2:
            cmp [esi.joy_.J_Current_Down],On
            jne D2
            mov D [flag+_down2],'  nO'
D2:
            cmp [esi.joy_.J_Fire_1],On
            jne F2
            mov D [flag+_fire2],'  nO'
F2:
            lea edx,Flag
            mov ah,Direct_Send
            Int_EOS

            cmp [Key_Map+Escape],On
            jne again

            mov ax,4c00h
            int 21h

            CODE32 ENDS
            END
