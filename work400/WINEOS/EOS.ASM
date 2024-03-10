;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÚÄÄÄÄÄÄÄÄÄ¿ ÚÄÄÄÄÄÄÄÄÄ¿ ÚÄÄÄÄÄÄÄÄÄ¿
;À¿  ÚÄÄÄ¿ ³ ³  ÚÄÄÄ¿  ³ ³  ÚÄÄÄÄ¿ ³
; ³  ³   ÀÄÙ ³  ³   ³  ³ ³  ³    ÀÄÙ
; ³  ÀÄÄ¿    ³  ³   ³  ³ ³  ÀÄÄÄÄÄÄ¿
; ³  ÚÄÄÙ    ³  ³   ³  ³ ÀÄÄÄÄÄÄ¿  ³
; ³  ³   ÚÄ¿ ³  ³   ³  ³ ÚÄ¿    ³  ³
;ÚÙ  ÀÄÄÄÙ ³ ³  ÀÄÄÄÙ  ³ ³ ÀÄÄÄÄÙ  ³
;ÀÄÄÄÄÄÄÄÄÄÙ ÀÄÄÄÄÄÄÄÄÄÙ ÀÄÄÄÄÄÄÄÄÄÙ  Eclipse Operating System
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

SCODE

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

INCLUDE LOADFILE.ASM

INCLUDE WRITEFIL.ASM

INCLUDE MONO.ASM

INCLUDE ALLOC.ASM

INCLUDE INT.ASM

INCLUDE INT_08.ASM

INCLUDE INT_09.ASM

INCLUDE SEND.ASM

INCLUDE INT_21.ASM

INCLUDE INT_33.ASM

If Use_Diamond
            INCLUDE EOS_ZIK.ASM
Endif

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SDATA
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                                                                          ³
;³                                                                          ³
;³Definition de Toutes les Variables Utilisees par L'EOS                    ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Uninstall           db 0    ; Prend la Valeur 1 Si EOS installe
                            ; 0 = EOS deja installe


Set_Fonc Macro x,y
                    db x
                    dd offset y
         endm

Liste_Fonction_EOS Label Byte
                    Set_Fonc Wait_Vbl               ,Wait_Vbl_EOS
                    Set_Fonc Get_Nb_Vbl             ,Get_Nb_Vbl_EOS
                    Set_Fonc Exit_Error             ,Exit_Error_EOS
                    Set_Fonc Use_Int_09             ,Use_Int_09_EOS
ifndef WIN32
                    Set_Fonc Use_Int_08             ,Use_Int_08_EOS
                    Set_Fonc Change_Synchro_Int_08  ,Change_Synchro_Int_08_EOS
                    Set_Fonc Detect_Windows         ,Detect_Windows_EOS
;                    Set_Fonc Detect_Vga             ,Detect_Vga_EOS
endif
If Use_Diamond
                    Set_Fonc Detect_Sound_Card      ,Detect_Sound_Card_EOS
                    Set_Fonc Load_Module            ,Load_Module_EOS
                    Set_Fonc Play_Module            ,Play_Module_EOS
                    Set_Fonc Stop_Module            ,Stop_Module_EOS
                    Set_Fonc Clear_Module           ,Clear_Module_EOS
                    Set_Fonc Manual_Setup           ,Manual_Setup_EOS
                    Set_Fonc Set_Volume             ,Set_Volume_EOS
                    Set_Fonc Play_Sample            ,Play_Sample_EOS
                    Set_Fonc Get_Info               ,Get_Info_EOS
                    Set_Fonc Set_Pattern            ,Set_Pattern_EOS
ifdef WIN32
                    Set_Fonc Load_Sample            ,Load_Sample_EOS
Endif
Endif
                    Set_Fonc Load_Internal_File     ,Load_Internal_File_EOS
                    Set_Fonc Load_External_File     ,Load_External_File_EOS
                    Set_Fonc Load_Internal_File_Handle     ,Load_Internal_File_Handle_EOS
                    Set_Fonc Load_External_File_Handle     ,Load_External_File_Handle_EOS
                    Set_Fonc Unpack_From_Memory     ,Unpack_From_Memory_EOS
                    Set_Fonc Write_External_File    ,Write_External_File_EOS
                    Set_Fonc Restore_Video_Mode     ,Restore_Video_Mode_EOS
                    Set_Fonc Set_Mono               ,Set_Mono_EOS
                    Set_Fonc Set_String_Mono        ,Set_String_Mono_EOS
                    Set_Fonc Set_Value_Mono         ,Set_Value_Mono_EOS
ifndef WIN32
                    Set_Fonc Allocate_Selector      ,Allocate_Selector_EOS
                    Set_Fonc DeAllocate_Selector    ,DeAllocate_Selector_EOS
endif
                    Set_Fonc Allocate_Memory        ,Allocate_Memory_EOS
                    Set_Fonc DeAllocate_Memory      ,DeAllocate_Memory_EOS
                    Set_Fonc Allocate_Memory_Handle ,Allocate_Memory_Handle_EOS
                    Set_Fonc DeAllocate_Memory_Handle,DeAllocate_Memory_Handle_EOS
                    Set_Fonc Resize_Memory_Handle   ,Resize_Memory_Handle_EOS
                    Set_Fonc Get_Irq                ,Get_Irq_EOS
                    Set_Fonc Set_Irq                ,Set_Irq_EOS
ifndef WIN32
                    Set_Fonc Physical_Address_Mapping,Physical_Address_Mapping_EOS
                    Set_Fonc Free_Physical_Address_Mapping,Free_Physical_Address_Mapping_EOS
                    Set_Fonc Get_Int                ,Get_Int_EOS
                    Set_Fonc Set_Int                ,Set_Int_EOS
                    Set_Fonc Get_Exception          ,Get_Exception_EOS
                    Set_Fonc Set_Exception          ,Set_Exception_EOS
endif
                    Set_Fonc Direct_Send            ,Direct_Send_EOS
                    db 0                            ,0

align
Offset_Fonction_EOS dd 0

Value_Str           db '        ',36 ; Utilise pour convertir un valeur en chaine HEXA

msg_fonc            db '    ş Invalid fonction call : '
err_fonc            db 'XX',13,10,36

ifdef WIN32
msg_int             db 'This Interrupt is not supported : '
err_int             db 'XX',13,10,0
endif

msg_vga             db '    ş VGA Card required',13,10,36

If Use_Diamond
Msg_Diamond         db '    ş Diamond Player Version '
                    Ver_EOS,13,10,36
Endif
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Addr_Dta            db 0ffh,0,0,0,0,0
                    db 8,3
Name_Vol            db 11 dup (3fh)
F_Attribut          db 0
F_Date1             dw 0
F_Date2             dw 0
F_Size_File         dd 0
ifndef WIN32
 F_Name_File         db 13 dup (0)
else
 F_Name_File         db 256 dup (0)
endif

Find_Volume         db '*.*',0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


Old_Video           dw 0            ; Ancien Carte Primaire et Secondaire
Old_Mode            db 3            ; Ancien Mode Video
Old_Line            db 49           ; Conserve si en Mode 3 la valeur pour les fontes
Addr_Save_Video     dw 0            ; Adresse du Buffer pour la Sauvegarde de la Carte VGA

Nb_Vbl              dd 0            ; Nombre de Vbl passer depuis le dernier appel
Wait_vbl_ok         db 0            ; 1 Une Vbl Passe


Handle              dw 0            ; Handle pour l'ouveture d'un fichier

Windows_Active      db 0


SCODE

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Initialization De L'EOS                                                   ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³        Carry = 0                                                         ³
;³             Tout Va Bien                                                 ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Probleme Pour L'init Fonction EOS non Suporte                ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_Init_EOS:
            mov [Remove_Flag],0
            mov [Uninstall],1

ifndef WIN32
            If Use_Diamond
            mov ah,9
            mov edx,O Msg_Diamond
            _int 21h
            call Init_Timer_Diamond
            Else
            mov [Use_08],0
            Endif
endif
            mov ah,1ah
            mov edx,O Addr_Dta
ifndef WIN32
            add edx,[Code32_Addr]
            mov ds,[Flat_Data_Sel]
endif
            _int 21h
            LoadDS

            call Test_Linked

            call Detect_Mono

            call Detect_Vga

            call Save_Video

            call Init_Mouse

            call Test_Eclipse_Member

ifndef WIN32
            mov ah,Detect_Windows
            Int_EOS

            mov ecx,25
@@Wait:
            mov ah,Wait_Vbl
            Int_EOS
            loop @@Wait
endif
            ret


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Fin de L'utilisation de l'EOS                                             ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Close_EOS:
            pushad
            PushDS
            PushES
            LoadDS
            LoadES
            cmp [Uninstall],1
            jne @@Ok1
            mov [Uninstall],0
            If Use_Diamond
             mov ah,Stop_Module             ; Arrete et Dealloue
             Int_EOS                        ; le module Si non deja fait
             mov ah,Clear_Module            ;
             Int_EOS
ifndef WIN32
             call Close_Timer_Diamond
endif
            Endif
ifndef WIN32
            mov ah,Use_Int_08
            mov bx,Off
            Int_EOS
endif
            mov ah,Use_Int_09
            mov bx,Off
            Int_EOS
            call Restore_Time
            ;call Clear_Mono
            mov ah,Restore_Video_Mode
            Int_EOS
@@Ok2:

@@Ok1:
            PopES                          ; EOS desinstalle
            PopDS
            popad
            clc
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Test Eclipse Member  Teste si l'EOS est lance sur une machine d'un des    ³
;³                     coders d'ECLIPSE                                     ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Test_Eclipse_Member:
ifndef WIN32
            pushad
            push [Real_DS]
            mov ah,1ah
            mov edx,O Addr_Dta
            _int 21h
            mov ah,11h
            _int 21h
            cmp [Name_Vol],3
            jne @@Ok3
            mov edi,[_0b0000h]
            mov ecx,10
            add edi,24*160-10*2
            mov esi,O Name_Vol+1
@@Ok1:
            mov al,[esi]
            mov [edi],al
            inc esi
            add edi,2
            loop @@Ok1
@@Ok3:
            pop [Real_DS]
            popad
endif
            ret


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Detect Vga           Detect If A Vga card is present                      ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Detect_Vga                                                   ³
;³                                                                          ³
;³Out :                                                                     ³
;³        BL = On    if a Vga card is present                               ³
;³        CL = On    if a Mda card is present                               ³
;³                                                                          ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Detect_Vga:
ifndef WIN32
            mov ax,1a00h
            _int 10h
            cmp al,1ah
            jne @@Ok100
            cmp bl,7
            je @@Ok5
            cmp bl,8
            je @@Ok5
            cmp bh,7
            je @@Ok41
            cmp bh,8
            jne @@Ok100
@@Ok41:
            xchg bh,bl
            mov [Old_Video],bx
            PushES
            push 40h
            PopES
            mov al,_ES[10h]
            and al,0cfh
            or al,20h
            mov es:[10h],al
            PopES
            mov ax,1a01h
            _int 10h
            pushad
            mov ax,3
            _int 10h
            PushDS
ASSUME DS:Kernel_Setup
            mov ds,_CS[Data16_Sel]
            mov ah,9
            mov edx,O Msg_eos
            _int 21h
            PopDS
ASSUME DS:CODE32
            popad
@@Ok5:
            ret
@@Ok100:
            mov ah,Exit_Error
            mov edx,O msg_vga
            Int_EOS
else
            mov bl,On
            mov cl,On
endif
            ret


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
Align
Detect_Windows_EOS:
ifndef WIN32
            pushad
            PushDS
            LoadDS
            call Test_Windows
            PopDS
            popad
endif
            mov al,_CS[Windows_Active]
            mIRETD

ifndef WIN32
Test_Windows:
            mov ax,1600h
            _int 2fh
            or al,al
            je @@Ok1
            cmp al,1h
            je @@Ok2
            cmp al,0ffh
            je @@Ok1
            cmp al,80h
            je @@Ok2
            jmp @@Ok2
@@Ok1:
            mov ax,4680h
            _int 2fh
            cmp al,80h
            jne @@Ok2
            mov [Windows_Active],Off
            ret
@@Ok2:
            mov ax,160ah
            _int 2fh
            cmp bh,3
            ja @@Ok3
            mov [Windows_Active],Windows_3x
            ret
@@Ok3:
            mov [Windows_Active],Windows_95
            ret
endif
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Restore L'etat de l'horloge du DOS                                        ³
;³                                                                          ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Restore_Time:
ifndef WIN32
@@Ok1:
            mov al,0ah                      ; Attends qu'il n'y ait pas
            out 70h,al                      ; actualisation
            in al,71h
            test al,80h
            jne @@Ok1
            xor al,al                       ; Lit les Secondes
            out 70h,al
            in al,71h
            db 0d4h,10h                     ; AAM en Base 16
            aad
            mov dh,al
            mov al,2                        ; Lit les Minutes
            out 70h,al
            in al,71h
            db 0d4h,10h                     ; AAM en Base 16
            aad
            mov cl,al
            mov al,4                        ; Lit les Heures
            out 70h,al
            in al,71h
            db 0d4h,10h                     ; AAM en Base 16
            aad
            mov ch,al
            xor dl,dl
            mov ah,2dh
            _int 21h
endif
            ret

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

Exit_Error_EOS:
ifndef WIN32
            mov ah,0fh
            _int 10h
            push ax
            push edx
endif
            mov ah,Restore_Video_Mode
            Int_EOS
ifndef WIN32
            pop edx

            mov ah,0fh
            _int 10h
            pop bx
endif
            mov ah,9
ifndef WIN32
            cmp al,bl
            je @@Ok1
            PushDS
            push edx
            mov ds,_CS[Data16_Sel]
ASSUME DS:Kernel_Setup
            mov edx,O Msg_eos
            _int 21h
            pop edx
            PopDS
ASSUME DS:CODE32
@@Ok1:
endif
            _int 21h
            mov ax,4c01h
            _int 21h


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Sauvegarde L'etat de la carte Video VGA                                   ³
;³                                                                          ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Save_Video:
ifndef WIN32
            mov ah,0fh
            _int 10h
            and al,7fh
            mov [Old_Mode],al
            cmp al,7h
            PushES
            push 40h
            PopES
            mov al,es:[84h]
            PopES
            mov [Old_Line],al
            je @@Ok10
            mov ax,1c00h
            mov cx,1+2+8
            _int 10h
            shl bx,2
            mov ah,48h
            DosInt 21h
            jc @@Ok10
            mov [Addr_Save_Video],ax
            push [Real_ES]
            and eax,0ffffh
            xor bx,bx
            mov [Real_ES],eax
            mov ax,1c01h
            _int 10h
            pop [Real_ES]
@@Ok10:
endif
            ret


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Restore le mode video qui etait actif lors du lancement du programme      ³
;³ (Restore L'etat de la carte Video VGA : DAC ,CRTC , Variable du BIOS )   ³
;³                                                                          ³
;³                                                                          ³
;³Entree :                                                                  ³
;³        AH = Restore_Video_Mode                                           ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Restore_Video_Mode_EOS:
ifndef WIN32
            pushad
            PushDS
            xor ebp,ebp
            mov ds,_CS[Data32_Sel]
            mov ah,0fh
            _int 10h
            and al,07fh
            cmp al,[Old_Mode]
            je @@Ok1
            mov ah,Wait_Vbl
            Int_EOS
            movzx eax,[Old_Mode]
            _int 10h
            inc ebp
            mov ah,Wait_Vbl
            Int_EOS
            mov dx,[Addr_Save_Video]
            test dx,dx
            je @@Ok2
            push [Real_ES]
            mov ax,1c02h
            mov cx,1+2+8
            mov [Real_ES],edx
            xor ebx,ebx
            _int 10h
            pop [Real_ES]
            mov ah,2
            xor bh,bh
            xor edx,edx
            _int 10h
@@Ok1:
            mov al,[Old_Mode]
            cmp al,2
            je @@Ok2
            cmp al,3
            jne @@Ok4
@@Ok2:
            mov dl,[Old_Line]
            test ebp,ebp
            jne @@Ok3
            PushES
            push 40h
            PopES
            cmp dl,_ES[84h]
            PopES
            je @@Ok4
@@Ok3:
            cmp dl,24
            je @@Ok4
            mov ax,1112h
            xor bx,bx
            sub dl,49
            sbb al,0
            _int 10h
@@Ok4:
            cmp [Old_Video],0
            je @@Ok5
            PushES
            push 40h
            PopES
            mov al,_ES[10h]
            or al,30h
            mov es:[10h],al
            PopES
            mov ax,1a01h
            mov bx,[Old_Video]
            _int 10h
            mov ax,7
            _int 10h
@@Ok5:
            PopDS
            popad
else
            pushad
            mov ax,3
            _int 10h
            popad
endif
            mIRETD


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Interruption EOS                                                          ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Align
Interrupt_EOS:
ifdef WIN32
            CCALL CheckWinMsg
endif
            push ebx
            PushDS
            mov ebx,O Liste_Fonction_EOS
            LoadDS
@@Ok1:
            cmp B [ebx],0
            je Invalide_Fonction
            cmp B [ebx],ah
            lea ebx,[ebx+5]
            jne @@Ok1
            mov ebx,D [ebx+1-5]
            PopDS
            xchg ebx,[esp]
ifndef WIN32
            sti
endif
            ret

Invalide_Fonction:
            PopDS
            pop ebx
            LoadDS
            mov al,ah
            and ax,0ff0h
            shr al,4
            add ax,'00'
            Adjust_Hex al
            Adjust_Hex ah
            mov W [err_fonc],ax
            mov ah,Exit_Error
            mov edx,offset msg_fonc
            Int_EOS


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

Align
Wait_Vbl_EOS:
ifndef WIN32
            PushDS
            push edx
            push 40h
            PopDS
            mov edx,ds:[63h]
            mov ds,_CS[Data32_Sel]
            add dl,6
@@Ok3:
            in al,dx
            test al,8
            je @@Ok3
@@Ok4:
            in al,dx
            test al,8
            jne @@Ok4
@@Ok10:
            mov eax,[Nb_Vbl]
            test eax,eax
            jne @@Ok11
            inc eax
@@Ok11:
            pop edx
            mov [Nb_Vbl],0
            PopDS
else
            pushad
            call _Wait_Synchro
            popad
endif
            mIRETD

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get Nb Vbl   Return the number of VBL generated since the program start   ³
;³                                                                          ³
;³In :                                                                      ³
;³                                                                          ³
;³Out :                                                                     ³
;³       EAX = Number of Vbl                                                ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_Nb_Vbl_EOS:
            mov eax,_CS[Nb_Vbl]
            mIRETD