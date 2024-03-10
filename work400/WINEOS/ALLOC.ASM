;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Reverse a L'allocation de page de descripteur
ifndef WIN32
Align 4
Handle_Memory_XMS           dd 0
Selector label byte
                    dw 0ffffh                      ; Limit[15..0]
                    db 00h,00h,00h                 ; Base[23..0]
                    s_ACCESS <1,00b,1,0010b>       ; P,DPL,1,type[E=0,ED,W,A ]
                    s_INFO <1,1,0,0,0fh>            ; G,B,0,avl,Limit[19..16]
                    db 0                           ; Base[31..24]

Msg_Memm    db '    ş Available memory : ',36
Memm        db '          ',36
Msg_Memm2   db 'Kb',13,10,36

Display_Mem:
            pushad
            mov edi,O Memm
            mov eax,edx
            xor ebp,ebp
            mov ecx,100000
@@Ok0:
            xor edx,edx
            div ecx
            test ebp,ebp
            jne @@Ok1
            test al,al
            je @@Ok2
@@Ok1:
            add al,'0'
            stosb
            inc ebp
@@Ok2:
            cmp ecx,1
            je @@Ok3
            push edx
            mov eax,ecx
            mov ecx,10
            xor edx,edx
            div ecx
            mov ecx,eax
            pop eax
            jmp @@Ok0
@@Ok3:
            mov B [edi],36
            mov ah,9
            mov edx,O Msg_Memm
            _int 21h
            mov edx,O Memm
            _int 21h
            mov edx,O Msg_Memm2
            _int 21h
            popad
            ret
endif
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Alloue toute la memoire superieure possible                               ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Init_Memory_EOS:
ifndef WIN32
            cmp [Server_Type],DPMI
            je @@Ok40
            cmp [Server_Type],RAW
            jne @@Ok5
            mov edx,[ExtMem_Free]
            shr edx,10
            cmp edx,256
            jae @@Ok1
            mov ah,Exit_Error
            mov edx,O Msg_Himem
            Int_EOS
@@Ok1:
            cmp edx,[Maximum_Allocate]
            jbe @@Ok11
            mov edx,[Maximum_Allocate]
@@Ok11:
            push edx
            call Display_Mem
            mov eax,[ExtMem_Free]
            add eax,1024*1024               ; Plus le 1 mega
            shl edx,10
            sub eax,edx
            add eax,4095
            and eax,Not 4095
            jmp @@Ok8

@@Ok5:
XMS_Version_Poke1 Label Byte
            mov ah,8
            DosCall [XMS_Driver]            ; Check Memory
            test bl,bl
            je @@Ok6
@@Ok51:
            mov ah,Exit_Error
            mov edx,O Msg_Himem
            Int_EOS
@@Ok6:
            mov edx,eax
            cmp edx,[Maximum_Allocate]
            jbe @@Ok61
            mov edx,[Maximum_Allocate]
@@Ok61:
            call Display_Mem
            push edx                        ; Push Number Kb Allocate
XMS_Version_Poke2 Label Byte
            mov ah,9
            DosCall [XMS_Driver]            ; Allocate Memory
            test ax,ax
            je @@Ok51
            mov [Handle_Memory_XMS],edx
            mov ah,0ch
            DosCall [XMS_Driver]            ; Lock Memory
            test ax,ax
            je @@Ok51
            shl edx,16
            mov dx,bx
            test dx,0fffh
            je @@Ok7
            add edx,4096
            and edx,Not 4095
            sub D [esp],4                   ; Enleve 4Ko de la Taille Maxi
@@Ok7:
            mov eax,edx                     ; EAX = Addresse de Base pour la ram
@@Ok8:                                      ; [ESP] = Taille du bloc memoire
            push eax
            Disable_Paging
            pop eax
            push eax                        ; Debut de la ram
            mov edi,[PageDirectory_PhysAddr]
            sub edi,[Code32_Addr]
            add eax,1000h
            add edi,4
            or al,7h                        ; Set:  P=1 , R/W =1, U/S=1
            mov ecx,3ffh
@@Ok9:
            stosd                           ; Page Table address
            add eax,1000h
            dec ecx
            jne @@Ok9
            pop edi
            sub edi,[Code32_Addr]
            mov [Addr_PageTables],edi
            mov ecx,[NumOfPages]
            mov eax,0000007h                ; Set:  P=1 , R/W =1, U/S=1
@@Ok10:
            stosd
            add eax,1000h
            dec ecx
            jne @@Ok10
            mov [Addr_MappingTables],edi
            mov ecx,[NumOfPages]            ; On fait la meme chose pour le
            sub al,7                        ; Mapping memory
@@Ok10_1:
            stosd                           ; mais on dit que les pages sont
            add eax,1000h                   ; inexistantes
            dec ecx
            jne @@Ok10_1
            mov ecx,edi                     ; ECX = Debut de la ram pouvent etre alloue
            add ecx,[Code32_Addr]           ; Replace en lineaire
            pop edi
            mov eax,[NumOfPages]
            shl edi,10                      ; ON met en Bytes
            lea eax,[8*eax+400h*4]          ; On soustrait 2*NumOfPages+Dirpages
            mov esi,[Addr_PageTables]       ; Alloue
            sub edi,eax
            shr ecx,12
            shr edi,12
@@Ok12:
            or D [esi+4*ecx],600h
            inc ecx
            dec edi
            jne @@Ok12
            mov ecx,[NumOfPages]
            mov esi,[Addr_MappingTables]
@@Ok13:
            or D [esi],600h
            add esi,4
            dec ecx
            jne @@Ok13
            Enable_Paging
@@Ok40:
endif
            ret


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³DesAlloue toute la memoire superieure prealablement alloue                ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Tous                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Close_Memory:
ifndef WIN32
            LoadDS
            cmp [Server_Type],DPMI
            jne @@Ok10
            mov ebx,[Addr_List_Handle_Mem]
            mov ecx,Nb_Handle_Mem
@@Ok1:
            cmp D [ebx],0
            je @@Ok2
            mov edi,[ebx]
            mov si,di
            shr esi,16
            mov ax,0502h
            _int 31h
@@Ok2:
            add ebx,4
            dec ecx
            jne @@Ok1

@@Ok10:
            mov edx,[Handle_Memory_XMS]
            test edx,edx
            je @@Ok20
            mov ah,0dh
            DosCall [XMS_Driver]            ; Unlock Memory
            mov ah,0ah
            DosCall [XMS_Driver]            ; DeAllocate Memory
@@Ok20:
endif
            ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Allocate Memory         Allocate Upper memory                             ³
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
;³       EDX = Total avaible memory                                         ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Allocate_Memory_EOS:
ifndef WIN32
            PushDS
            push ecx
            push esi
            push edi
            pushfd
            push cs
            push O Return_Allocate_Memory_EOS
            jmp Allocate_Memory_Handle_EOS
Return_Allocate_Memory_EOS:
            jc @@Ok10
            LoadDS
            mov ecx,Nb_Handle_Mem
            mov esi,[Addr_List_Mem]
@@Ok1:
            cmp D [esi],0
            je @@Ok2
            add esi,4
            dec ecx
            jne @@Ok1
@@Ok2:
            mov [esi],edi
            pop edi
            pop esi
            pop ecx
            PopDS
            Clear_Carry
            mIRETD
@@Ok10:
            pop edi
            pop esi
            pop ecx
            PopDS
            Set_Carry
            mIRETD
else
            push ebx
            push ecx
            push esi
            WIN32CALL GlobalAlloc,GMEM_FIXED,edx
            test eax,eax
            je @@Error
            mov ecx,Nb_Handle_Mem
            mov esi,[Addr_List_Mem]
@@Ok1:
            cmp D [esi],0
            je @@Ok2
            add esi,4
            dec ecx
            jne @@Ok1
@@Ok2:
            mov [esi],eax
            mov edx,eax
            mov edi,eax
            pop esi
            pop ecx
            pop ebx
            Clear_Carry
            mIRETD
@@Error:
            xor eax,eax
            xor edx,edx
            pop esi
            pop ecx
            pop ebx
            Set_Carry
            mIRETD


endif

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³DeAllocate Memory    Free the last allocate memory                        ³
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
DeAllocate_Memory_EOS:
            PushDS
            push ecx
            push esi
            push edi
            LoadDS
            mov ecx,Nb_Handle_Mem
            mov esi,[Addr_List_Mem]
@@Ok1:
            cmp D [esi],0
            je @@Ok2
            add esi,4
            dec ecx
            jne @@Ok1
@@Ok2:
            xor edi,edi
            sub esi,4
            jl Error_Deallocate
            xchg [esi],edi
ifndef WIN32
            pushfd
            push cs
            push O Return_DeAllocate_Memory_EOS
            jmp DeAllocate_Memory_Handle_EOS
Return_DeAllocate_Memory_EOS:
            jc Error_Deallocate
            pop edi
            pop esi
            pop ecx
            PopDS
            Clear_Carry
            mIRETD
Error_Deallocate:
            pop edi
            pop esi
            pop ecx
            PopDS
            Set_Carry
            mIRETD
else
            pushad
            WIN32CALL GlobalFree,edi
            test eax,eax
            popad
            je Error_Deallocate
            pop edi
            pop esi
            pop ecx
            PopDS
            Clear_Carry
            mIRETD

Error_Deallocate:
            pop edi
            pop esi
            pop ecx
            PopDS
            Set_Carry
            mIRETD
endif




;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Allocate Memory Handle  Allocate Upper memory with handle                 ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Allocate_Memory_Handle                                       ³
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
;³       EDX = Total avaible memory                                         ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Allocate_Memory_Handle_EOS:
ifndef WIN32
            cmp edx,not 0fffh
            jae @@Ok0
            test edx,0fffh                  ; Aligne sur 4096 que si necessaire
            je @@Ok0
            add edx,4096
            and edx,Not 4095
@@Ok0:
            push ebx
            push ecx
            push esi
            PushDS
            push 0
            LoadDS
            cmp [Server_Type],DPMI
            jne Allocate_VCPI_XMS_RAW
            PushES                         ; GET free memory thats' left
            push ss
            PopES
            sub esp,48
            mov edi,esp
            mov ax,0500h
            _int 31h
            mov eax,[esp]                   ; get Total free size
            add esp,48
            PopES
            cmp eax,edx
            jae @@Ok4
            mov edx,eax
            jmp Exit_Allocate_Mem_Error
@@Ok4:
            mov ebx,edx
            mov cx,dx
            mov ax,0501h                    ;-> Allocate a New Block.
            shr ebx,16                      ; CX:BX = size to allocate.
            _int 31h
            jnc @@Ok5
@@Ok5:
            shl ebx,16                      ; bx:cx = linear address
            shl esi,16
            mov bx,cx
            mov si,di
            mov edx,ebx
            mov eax,edx                     ; eax = edx
            mov edi,esi
            jmp Exit_Allocate_Mem


Allocate_VCPI_XMS_RAW:
            mov esi,[Addr_PageTables]
            sub esi,3
            xor eax,eax                     ; Compte la memoire totale Libre
            xor ebx,ebx                     ; Compte la plus grande region allouable
            mov ecx,[NumOfPages]            ; plus le nombre courant
            shr edx,12                      ; EDX nombre de page a alloue
@@Ok10:
            add esi,4
            test B [esi],4h                 ; Test si bit libre
            je @@Ok12
            inc eax                         ; Oui
            test ebx,ebx
            jne @@Ok11
            mov edi,esi
@@Ok11:
            inc ebx
            cmp ebx,edx
            je @@Ok30
            jmp @@Ok14

@@Ok12:
            cmp ebx,[esp]                   ; Memoire Occupe ou non allouable
            jbe @@Ok13                      ; Est ce le plus grand bloc
            mov [esp],ebx
@@Ok13:
            xor ebx,ebx
@@Ok14:
            dec ecx
            jne @@Ok10
            cmp ebx,[esp]                   ; Est ce le plus grand bloc
            jae @@Ok20
            mov ebx,[esp]
@@Ok20:
            mov edx,eax
            mov eax,ebx
            shl eax,12
            shl edx,12
            xor edi,edi                     ; No handle
            jmp Exit_Allocate_Mem_Error

@@Ok30:
            mov esi,[Addr_List_Handle_Mem]
            mov ecx,Nb_Handle_Mem
@@Ok31:
            cmp D [esi],0
            je @@Ok32
            add esi,8
            dec ecx
            jne @@Ok31
            xor eax,eax
            xor edx,edx
            xor edi,edi
            jmp Exit_Allocate_Mem_Error


@@Ok32:
            mov ecx,edx
            mov edx,[edi-1]
            and edx,not 0fffh
            mov [esi],edx                   ; debut de la ram
            mov [esi+4],ecx                 ; Taille de la RAM / 4096
@@Ok40:
            and B [edi],Not 4               ; Set Memory Used
            add edi,4
            dec ecx
            jne @@Ok40
            mov eax,edx
            mov edi,edx                     ; edi = Handle = Pointeur dans List_Mem
Exit_Allocate_Mem:
            sub edx,[Code32_Addr]
            pop esi                         ; Restaure 0
            PopDS
            pop esi
            pop ecx
            pop ebx
            Clear_Carry
            mIRETD

Exit_Allocate_Mem_Error:
            pop esi                         ; Restaure 0
            PopDS
            pop esi
            pop ecx
            pop ebx
            Set_Carry
            mIRETD
else                        ; WIN32 Emulation
            push ebx
            push ecx
            push esi
            WIN32CALL GlobalAlloc,GPTR,edx
            pop esi
            pop ecx
            pop ebx
            test eax,eax
            je @@Error
            mov edx,eax
            mov edi,eax
            Clear_Carry
            mIRETD
@@Error:
            xor eax,eax
            xor edx,edx
            Set_Carry
            mIRETD
endif

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³DeAllocate Memory Handle  Free the allocate memory with this handle       ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = DeAllocate_Memory_Handle                                     ³
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
DeAllocate_Memory_Handle_EOS:
ifndef WIN32
            pushad
            PushDS
            LoadDS
            mov esi,[Addr_List_Handle_Mem]
            mov ecx,Nb_Handle_Mem
            test edi,edi
            je @@Ok11
            cmp [Server_Type],DPMI
            jne DeAllocate_VCPI_XMS_RAW
            mov esi,edi
            shr esi,16
            mov ax,0502h
            _int 31h
            jc @@Ok11
            PopDS
            popad
            Clear_Carry
            mIRETD
@@Ok11:
            PopDS
            popad
            Set_Carry
            mIRETD


DeAllocate_VCPI_XMS_RAW:
@@Ok1:
            cmp D [esi],edi
            je @@Ok2
            add esi,8
            dec ecx
            jne @@Ok1
            PopDS
            popad
            Set_Carry
            mIRETD
@@Ok2:
            shr edi,10                      ; 10 car 12-2 pointe du Dword
            xor ecx,ecx
            mov D [esi],0
            xchg ecx,[esi+4]                ; Get Size Of Memory to freed
            add edi,[Addr_PageTables]
            inc edi
@@Ok10:
            or B [edi],4                    ; Set Memory Unused
            add edi,4
            dec ecx
            jne @@Ok10
            PopDS
            popad
            Clear_Carry
            mIRETD
else                        ; WIN32 Emulation
            test edi,edi
            je @@Skip
            pushad
            WIN32CALL GlobalFree,edi
            test eax,eax
            popad
            je @@Error
@@Skip:
            Clear_Carry
            mIRETD
@@Error:
            Set_Carry
            mIRETD


endif
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Resize Memory Handle    Resize the allocate memory with this handle       ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Resize_Memory_Handle                                         ³
;³       ECX = New Size of th memory block                                  ³
;³       EDI = Handle of Memory                                             ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³       EAX = Physical address of the block (work with Zero_Sel)           ³
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
Resize_Memory_Handle_EOS:
ifndef WIN32
            cmp _CS[Server_Type],DPMI
            jne @@Ok30
            push esi
            push ecx
            mov ebx,ecx
            mov esi,edi
            shr ebx,16
            shr esi,16
            mov ax,0503h
            _int 31h
            jc @@Ok29
            push bx
            push cx
            pop eax
            mov edx,eax
            push si
            push di
            pop edi
            pop ecx
            pop esi
            sub edx,_CS[Code32_Addr]
            Clear_Carry
            mIRETD
@@Ok29:
            pop ecx
            pop esi
            Set_Carry
            mIRETD

@@Ok30:
            push ebx
            push ecx
            push esi
            PushDS
            push ecx
            LoadDS
@@Ok0:
            mov esi,[Addr_List_Handle_Mem]
            mov ecx,Nb_Handle_Mem
@@Ok1:
            cmp D [esi],edi
            je @@Ok2
            add esi,8
            dec ecx
            jne @@Ok1
            pop ecx
            PopDS
            pop esi
            pop ecx
            pop ebx
            Set_Carry
            mIRETD
@@Ok2:
            pop ecx
            test ecx,ecx                    ; Taille Invalid
            je @@Ok101
            test ecx,0fffh                  ; Aligne sur 4096 que si necessaire
            je @@Ok3
            add ecx,4096
            and ecx,Not 4095
@@Ok3:
            mov eax,[esi+4]                 ; Get Size Of Memory to freed
            shr ecx,12
            cmp eax,ecx
            je @@Ok100                      ; Meme Taille
            jb @@Ok50                       ; Nouvelle Taille Plus Grande
                                            ; Nouvelle Taille Plus Petite
            shr edi,10
            add edi,[Addr_PageTables]       ; EDI=Debut de l'allocation
            inc edi
            sub eax,ecx
            mov [esi+4],ecx                 ; Nouvelle Taille de la RAM / 4096
@@Ok10:
            and B [edi],Not 4               ; Set Memory Used
            add edi,4
            dec ecx
            jne @@Ok10
@@Ok11:
            or B [edi],4                    ; Set Memory Unused
            add edi,4
            dec eax
            jne @@Ok11
            jmp @@Ok100

@@Ok50:                                     ; Nouvelle Taille Plus Grande
            push ecx
            push edi
            shr edi,10
            add edi,[Addr_PageTables]       ; EDI=Debut de l'allocation
            lea edi,[edi+4*eax+1]           ; On se poistionne a la fin de l'allocation

            sub ecx,eax                     ; ECX nombre restant a allouer
@@Ok51:
            test B [edi],4                  ; Memory Used ?
            je @@Ok55                       ; Oui plus de ram
            add edi,4
            dec ecx
            jne @@Ok51
            pop edi
            pop ecx                         ; Ok il y a la place apres
            mov [esi+4],ecx                 ; Met la nouvelle Taille
            shr edi,10
            add edi,[Addr_PageTables]       ; EDI=Debut de l'allocation
            inc edi
@@Ok52:
            and B [edi],Not 4               ; Set Memory Used
            add edi,4
            dec ecx
            jne @@Ok52
            jmp @@Ok100



@@Ok55:
            pop edi                         ; Oui plus de ram
            pop ecx                         ; on allloue un block qu'on recopie
            push edi
            mov ah,Allocate_Memory_Handle
            mov edx,ecx
            shl edx,12
            Int_EOS                         ; Allocate NEW Memory
            jc @@Ok99
            push edi
            PushES
            PushDS
            PopES
            shl ecx,10
            mov esi,[esi]                   ; On prend le vieux Block
            sub esi,[Code32_Addr]
            mov edi,edx
            cld
            rep movsd                       ; On copie l'ancien sur le nouveau
            PopES
            pop ebx                         ; Tmp edi
            pop edi
            push eax
            mov ah,DeAllocate_Memory_Handle
            Int_EOS                         ; Dealloue l'ancien Block
            pop eax
            mov edi,ebx
            PopDS                          ; Sortie avec le nouveau Handle
            pop esi
            pop ecx
            pop ebx
            Clear_Carry
            mIRETD

@@Ok99:
            pop edi
            jmp @@Ok101

@@Ok100:
            mov eax,[esi]
            mov edx,eax
            mov edi,eax
            sub edx,[Code32_Addr]
            PopDS
            pop esi
            pop ecx
            pop ebx
            Clear_Carry
            mIRETD

@@Ok101:
            PopDS
            pop esi
            pop ecx
            pop ebx
            Set_Carry
            mIRETD
else                        ; WIN32 Emulation
            push ebx
            push esi
            WIN32CALL GlobalReAlloc,edi,ecx,0
            pop esi
            pop ebx
            test eax,eax
            je @@Error
            mov edi,eax
            mov edx,eax
            Clear_Carry
            mIRETD
@@Error:
            Set_Carry
            mIRETD

endif

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
ifndef WIN32
Allocate_Selector_EOS:
            push ecx
            push esi
            push edi
            PushDS
            PushES
            LoadDS
            mov eax,edi
            mov edi,O Selector
            LoadES
            mov _ES[edi],ax
            shr eax,16
            and B _ES[edi+6],not 0fh
            or _ES[edi+6],al
            mov eax,esi
            mov _ES[edi+2],ax
            shr eax,16
            mov _ES[edi+4],al
            mov _ES[edi+7],ah
            cmp [Server_Type],DPMI           ; Serveur_Dpmi
            jne @@Ok10
            xor ax,ax
            mov cx,1
            _int 31h
            jc Allocate_Selector_EOS_Erreur
            mov bx,ax
            mov ax,cs
            lar ax,ax                       ; this one puts accsess rights in DH
            and ah,01100000b                ; we just want the DPL field.
            or [di+5],ah                    ; Set the descriptor DPL field
            mov ax,0ch
            _int 31h
            jc Allocate_Selector_EOS_Erreur
            jmp Allocate_Selector_EOS_Ok

@@Ok10:
            LoadDS
            mov esi,[Free_Sel_Offset]
            mov ecx,Nb_Free_Desc
            mov bx,_CS[Free_Sel]            ; Addresse du Premier Selecteur Vide
@@OK11:
            test B [esi+7],08h              ; Cherche un Selecteur
            jne @@Ok12                      ; Vide
            add esi,8
            add bx,8
            dec ecx
            jne @@OK11
            jmp Allocate_Selector_EOS_Erreur
@@Ok12:
            mov eax,_ES[edi]
            mov [esi],eax
            mov eax,_ES[edi+4]
            or ah,90h
            mov [esi+4],eax
Allocate_Selector_EOS_Ok:
            PopES
            PopDS
            pop edi
            pop esi
            pop ecx
            Clear_Carry
            mIRETD

Allocate_Selector_EOS_Erreur:
            PopES
            PopDS
            pop edi
            pop esi
            pop ecx
            xor bx,bx
            Set_Carry
            mIRETD

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
DeAllocate_Selector_EOS:
            push ecx
            push esi
            push edi
            PushDS
            PushES
            LoadDS
            cmp [Server_Type],DPMI           ; Serveur_Dpmi
            jne @@Ok10
            mov ax,1
            mov cx,1
            _int 31h
            jc DeAllocate_Selector_EOS_Erreur
            jmp DeAllocate_Selector_EOS_Ok

@@Ok10:
            mov esi,[Free_Sel_Offset]
            mov ax,_CS[Free_Sel]            ; Addresse du Premier Selecteur Vide
            and ebx,0ffffh
            and eax,0ffffh
            sub ebx,eax
            jc DeAllocate_Selector_EOS_Erreur ; Selecteur Invalide si inferieur a Origine
            cmp ebx,Nb_Free_Desc*8
            jg DeAllocate_Selector_EOS_Erreur ; Selecteur Invalide si plus grand que max
            add esi,ebx                     ; Offset du selecteur

@@OK11:
            test B [esi+7],08h              ; Cherche si le Selecteur existe vraiment
            jne DeAllocate_Selector_EOS_Erreur
            or B [esi+7],08h                ; Set Bit Free
DeAllocate_Selector_EOS_Ok:
            PopES
            PopDS
            pop edi
            pop esi
            pop ecx
            Clear_Carry
            mIRETD

DeAllocate_Selector_EOS_Erreur:
            PopES
            PopDS
            pop edi
            pop esi
            pop ecx
            Set_Carry
            mIRETD


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
Physical_Address_Mapping_EOS:
            push eax
            push ebx
            push ecx
            push edx
            push edi
            push ebp
            PushDS
            LoadDS
            cmp esi,1024*1024                ; above 1 MB minimun
            jb Exit_Mapping_Error
            cmp [Server_Type],DPMI           ; Serveur DPMI
            jne @@Ok8
            mov ax,800h
            push esi
            push ecx
            pop di
            pop si
            pop cx
            pop bx
            _int 31h
            jc Exit_Mapping_Error
            push bx
            push cx
            pop esi
            jmp Exit_Mapping

@@Ok8:
            mov ebp,esi
            and ebp,Not 0fffh               ; Must Be 4096 Align
            mov edx,ecx
            test edx,0fffh                  ; Aligne sur 4096 que si necessaire
            je @@Ok9
            add edx,4096
            and edx,Not 4095
@@Ok9:
            mov esi,[Addr_MappingTables]
            xor ebx,ebx                     ; Compte la plus grande region allouable
            mov ecx,[NumOfPages]            ; plus le nombre courant
            sub esi,4
            shr edx,12                      ; EDX nombre de page a alloue
@@Ok10:
            add esi,4
            test B [esi+1],4h               ; Test si bit libre
            je @@Ok12
            test ebx,ebx
            jne @@Ok11
            mov edi,esi
@@Ok11:
            inc ebx
            cmp ebx,edx
            je @@Ok30
            dec ecx
            jne @@Ok10
            jmp Exit_Mapping_Error
@@Ok12:
            xor ebx,ebx
            dec ecx
            jne @@Ok10
            jmp Exit_Mapping_Error
@@Ok30:
            mov esi,[Addr_List_Handle_Mapping]
            mov ecx,Nb_Handle_Mapping
@@Ok31:
            cmp D [esi],0
            je @@Ok32
            add esi,12
            dec ecx
            jne @@Ok31
            jmp Exit_Mapping_Error
@@Ok32:
            mov ecx,edx
            mov [esi],edi                   ; debut de la ram
            mov [esi+4],ecx                 ; Taille de la RAM / 4096
            mov eax,[edi]                   ; On prend l'addresse lineaire de base
            and eax,Not 0fffh
            mov [esi+8],eax
            mov esi,eax
            cli
;            Disable_Paging
            or ebp,7h                       ; Set:  P=1 , R/W =1, U/S=1
@@Ok40:
            mov [edi],ebp
            add ebp,1000h
            add edi,4
            dec ecx
            jne @@Ok40
;            Enable_Paging
Exit_Mapping:
            PopDS
            pop ebp
            pop edi
            pop edx
            pop ecx
            pop ebx
            pop eax
            Clear_Carry
            mIRETD

Exit_Mapping_Error:
            PopDS
            pop ebp
            pop edi
            pop edx
            pop ecx
            pop ebx
            pop eax
            Set_Carry
            mIRETD


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Free Address Mapping      Free the allocate memory mapping                ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = DeAllocate_Memory_Handle                                     ³
;³       ESI = Address of the block to freed                                ³
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
Free_Physical_Address_Mapping_EOS:
            pushad
            PushDS
            LoadDS
            cmp [Server_Type],DPMI
            jne Free_Mapping_VCPI_XMS_RAW
            push esi
            pop cx
            pop bx
            mov ax,0801h
            _int 31h
            jc @@Ok11
            PopDS
            popad
            Clear_Carry
            mIRETD
@@Ok11:
            PopDS
            popad
            Set_Carry
            mIRETD


Free_Mapping_VCPI_XMS_RAW:
            mov edi,esi
            mov ecx,Nb_Handle_Mapping
            mov esi,[Addr_List_Handle_Mapping]
@@Ok1:
            cmp D [esi+8],edi
            je @@Ok2
            add esi,12
            dec ecx
            jne @@Ok1
            PopDS
            popad
            Set_Carry
            mIRETD
@@Ok2:
            xor edi,edi
            xor ecx,ecx
            xchg edi,[esi]
            xchg ecx,[esi+4]                ; Get Size Of Memory to freed
            mov eax,[esi+8]
            cli
            or eax,600h
@@Ok10:
            mov [edi],eax                  ; Set Memory Unused
            add edi,4
            add eax,1000h
            dec ecx
            jne @@Ok10
            PopDS
            popad
            Clear_Carry
            mIRETD


endif