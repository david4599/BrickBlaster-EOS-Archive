;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Gestion des INT & IRQ
;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
;쿒et_Int       Get protected mode interrupt vector                         �
;�                                                                          �
;쿔n :                                                                      �
;�        AH = Get_Int                                                      �
;�        BX = Interrupt number                                             �
;�                                                                          �
;쿚ut :                                                                     �
;�    CX:EDX = Selector:Offset of interrupt                                 �
;�                                                                          �
;쿌utre Registre Modifie : Aucun                                            �
;�                                                                          �
;�                                                                          �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
ifndef WIN32
Get_Int_EOS:
            PushDS
            push eax
            LoadDS
            cmp [Server_Type],DPMI          ; Check if need to use DPMI services
            jne @@Ok1
            mov ax,0204h
            _int 31h
            pop eax
            PopDS
            Clear_Carry
            mIRETD
@@Ok1:
            movzx eax,bl
            shl eax,3
            cmp bl,20h
            jb @@Ok11
            cmp bl,24h
            jne @@Ok3
            mov edx,[New_Int_24h_Pmode]
            mov cx,W [New_Int_24h_Pmode+4]
            pop eax
            PopDS
            Clear_Carry
            mIRETD
@@Ok3:
            add eax,[IDT_Addr]
            mov dx,[eax+6]                  ; read offset 16..31
            shl edx,16
            mov dx,[eax]                    ; read offset 0..15
            mov cx,[eax+2]                  ; read selector
            pop eax
            PopDS
            Clear_Carry
            mIRETD
@@Ok11:
            add eax,[Addr_Int_0_32_Tbl]
            mov edx,[eax]
            mov cx,[eax+4]
            pop eax
            PopDS
            Clear_Carry
            mIRETD
endif


;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
;쿞et_Int       Set protected mode interrupt vector                         �
;�                                                                          �
;쿔n :                                                                      �
;�        AH = Get_Int                                                      �
;�        BX = Interrupt number                                             �
;�    CX:EDX = Selector:Offset of interrupt                                 �
;�                                                                          �
;쿚ut :                                                                     �
;�                                                                          �
;쿌utre Registre Modifie : Aucun                                            �
;�                                                                          �
;�                                                                          �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
ifndef WIN32
Set_Int_EOS:
            PushDS
            push eax
            LoadDS
            cmp [Server_Type],DPMI          ; Check if need to use DPMI services
            jne @@Ok1
            mov ax,0205h
            _int 31h
            pop eax
            PopDS
            Clear_Carry
            mIRETD
@@Ok1:
            cli
            movzx eax,bl
            shl eax,3
            cmp bl,20h
            jb @@Ok11
            cmp bl,24h
            jne @@Ok3
            mov [New_Int_24h_Pmode],edx
            mov W [New_Int_24h_Pmode+4],cx
            pop eax
            PopDS
            Clear_Carry
            mIRETD
@@Ok3:
            add eax,[IDT_Addr]              ; Get address of the IDT
            mov [eax],dx                    ; Set offset 0..15
            rol edx,16
            mov [eax+2],cx                  ; Set selector
            mov [eax+6],dx                  ; Set offset 16..31
            rol edx,16
            pop eax
            PopDS
            Clear_Carry
            mIRETD
@@Ok11:
            add eax,[Addr_Int_0_32_Tbl]
            mov [eax],edx
            mov [eax+4],cx
            pop eax
            PopDS
            Clear_Carry
            mIRETD
endif

;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
;쿒et_Exception Get protected mode exception vector                         �
;�                                                                          �
;쿔n :                                                                      �
;�        AH = Get_Int                                                      �
;�        BX = Exception number                                             �
;�                                                                          �
;쿚ut :                                                                     �
;�    CX:EDX = Selector:Offset of exception                                 �
;�                                                                          �
;쿚ther Registers Change : None                                             �
;�                                                                          �
;�                                                                          �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
ifndef WIN32
Get_Exception_EOS:
            PushDS
            push eax
            LoadDS
            cmp [Server_Type],DPMI          ; Check if need to use DPMI services
            jne @@Ok11
            mov ax,0202h
            _int 31h
            pop eax
            PopDS
            Clear_Carry
            mIRETD
@@Ok11:
            cmp bl,20h
            jae @@Ok20
            movzx eax,bl
            shl eax,3
            add eax,[Addr_Exception_Tbl]
            mov edx,[eax]
            mov cx,[eax+4]
@@Ok20:
            pop eax
            PopDS
            Clear_Carry
            mIRETD
endif


;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
;쿞et_Exception Set protected mode exception vector                         �
;�                                                                          �
;쿔n :                                                                      �
;�        AH = Get_Int                                                      �
;�        BX = Exception number                                             �
;�    CX:EDX = Selector:Offset of exception                                 �
;�                                                                          �
;쿚ut :                                                                     �
;�                                                                          �
;쿚ther Registers Change : None                                             �
;�                                                                          �
;�                                                                          �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
ifndef WIN32
Set_Exception_EOS:
            PushDS
            push eax
            LoadDS
            cmp [Server_Type],DPMI          ; Check if need to use DPMI services
            jne @@Ok11
            mov ax,0203h
            _int 31h
            pop eax
            PopDS
            Clear_Carry
            mIRETD
@@Ok11:
            cmp bl,20h
            jae @@Ok20
            movzx eax,bl
            shl eax,3
            add eax,[Addr_Exception_Tbl]
            mov [eax],edx
            mov [eax+4],cx
@@Ok20:
            pop eax
            PopDS
            Clear_Carry
            mIRETD
endif



;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
;쿒et_Irq       Get protected mode irq vector                               �
;�                                                                          �
;쿔n :                                                                      �
;�        AH = Get_Irq                                                      �
;�        BX = Irq number                                                   �
;�                                                                          �
;쿚ut :                                                                     �
;�    CX:EDX = Selector:Offset of irq                                       �
;�                                                                          �
;쿌utre Registre Modifie : Aucun                                            �
;�                                                                          �
;�                                                                          �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Get_Irq_EOS:
ifndef WIN32
            PushDS
            push eax
            push ebx
            LoadDS
            and bl,0fh                      ; ignore bits 4..7
            cmp bl,2                        ; If IRQ = 2 then we must
            jne @@Ok1
            mov bl,9                        ; use IRQ 9.
@@Ok1:
            mov bh,[Pic1_Base]
            cmp bl,8
            jl @@Ok2
            mov bh,[Pic2_Base]              ; Get the interrupt number
            sub bl,8                        ; of the IRQ number.
@@Ok2:
            add bl,bh
            cmp [Server_Type],DPMI          ; Check if need to use DPMI services
            jne @@Ok10
            mov ax,0204h
            _int 31h
            pop ebx
            pop eax
            PopDS
            Clear_Carry
            mIRETD
@@Ok10:
            cli
            movzx eax,bl
            shl eax,3
            add eax,[IDT_Addr]              ; Get address of the IDT
            mov dx,[eax+6]                  ; Get offset 16..31
            rol edx,16
            mov cx,[eax+2]                  ; Get selector
            mov dx,[eax]                    ; Get offset 0..15
            pop ebx
            pop eax
            PopDS
            Clear_Carry
            mIRETD
else
            cmp bl,0
            jne @@Ok10
            mov edx,[Timer_Handler]
            mov ecx,cs
            Clear_Carry
            mIRETD
@@Ok10:
            Set_Carry
            mIRETD
endif

;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
;쿞et_Irq       Set protected mode irq vector                               �
;�                                                                          �
;쿔n :                                                                      �
;�        AH = Get_Irq                                                      �
;�        BX = Irq number                                                   �
;�    CX:EDX = Selector:Offset of irq                                       �
;�                                                                          �
;쿚ut :                                                                     �
;�                                                                          �
;쿌utre Registre Modifie : Aucun                                            �
;�                                                                          �
;�                                                                          �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Set_Irq_EOS:
ifndef WIN32
            PushDS
            push eax
            push ebx
            LoadDS
            and bl,0fh                      ; ignore bits 4..7
            cmp bl,2                        ; If IRQ = 2 then we must
            jne @@Ok1
            mov bl,9                        ; use IRQ 9.
@@Ok1:
            mov bh,[Pic1_Base]
            cmp bl,8
            jl @@Ok2
            mov bh,[Pic2_Base]              ; Get the interrupt number
            sub bl,8                        ; of the IRQ number.
@@Ok2:
            add bl,bh
            cmp [Server_Type],DPMI          ; Check if need to use DPMI services
            jne @@Ok10
            mov ax,0205h
            _int 31h
            pop ebx
            pop eax
            PopDS
            Clear_Carry
            mIRETD
@@Ok10:
            cli
            movzx eax,bl
            shl eax,3
            add eax,[IDT_Addr]              ; Get address of the IDT
            mov [eax],dx                    ; Set offset 0..15
            rol edx,16
            mov [eax+2],cx                  ; Set selector
            mov [eax+6],dx                  ; Set offset 16..31
            rol edx,16
            pop ebx
            pop eax
            PopDS
            Clear_Carry
            mIRETD
else
            cmp bl,0
            jne @@Ok10
            mov [Timer_Handler],edx
            Clear_Carry
            mIRETD
@@Ok10:
            Set_Carry
            mIRETD
endif