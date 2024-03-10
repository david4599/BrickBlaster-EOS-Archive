ifndef WIN32

If Use_Diamond
Timer_Speed = 512
Extrn       Init_Timer_Diamond      : Proc
Extrn       Close_Timer_Diamond     : Proc
Extrn       Timer_Vbl               : Word
Extrn       Waiting_Vbl             : Byte
Extrn       HAve_A_Vbl              : Byte
Public      Nb_Vbl
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Use Int 08   Use Int 08 (IRQ 0) to count frame rate and have a stable     ³
;³             vertical retrace (important when using the Sound Blaster)    ³
;³             Defaults frequency is 70Hz                                   ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Use_Int_08                                                   ³
;³        BX = On Enable Int 08                                             ³
;³           = Off Disable Int 08 (Default setting)                         ³
;³                                                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Use_Int_08_EOS:
            mIRETD

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Change Synchro Int 08   Change frequency for Interupt 08                  ³
;³                        Defaults frequency is 70Hz                        ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Change_Synchro_Int_08                                        ³
;³        BX = frequency                                                    ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Change_Synchro_Int_08_EOS:
            push eax
            push ebx
            push edx
            PushDS
            LoadDS
            mov al,36h
            out 43h,al
            mov eax,Timer_Speed
            shl ebx,16
            xchg eax,ebx
            xor edx,edx
            div ebx
            mov [Timer_Vbl],ax
            mov eax,1193180/Timer_Speed
            out 40h,al
            shr eax,8
            out 40h,al
            PopDS
            pop edx
            pop ebx
            pop eax
            mIRETD





Else

Use_08              db Off          ; On Detourne Int_08
Freq_Timer          dw 70           ; Default 70 Hz
Timer_Vbl           dw 0
Current_Timer_Vbl   dw 0

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Use Int 08   Use Int 08 (IRQ 0) to count frame rate and have a stable     ³
;³             vertical retrace (important when using the Sound Blaster)    ³
;³             Defaults frequency is 70Hz                                   ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Use_Int_08                                                   ³
;³        BX = On Enable Int 08                                             ³
;³           = Off Disable Int 08 (Default setting)                         ³
;³                                                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Use_Int_08_EOS:
            pushad
            PushDS
            LoadDS
            and bl,1
            je @@Ok1
            call Init_Timer
            jmp @@Ok2
@@Ok1:
            call Close_Timer
@@Ok2:
            PopDS
            popad
            mIRETD


Init_Timer:
            cmp [Use_08],On
            je @@Ok10
            mov ah,Get_Irq
            mov bl,0                        ; BL = IRQ number.
            Int_EOS                         ; Call the service.
            mov [Old_Adr_Int_08],edx
            mov [Old_Sel_Int_08],cx
            cmp edx,offset Interrupt_Timer
            je @@Ok10
            mov ah,Set_Irq
            mov bl,0                        ; BL = IRQ number
            mov edx,Offset Interrupt_Timer  ; EDX = offset of int vector
            mov cx,cs                       ; CX = selector value
            Int_EOS                         ; Call the service.
            mov [Use_08],On
            mov ah,Change_Synchro_Int_08
            mov bx,70
            Int_EOS
@@Ok10:
            ret

Close_Timer:
            cmp [Use_08],On
            jne @@Ok1
            mov ah,Get_Irq
            mov bl,0                        ; BL = IRQ number.
            Int_EOS                         ; Call the service.
            cmp edx,O Interrupt_Timer
            jne @@Ok1
            mov edx,[Old_Adr_Int_08]        ; EDX = offset of int vector
            mov cx,[Old_Sel_Int_08]         ; CX = selector value
            mov ah,Set_Irq
            mov bl,0                        ; BL = IRQ number.
            Int_EOS                         ; Call the service.
            mov al,36h
	out 43h,al
            xor ax,ax
            out 40h,al
            out 40h,al
@@Ok1:
            mov [Use_08],Off
            ret


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Synchro Int 08   Resynchronise l'interruption 08 apr‚s un changement de   ³
;³                 mode vid‚o                                               ³
;³Entree :                                                                  ³
;³        AH = Synchro_Int_08                                               ³
;³        BX = Frequence 60 or 70h                                          ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Change_Synchro_Int_08_EOS:
            push eax
            push ebx
            push edx
            PushDS
            LoadDS
            cmp [Use_08],On
            jne @@Ok1
            mov [Freq_Timer],bx
            mov eax,1193180
            movzx ebx,bx
            xor edx,edx
            div ebx
            mov [Timer_Vbl],ax
            push eax
            mov al,36h
            out 43h,al
            pop eax
            out 40h,al
            shr eax,8
            out 40h,al
@@Ok1:
            PopDS
            pop edx
            pop ebx
            pop eax
            mIRETD

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Interrupt_Timer                                                           ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Align
Interrupt_Timer:
            push eax
            PushDS
            LoadDS
            inc [Nb_Vbl]
            mov ax,[Timer_Vbl]
            add [Current_Timer_Vbl],ax
            jc @@Ok1
            mov al,20h
            out 20h,al
            PopDS
            pop eax
            mIRETD
@@Ok1:
            PopDS
            pop eax
            db 0eah
Old_Adr_Int_08      dd 0
Old_Sel_Int_08      dw 0            ; Ancienne Adresse De l'interruption 08h

Endif
endif