SDATA
Mono        db Off                          ; On Presence D'un carte Monochrome
SCODE

Detect_Mono:
            mov [Mono],Off
ifndef WIN32
            mov ax,1a00h
            _int 10h
            cmp al,1ah
            jne @@Detect_Done
            cmp bh,1
            jne @@Detect_Done
            mov [Mono],On
            call Clear_Mono
            PushDS
ASSUME DS:Kernel_Setup
            mov ds,_CS[Data16_Sel]
            mov ah,Set_String_Mono
            mov edx,O Msg_eos
            mov ebx,0
            mov ecx,22
            Int_EOS
            PopDS
ASSUME DS:CODE32
@@Detect_Done:
endif
            ret



Clear_Mono:
            cmp _CS[Mono],On
            jne @@Ok1
            push eax
            push edx
            push edi
            PushES
            mov dx,3b4h
            mov ax,0eh
            out dx,ax
            inc al
            out dx,ax
            mov ax,_CS[Data32_Sel]
            mov es,ax
            mov edi,_ES[_0b0000h]
            mov eax,02200220h
            mov ecx,(80/2)*25
            rep stosd
            PopES
            pop edi
            pop edx
            pop eax
@@Ok1:
            ret


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set Mono   Force ou non L'affiche de message sur l'ecran monochrome       ³
;³                                                                          ³
;³Entree :                                                                  ³
;³        AH = Set_Mono                                                     ³
;³        BX = On  Force Monochrome On                                      ³
;³             Off Formce Monochrome Off                                    ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Set_Mono_EOS:
            PushDS
            and bl,1
            LoadDS
            mov [Mono],bl
            PopDS
            mIRETD


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set String Mono    Affiche un texte sur l'ecran Monochrome si present     ³
;³                                                                          ³
;³Entree :                                                                  ³
;³        AH = Set_String_Mono                                              ³
;³        BX = Coor X                                                       ³
;³        CX = Coor Y                                                       ³
;³       EDX = Addresse du texte fini par $                                 ³
;³                                                                          ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Set_String_Mono_EOS:
            cmp _CS[Mono],On
            jne @@Ok5
            pushad
            PushES
            LoadES
            mov edi,_ES[_0b0000h]
            and ebx,0ffffh
            and ecx,0ffffh
            add ebx,ebx
            shl ecx,5               ;
            add edi,ebx
            lea ecx,[ecx+4*ecx]     ; Multiplie par 5
            mov esi,edx
            add edi,ecx
@@Ok1:
            mov al,[esi]
            inc esi
            call test_letter
            cmp al,36
            je @@Ok2
            cmp al,0
            je @@Ok2
            mov ah,2
            mov _ES[edi],ax
            add edi,2
            jmp @@Ok1
@@Ok2:
            PopES
            popad
@@Ok5:
            mIRETD

test_letter:
            cmp al,13
            jne @@Ok1
            mov al,[esi]
            add edi,160
            inc esi
@@Ok1:
            cmp al,10
            jne @@Ok2
            mov eax,edi
            sub eax,_ES[_0b0000h]
            mov ecx,160
            xor edx,edx
            div ecx
            shl eax,5
            lea edi,[eax+4*eax]
            add edi,_ES[_0b0000h]
            mov al,[esi]
            inc esi
@@Ok2:
            ret


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set Value Mono   Affiche une Valeur (hexa) sur l'ecran Monochrome si      ³
;³                 pr‚sent                                                  ³
;³Entree :                                                                  ³
;³        AH = Set_Value_Mono                                               ³
;³        BX = Coor X                                                       ³
;³        CX = Coor Y                                                       ³
;³        EDX = Valeur a afficher                                           ³
;³                                                                          ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Set_Value_Mono_EOS:
            pushad
            PushDS
            PushES
            push ebx
            push ecx
            mov ax,_CS[Data32_Sel]
            mov ds,ax
            mov es,ax
            mov eax,edx
            mov edi,offset Value_Str
            call hex2decdd
            pop ecx
            pop ebx
            mov ah,Set_String_Mono
            mov edx,offset Value_Str
            Int_EOS
            PopES
            PopDS
            popad
            mIRETD
hex2decdd:
            mov edx,0f0000000h
            mov ecx,28
@@Ok1:
	push eax
            and eax,edx
            shr eax,cl
            add al,'0'
            cmp al,'9'
            jbe @@Ok2
            add al,'A'-'9'-1
@@Ok2:
            stosb
            pop eax
            shr edx,4
            sub ecx,4
            jge @@Ok1
            ret