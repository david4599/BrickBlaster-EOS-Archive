;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Gestion de l'Interruption 21h en 32 bits
ifndef WIN32
Int_21h:
            sti                             ; have interrupts enabled for MSDOS
            PushDS
            PushES
            push _CS[Real_ES]               ;  Save  Real_DS and Real_ES
            push _CS[Real_DS]
            cmp ah,9h
            je Display_String
            cmp ah,0ah
            je Get_String
            cmp ah,0fh
            je FCB_Function
            cmp ah,10h
            je FCB_Function
            cmp ah,11h
            je FCB_Function
            cmp ah,12h
            je FCB_Function
            cmp ah,13h
            je FCB_Function
            cmp ah,14h
            je FCB_Function
            cmp ah,15h
            je FCB_Function
            cmp ah,16h
            je FCB_Function
            cmp ah,17h
            je FCB_Function
            cmp ah,1ah
            je Set_DTA
            cmp ah,21h
            je FCB_Function
            cmp ah,22h
            je FCB_Function
            cmp ah,23h
            je FCB_Function
            cmp ah,24h
            je FCB_Function
            cmp ah,25h
            je Set_Int_Dos
            cmp ah,27h
            je FCB_Function
            cmp ah,28h
            je FCB_Function
            cmp ah,2fh
            je Get_DTA
            cmp ah,34h
            je Get_Flags_InDos
            cmp ah,35h
            je Get_Int_Dos
            cmp ah,39h
            je Make_Directory
            cmp ah,3Ah
            je Remove_Directory
            cmp ah,3Bh
            je Change_Directory
            cmp ah,3Ch
            je Create_File
            cmp ah,3Dh
            je Open_File
            cmp ah,3Fh
            je Read_File
            cmp ah,40h
            je Write_File
            cmp ah,41h
            je Delete_File
            cmp ah,43h
            je File_Attributes
            cmp ah, 47h
            je Get_Directory
            cmp ah,48h
            je Allocate_Memory_Dos
            cmp ah,49h
            je Free_Memory_Dos
            cmp ah,4ah
            je Resize_Memory_Dos
            cmp ah, 4Bh
            je Load_and_Execute
            cmp ah,4Ch
            je Terminate_Program
            cmp ah,4Eh
            je Find_First
            cmp ah,4Fh
            je Find_Next
            cmp ah,56h
            je Rename_file
            cmp ah,5Ah
            je Create_Temporary_file
            cmp ah,5Bh
            je Creat_New_File
            cmp ah,60h
            je Get_Full_Name
            cmp ah,62h
            je Get_Psp
            cmp ax,0ff00h
            je Watcom_Check
            push D [esp+4*(4+2)]
            popfd
            DosInt 21h
            movzx eax,ax
            LoadDS
            pop [Real_DS]
            pop [Real_ES]
            PopES
            PopDS
            retf 4


FCB_Function:
            push ecx
            mov ecx,37
            call Fill_Buffer_DS_EDX
            pop ecx
            DosInt 21h
            call Copy_DTA
            jmp ExitInt21h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Watcom Check    Emule la presence de l'executable DOS4GW                  ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³         AL = 0ffh                                                        ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Watcom_Check:
            cmp dx,00078h
            jne @@Ok1
            mov al,0ffh
@@Ok1:
            clc
            jmp ExitInt21h


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Display String  Emule la fonction 9 de l'int 21h en utilisant la fonction ³
;³                40h write file (pour etre compatible avec le STDOUT       ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Display_String:
            pushad
            mov esi,edx
            LoadES
Display_String1:
            mov ebx,Size_ASCIIZ_Buffer
            mov edi,_CS[ASCIIZ_Buffer_Addr]
            xor ecx,ecx
@@Ok1:
            mov al,[esi]
            cmp al,'$'
            je @@Ok2
            test al,al
            je @@Ok2
            mov _ES[edi],al
            inc esi
            inc ecx
            inc edi
            dec ebx
            jne @@Ok1
@@Ok2:
            mov ah,40h
            mov ebx,1
            mov edx,_ES[Seg_Buffer]             ; set real mode pointer
            mov _ES[Real_DS],edx
            mov edx,_ES[O_ASCIIZ_Buffer]
            DosInt 21h
            cmp ecx,Size_ASCIIZ_Buffer
            je Display_String1
            popad
            jmp ExitInt21h

Get_String:
            push esi
            push edx
            LoadES
            mov edx,_ES[Seg_Buffer]             ; set real mode pointer
            mov _ES[Real_DS],edx
            mov edx,_ES[O_ASCIIZ_Buffer]
            DosInt 21h
            pop edx
            jc @@Ok1
            mov esi,edx
            call Get_ASCIIZ_Buffer_DS_ESI
            clc
@@Ok1:
            pop esi
            jmp ExitInt21h




;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set DTA         Emule la fonction 1ah de l'int 21h                        ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Offset_DTA          dd 0
Selector_DTA        dw 0
Set_DTA:
            pushad
            PushDS
            PushES
            LoadES
            mov _ES[Offset_DTA],edx
            mov _ES[Selector_DTA],ds
            mov esi,edx
            mov edi,_CS[Dta_Addr]
            mov ecx,43
            cld
            rep movsb
            mov ah,1ah
            mov edx,_ES[Seg_Buffer]
            mov [Real_DS],edx
            mov edx,_ES[O_DTA]
            DosInt 21h
            PopES
            PopDS
            popad
            clc
            jmp ExitInt21h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get DTA         Emule la fonction 2fh de l'int 21h                        ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_DTA:
            mov ebx,_CS[Offset_DTA]
            mov es,_CS[Selector_DTA]
            clc
            jmp ExitInt21h

Copy_DTA:
            pushfd
            pushad
            PushDS
            PushES
            LoadDS
            mov di,[Selector_DTA]
            test di,di
            je @@Ok10
            mov es,di
            mov edi,[Offset_DTA]
            mov esi,[Dta_Addr]
            mov ecx,43
            cld
            rep movsb
@@Ok10:
            PopES
            PopDS
            popad
            popfd
            ret


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set Int         Emule la fonction 25h de l'int 21h                        ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set_Int_Dos:
            push eax
            push ebx
            push ecx
            mov ecx,ds
            cmp al,2
            jne @@Ok1
            mov al,71h
@@Ok1:
            cmp al,8h
            jb @@Ok10
            cmp al,0fh
            ja @@Ok10
            mov bl,al
            sub bl,8
            mov ah,Set_Irq
            jmp @@Ok100
@@Ok10:
            cmp al,70h
            jb @@Ok20
            cmp al,77h
            ja @@Ok20
            mov bl,al
            sub bl,(70h-8)
            mov ah,Set_Irq
            jmp @@Ok100
@@Ok20:
            mov ah,Set_Int
            mov bl,al
@@Ok100:
            Int_EOS
            pop ecx
            pop ebx
            pop eax
            clc
            jmp ExitInt21h


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get Int         Emule la fonction 35h de l'int 21h                        ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_Int_Dos:
            push eax
            push ecx
            push edx
            xor ecx,ecx
            cmp al,2
            jne @@Ok1
            mov al,71h
@@Ok1:
            cmp al,8h
            jb @@Ok10
            cmp al,0fh
            ja @@Ok10
            mov bl,al
            sub bl,8
            mov ah,Get_Irq
            jmp @@Ok100
@@Ok10:
            cmp al,70h
            jb @@Ok20
            cmp al,77h
            ja @@Ok20
            mov bl,al
            sub bl,(70h-8)
            mov ah,Get_Irq
            jmp @@Ok100
@@Ok20:
            mov ah,Get_Int
            mov bl,al
@@Ok100:
            Int_EOS
            mov ebx,edx
            mov [esp+5*4],ecx
            pop edx
            pop ecx
            pop eax
            clc
            jmp ExitInt21h



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get Flags InDos Emule la fonction 34h de l'int 21h                        ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_Flags_InDos:
            DosInt 21h
            LoadDS
            mov [esp+2*4],ds
            movzx ebx,bx
            push eax
            movzx eax,W [Real_ES]
            shl eax,4
            add ebx,eax
            sub ebx,[Code32_Addr]
            pop eax
            clc
            jmp ExitInt21h




Remove_Directory:
Change_Directory:
Create_File:
Open_File:
Make_Directory:
Delete_File:
File_Attributes:
Creat_New_File:
            push edx
            call Fill_ASCIIZ_Buffer_DS_EDX
            DosInt 21h
            pop edx
            jmp ExitInt21h


Find_First:
            push edx
            call Fill_ASCIIZ_Buffer_DS_EDX
            DosInt 21h
            pop edx
            call Copy_DTA
            jmp ExitInt21h

Find_Next:
            DosInt 21h
            call Copy_DTA
            jmp ExitInt21h




;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Create Temporary File                                                     ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Create_Temporary_file:
            push edx
            call Fill_ASCIIZ_Buffer_DS_EDX
            DosInt 21h
            pop edx
            jc ExitInt21h
            xchg edx,esi
            call Get_ASCIIZ_Buffer_DS_ESI
            xchg edx,esi
            jmp ExitInt21h


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Allocate Memory                                                           ³
;³                                                                          ³
;³Entree :                                                                  ³
;³          AH = 48h                                                        ³
;³          BX = Size of Memory Div 16                                      ³
;³Sortie :                                                                  ³
;³          BX = Selector of the memory                                     ³
;³                                                                          ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Allocate_Memory_Dos:
            LoadDS
            mov [Size_Alloc],ebx
            DosInt 21h
            movzx eax,ax
            movzx ebx,bx
            jc ExitInt21h
            call Segment_To_Descriptor
            jc ExitInt21h
            clc
            jmp ExitInt21h




;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Resize Memory                                                             ³
;³                                                                          ³
;³Entree :                                                                  ³
;³          AH = 4ah                                                        ³
;³          BX = New Size of Memory Div 16                                  ³
;³          ES = Selector of Memory                                         ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Resize_Memory_Dos:
            LoadDS
            push ebx
            push ecx
            push edx
            push esi
            mov [Size_Alloc],ebx
            mov ebx,es
            call Get_Base_Segment
            jc @@Ok20
            shr dx,4
            shl cx,12
            or dx,cx
            mov [Real_ES],edx
            mov ah,4ah
            mov ebx,[Size_Alloc]
            DosInt 21h
            movzx eax,ax
            movzx ebx,bx
            mov [esp+3*4],ebx
            jc @@Ok20
            mov ebx,es
            call Set_Segment_Limit
            clc
@@Ok20:
            pop esi
            pop edx
            pop ecx
            pop ebx
            jmp ExitInt21h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Free Memory                                                               ³
;³                                                                          ³
;³Entree :                                                                  ³
;³          AH = 49h                                                        ³
;³          ES = Selector of Memory                                         ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Free_Memory_Dos:
            LoadDS
            push ebx
            push ecx
            push edx
            push esi
            mov ebx,es
            call Get_Base_Segment
            jc @@Ok20
            shr dx,4
            shl cx,12
            or dx,cx
            mov [Real_ES],edx
            mov ah,49h
            DosInt 21h
            movzx eax,ax
            jc @@Ok20
            call Free_Selector
            jc @@Ok20
            clc
@@Ok20:
            pop esi
            pop edx
            pop ecx
            pop ebx
            jmp ExitInt21h


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load and Execute                                                          ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Load_and_Execute:
            push edx
            push ebx
            push eax
            mov es,_ES[ebx+10]
            mov ebx,_ES[ebx+6]
            call Fill_ASCIIZ_Buffer2_ES_EBX
            call Fill_ASCIIZ_Buffer_DS_EDX
            LoadDS
            mov ah,51h
            DosInt 21h
            movzx eax,bx
            mov [Param_FCB1_Seg],ax
            mov [Param_FCB2_Seg],ax
            shl eax,4
            sub eax,[Code32_Addr]
            mov bx,[eax+5ch]
            mov [Param_FCB1_Off],bx
            mov bx,[eax+6ch]
            mov [Param_FCB2_Off],bx
            pushad
            movzx ebx,W [eax+2ch]
            call Get_Base_Segment
            shr dx,4
            shl ecx,12
            or edx,ecx
            mov [Param_Block],dx
            popad
            mov eax,[O_ASCIIZ_Buffer2]
            mov [Param_Off],ax
            mov eax,[Seg_Buffer]                    ; set real mode pointer
            mov [Param_Seg],ax
            LoadES
            mov ebx,O Param_Block
            add ebx,_ES[Code32_Addr]
            shr ebx,4
            mov [Real_ES],ebx
            mov ebx,O Param_Block
            pop eax
            and ebx,0fh
            DosInt 21h
            pop ebx
            pop edx
            jmp ExitInt21h

Param_Block dw 0                            ; Segment Environement
Param_Off   dw 0                            ; Offset des Param
Param_Seg   dw 0                            ; Seg Offset
Param_FCB1_Off      dw 0                    ; Offset FCB1
Param_FCB1_Seg      dw 0                    ; Segment FCB1
Param_FCB2_Off      dw 0                    ; Offset FCB2
Param_FCB2_Seg      dw 0                    ; Segment FCB2


Byte_Count          dd 0
Bytes_Read          dd 0
Bytes_Written       dd 0

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Read File                                                                 ³
;³                                                                          ³
;³Entree :                                                                  ³
;³          BX = handle of the opened file                                  ³
;³          ECX = number of bytes to read                                   ³
;³          DS:EDX = far pointer of the data to read to the file.           ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : EAX Number of Bytes read                         ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Read_File:
            push ecx
            push edx
            push esi
            push edi
            PushDS
            PopES
            cld
            LoadDS
            mov [Bytes_Read],0
            mov [Byte_Count],ecx
            mov edi,edx
            mov edx,[Seg_Buffer]         ; set real mode DS reg
            mov [Real_DS],edx
@@Ok1:
            mov ecx,Size_File_Block_Buffer          ; Bytes to write
            sub [Byte_Count],ecx
            jg @@Ok2
            add ecx,[Byte_Count]
@@Ok2:
            mov ah,03Fh
            mov edx,[O_File_Block_Buffer]
            DosInt 21h
            jc @@Ok5
            and eax,0FFFFh
            je @@Ok4
            add [Bytes_Read],eax
            mov ecx,eax
            mov esi,[File_Block_Buffer_Addr]
            mov edx,ecx
            shr ecx,2
            rep movsd                               ; end Dword
            and edx,3
            je @@Ok3
            mov ecx,edx
            rep movsb                               ; copy from DS:ESI --> ES:EDI
@@Ok3:
            cmp ax,Size_File_Block_Buffer
            je @@Ok1
@@Ok4:
            mov eax,[Bytes_Read]
            clc
@@Ok5:
            pop edi
            pop esi
            pop edx
            pop ecx
            jmp ExitInt21h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Write File                                                                ³
;³                                                                          ³
;³Entree :                                                                  ³
;³          BX = handle of the opened file                                  ³
;³          ECX = number of bytes to write                                  ³
;³          DS:EDX = far pointer of the data to write to the file.          ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : EAX Number of Bytes written                      ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Write_File:
            push ebx
            push ecx
            push edx
            push esi
            push edi
            cld
            LoadES
            mov _ES[Bytes_Written],0
            mov _ES[Byte_Count],ecx
            mov esi,edx

@@Ok1:
            mov ecx,Size_File_Block_Buffer              ; Bytes to write
            sub _ES[Byte_Count],ecx
            ja @@Ok2
            add ecx,_ES[Byte_Count]
@@Ok2:

            push ecx                        ; copy area to block buffer
            mov edi,_ES[File_Block_Buffer_Addr]
            mov edx,ecx
            shr ecx,2
            rep movsd                       ; end Dword
            and edx,3
            je @@Ok3
            mov ecx,edx
            rep movsb                       ; copy from DS:ESI --> ES:EDI
@@Ok3:
            pop ecx

            mov edx,_ES[Seg_Buffer]         ; set real mode DS reg
            mov _ES[Real_DS],edx
            mov edx,_ES[O_File_Block_Buffer];as a far pointer
            mov ah,040h                     ; write_handle file
            DosInt 21h
            jc @@Ok5
            and eax,0FFFFh
            je @@Ok4
            add _ES[Bytes_Written],eax
            cmp cx,Size_File_Block_Buffer
            je @@Ok1
@@Ok4:
            mov eax,_ES[Bytes_Written]
            clc
@@Ok5:
            pop edi
            pop esi
            pop edx
            pop ecx
            pop ebx
            jmp ExitInt21h



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Rename File                                                               ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Rename_file:
            push edx
            push edi
            call Fill_ASCIIZ_Buffer_DS_EDX
            call Fill_ASCIIZ_Buffer2_ES_EDI
            DosInt 21h
            pop edi
            pop edx
            jmp ExitInt21h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get Directory                                                             ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie :                                                  ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_Directory:
            push esi
            PushDS
            LoadDS
            mov esi,[Seg_Buffer]            ; set real mode pointer
            mov [Real_DS],esi
            mov esi,[O_ASCIIZ_Buffer]
            DosInt 21h
            PopDS
            pop esi
            jc ExitInt21h
            call Get_ASCIIZ_Buffer_DS_ESI
            jmp ExitInt21h


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get Full Name   function 60h                                              ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie :                                                  ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_Full_Name:
            push edx
            push esi
            push edi
            mov edx,esi
            call Fill_ASCIIZ_Buffer_DS_EDX
            mov esi,edx
            call Fill_ASCIIZ_Buffer2_ES_EDI
            DosInt 21h
            pop edi
            call Get_ASCIIZ_Buffer2_ES_EDI
            pop esi
            pop edx
            jmp ExitInt21h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get Psp         function 62h                                              ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie :                                                  ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_Psp:
            mov bx,_CS[PSP_Sel]
            clc
            jmp ExitInt21h



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Terminate Program                                                         ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie :                                                  ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tmp_EAX_    dd 0
Terminate_Program:
            LoadDS
            mov [Tmp_EAX_],eax
            cli
            mov ax,_CS[Data32_Sel]
            mov es,ax
            mov fs,ax
            mov gs,ax
            mov ss,ax
            mov esp,[Pmode_Stack]
            call Close_EOS
            call Close_Memory

            cmp [Server_Type], DPMI
            jne @@Ok2
Assume es:Kernel_Setup
            PushES
            mov es,_CS[Data16_Sel]
            mov ax,304h
            mov dx,_ES[Call_Back_DPMI]
            mov cx,_ES[Call_Back_DPMI+2]
            _int 31h
            PopES
Assume es:CODE32
            mov ax,0205h
            mov bl,21h
            mov cx,W [old_DPMI_int21h+4]
            mov edx,D [old_DPMI_int21h]     ; Restaure l'ancienne Int 21h
            _int 31h
            mov eax,[Tmp_EAX_]
            mov ah,4ch
            _int 21h

@@Ok2:
            mov eax,[Tmp_EAX_]
            mov ds,_CS[Data16_Sel]
Assume ds:Kernel_Setup
            mov [Code_Erreur+1],al
            cmp _CS[Server_Type],VCPI
            je @@Ok3
            mov eax,O Exit_To_DOS_Raw
            db 0eah
            dd O Go_Real_Mode,Code16_Desc-GDT
@@Ok3:
            push small Kernel_Setup
            push small O VCPI_Terminate_Program
            _int Int_Val_Call

Assume ds:CODE32





;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ExitInt21h  Routine commune pour la sortie des fonction de l'int 21h      ³
;³                                                                          ³
;³Entree :                                                                  ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³Autre Registre Modifie :                                                  ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ExitInt21h:
            LoadDS
            pop [Real_DS]
            pop [Real_ES]
            PopES
            PopDS
            jnc @@Ok1
            movzx eax,ax
            Set_Carry
            mIRETD
@@Ok1:
            Clear_Carry
            mIRETD

;--------------------------------------------------------
; Proc will fill a ASCIIZ buffer with the string pointed to by DS:EDX
; It then sets [real_DS] and DX as a real mode far pointer.

Fill_ASCIIZ_Buffer_DS_EDX:
            PushES
            pushad
            LoadES
            mov edi,_CS[ASCIIZ_Buffer_Addr]
            mov ecx,Size_ASCIIZ_Buffer-1
@@Ok1:
            mov al,[edx]
            mov _ES[edi],al
            inc edx
            inc edi
            test al,al
            je @@Ok5
            dec ecx
            jne @@Ok1
            mov B _ES[edi],0
@@Ok5:
            popad
            mov edx,_CS[Seg_Buffer]             ; set real mode pointer
            mov _ES[Real_DS],edx
            mov edx,_CS[O_ASCIIZ_Buffer]
            PopES
            ret

;--------------------------------------------------------
; Proc will fill a ASCIIZ buffer with the string pointed to by ES:EDI
; It then sets [real_ES] and DI as a real mode far pointer to the buffer.

Fill_ASCIIZ_Buffer2_ES_EDI:
            PushDS
            pushad
            LoadDS
            mov edx,[ASCIIZ_Buffer2_Addr]
            mov ecx,Size_ASCIIZ_Buffer2-1
@@Ok1:
            mov al,_ES[edi]
            mov [edx],al
            inc edi
            inc edx
            test al,al
            je @@Ok5
            dec ecx
            jne @@Ok1
            mov B [edx],0
@@Ok5:
            popad
            mov edi,[Seg_Buffer]            ; set real mode pointer
            mov [Real_ES],edi
            mov edi,[O_ASCIIZ_Buffer2]
            PopDS
            ret

;--------------------------------------------------------
; Proc will fill a ASCIIZ buffer with the string pointed to by ES:EDI
; It then sets [real_ES] and DI as a real mode far pointer to the buffer.
; Only for Exec Fonction

Fill_ASCIIZ_Buffer2_ES_EBX:
            PushDS
            pushad
            LoadDS
            mov edx,[ASCIIZ_Buffer2_Addr]
            xor ecx,ecx
@@Ok1:
            mov al,_ES[ebx+ecx]
            test al,al
            je @@Ok5
            mov [edx+ecx],al
            inc ecx
            cmp ecx,128
            jne @@Ok1
@@Ok5:
            popad
            PopDS
            ret

;--------------------------------------------------------
; Proc will read the ASCIIZ buffer and copy it into the string pointed to
; by DS:ESI

Get_ASCIIZ_Buffer_DS_ESI:
            pushad
            PushES
            LoadES
            mov edx,_CS[ASCIIZ_Buffer_Addr]
            mov ecx,Size_ASCIIZ_Buffer-1
@@Ok1:
            mov al,_ES[edx]
            mov _DS[esi],al
            inc edx
            inc esi
            test al,al
            je @@Ok5
            dec ecx
            jne @@Ok1
            mov B _DS[esi],0
@@Ok5:
            PopES
            popad
            ret

;--------------------------------------------------------
; Proc will read the ASCIIZ buffer and copy it into the string pointed to
; by ES:EDI

Get_ASCIIZ_Buffer2_ES_EDI:
            pushad
            PushDS
            LoadDS
            mov edx,[ASCIIZ_Buffer2_Addr]
            mov ecx,Size_ASCIIZ_Buffer-1
@@Ok1:
            mov al,_DS[edx]
            mov _ES[edi],al
            inc edx
            inc edi
            test al,al
            je @@Ok5
            dec ecx
            jne @@Ok1
            mov B _ES[edi],0
@@Ok5:
            PopDS
            popad
            ret

;--------------------------------------------------------
; Proc will fill a ASCIIZ buffer with the string pointed to by DS:EDX
; It then sets [real_DS] and DX as a real mode far pointer.
; Lenght Pass by ECX

Fill_Buffer_DS_EDX:
            PushES
            pushad
            LoadES
            mov edi,_CS[ASCIIZ_Buffer_Addr]
@@Ok1:
            mov al,[edx]
            mov _ES[edi],al
            inc edx
            inc edi
            dec ecx
            jne @@Ok1
            popad
            mov edx,_CS[Seg_Buffer]             ; set real mode pointer
            mov _ES[Real_DS],edx
            mov edx,_CS[O_ASCIIZ_Buffer]
            PopES
            ret



;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Tmp_GDT     df 0
Size_Alloc  dd 0
;
;Int:
;           AX = Segment mode REAL
;           Size_Alloc = Size of Selector
;
;Out:
;           AX = Selector
;
;
Segment_To_Descriptor:
            push ebx
            push ecx
            push edx
            push esi
            push edi
            cmp _CS[Server_Type],DPMI
            jne @@Ok10
            push ax
            mov ax,0h
            mov cx,1
            _int 31h
            pop dx
            jc @@Ok14
            mov bx,ax
            xor cx,cx
            mov ax,7
            _int 31h
            jc @@Ok14
            call Set_Segment_Limit
            mov ax,bx
            jc @@Ok14
            jmp @@Ok30
@@Ok10:
            mov ebx,eax
            LoadDS
            mov esi,[Free_Sel_Offset]
            mov edx,Nb_Free_Desc
            mov ax,[Free_Sel]               ; Addresse du Premier Selecteur Vide
@@OK11:
            test B [esi+7],08h              ; Cherche un Selecteur
            jne @@Ok20                      ; Vide
            push esi                       ; Regarde si segment
            push ebx
            movzx ebx,ax                    ; Real n'est pas deja mappe
            sgdt [Tmp_GDT]
            mov esi,D [Tmp_GDT+2]
            sub esi,[Code32_Addr]
            mov ch,[esi+ebx+7]
            mov cl,[esi+ebx+4]
            mov dx,[esi+ebx+2]
            pop ebx
            pop esi
            cmp cx,10h                      ; cx > 10h dont superieur a 1 Mo
            jae @@Ok13
            shl cx,12
            shr dx,4
            or dx,cx
            cmp dx,bx
            je @@Ok30                       ; Selecteur deja mapper
@@Ok13:
            add esi,8
            add ax,8
            dec edx
            jne @@OK11
@@Ok14:
            pop edi
            pop esi
            pop edx
            pop ecx
            pop ebx
            stc
            ret
@@Ok20:
            movzx edi,ax
            sub di,[Free_Sel]
            add edi,[Free_Sel_Offset]
            and ebx,0ffffh
            mov edx,ebx
            shr edx,12
            shl ebx,20
            movzx esi,W [Size_Alloc]
            shl esi,4
            xchg bx,si
            or edx,esi
            or edx,409200h                  ; Set Selector
            mov [edi],ebx
            mov [edi+4],edx
@@Ok30:
            pop edi
            pop esi
            pop edx
            pop ecx
            pop ebx
            clc
            ret

Get_Base_Segment:
            cmp _CS[Server_Type],DPMI
            jne @@Ok10
            mov ax,6
            _int 31h
            jc @@Ok19
            ret

@@Ok10:
            sgdt [Tmp_GDT]
            mov esi,D [Tmp_GDT+2]
            sub esi,[Code32_Addr]
            add esi,ebx
            mov ch,[esi+7]
            mov cl,[esi+4]
            mov dx,[esi+2]
            jc @@Ok20
            test cx,0fff0h
            jne @@Ok20
@@Ok19:
            clc
@@Ok20:
            ret

Set_Segment_Limit:
            cmp _CS[Server_Type],DPMI
            jne @@Ok10
            push eax
            mov ecx,[Size_Alloc]
            shl ecx,4
            xchg dx,cx
            shr ecx,16
            mov ax,8h
            _int 31h
            pop eax
            jc @@Ok12
            ret

@@Ok10:
            mov ebx,[Size_Alloc]
            shl ebx,4
            mov [esi],bx
            shr ebx,16
            and B [esi+6],Not 0fh
            and bl,0fh
            or [esi+6],bl
            clc
@@Ok12:
            ret

Free_Selector:
            cmp _CS[Server_Type],DPMI
            jne @@Ok10
            mov ax,1h
            mov bx,es
            _int 31h
            ret
@@Ok10:
            or D [esi+7],08h
            clc
            ret
else        ; WIN32 Emulation
SDATA

Addr_DTA    dd 0
finddata    _WIN32_FIND_DATA  <>

Buffer      db 1024 dup (0)
SCODE
Simulate_Int21h:
            push ebx
            push ecx
            push edx
            cmp ah,9
            je Display_String
            cmp ah,0eh
            je SetCurrentDrive
            cmp ah,19h
            je GetCurrentDrive
            cmp ah,1Ah
            je SetDTA
            cmp ah,3bh
            je SetCurrentDirectory_DOS
            cmp ah,3ch
            je Create_File
            cmp ah,3dh
            je Open_File
            cmp ah,3fh
            je Read_File
            cmp ah,3eh
            je Close_File
            cmp ah,40h
            je Write_File
            cmp ah,42h
            je Seek_File
            cmp ah,47h
            je GetCurrentDirectory_DOS
            cmp ah,4eh
            je FindFirst_DOS
            cmp ah,4fh
            je FindNext_DOS
            cmp ah,4ch
            je Exit_Program
            jmp Exit_Error_Int21h
Exit_TestEAX:
            test eax,eax
            je Exit_Error_Int21h
Exit_Ok_Int21h:
            pop edx
            pop ecx
            pop ebx
            clc
            ret 4

Exit_Error_Int21h:
            pop edx
            pop ecx
            pop ebx
            stc
            ret 4

SetDTA:
            mov [Addr_DTA],edx
            jmp Exit_Ok_Int21h


Display_String:
            pushad
            mov edi,O Buffer
            xor esi,esi
@@Loop:
            mov al,[edx+esi]
            mov [edi+esi],al
            test al,al
            je @@End
            cmp al,'$'
            jne @@Skip
            mov D [edi+esi],0
            jmp @@End
@@Skip:
            cmp al,'þ'
            jne @@Skip2
            mov B [edi+esi],'!'
@@Skip2:
            inc esi
            jmp @@Loop
@@End:
            popad
            CCALL RestorePalette
            WIN32CALL MessageBox,MainhWnd,<O Buffer>,<O msg_eos>,MB_ICONASTERISK
            jmp Exit_Ok_Int21h

Exit_Program:
            and eax,0ffh
            WIN32CALL PostQuitMessage,eax
            jmp _CheckWinMsg

Create_File:
            WIN32CALL CreateFile,edx,GENERIC_READ+GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL+FILE_FLAG_SEQUENTIAL_SCAN,0
            cmp eax,INVALID_HANDLE_VALUE
            je Exit_Error_Int21h
            jmp Exit_Ok_Int21h

Open_File:
            xor ecx,ecx
            and eax,3
            jne @@Ok1
            or ecx,GENERIC_READ
@@Ok1:
            cmp eax,1
            jne @@Ok2
            or ecx,GENERIC_WRITE
@@Ok2:
            cmp eax,2
            jne @@Ok3
            or ecx,GENERIC_READ+GENERIC_WRITE
@@Ok3:
            WIN32CALL CreateFile,edx,ecx,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL+FILE_FLAG_SEQUENTIAL_SCAN,0
            cmp eax,INVALID_HANDLE_VALUE
            je Exit_Error_Int21h
            jmp Exit_Ok_Int21h

Read_File:
            push 0
            mov eax,esp
            WIN32CALL ReadFile,ebx,edx,ecx,eax,0
            pop eax
            jmp Exit_TestEAX

Write_File:
            push 0
            mov eax,esp
            WIN32CALL WriteFile,ebx,edx,ecx,eax,0
            pop eax
            jmp Exit_TestEAX

Close_File:
            WIN32CALL CloseHandle,ebx
            jmp Exit_TestEAX

Seek_File:
            and eax,03h
            shl ecx,16
            mov cx,dx
            WIN32CALL SetFilePointer,ebx,ecx,0,eax
            cmp eax,INVALID_HANDLE_VALUE
            je Exit_Error_Int21h
            mov edx,eax
            shr edx,16
            mov [esp],edx           ; Set EDX in the Stack
            jmp Exit_Ok_Int21h

SetCurrentDrive:
            add dl,'A'
            and edx,0ffh
            or edx,":"*256
            push edx
            WIN32CALL SetCurrentDirectory,esp
            add esp,4
            jmp Exit_Ok_Int21h

GetCurrentDrive:
;            call _getdrive
            dec al
            jmp Exit_Ok_Int21h

GetCurrentDirectory_DOS:
            WIN32CALL GetCurrentDirectory,128,esi
            jmp Exit_TestEAX

SetCurrentDirectory_DOS:
            WIN32CALL SetCurrentDirectory,edx
            jmp Exit_TestEAX

UpdateDTA:
            mov ebx,[Addr_DTA]
            mov eax,[finddata._WIN32_FIND_DATA.dwFileAttributes]
            mov [ebx._DOS_FIND_DATA.fAttributes],al

            mov eax,[finddata._WIN32_FIND_DATA.nFileSizeLow]
            mov [ebx._DOS_FIND_DATA.fFileSize],eax
            push esi
            push edi
            lea esi,[ebx._DOS_FIND_DATA.fLastWriteTime]
            lea edi,[ebx._DOS_FIND_DATA.fLastWriteDate]
            WIN32CALL FileTimeToDosDateTime,<O _WIN32_FIND_DATA.ftLastWriteTime>,edi,esi
            lea edi,[ebx._DOS_FIND_DATA.fFileName]
            WIN32CALL GetShortPathName,<O finddata._WIN32_FIND_DATA.cFileName>,edi,13
            pop edi
            pop esi
            ret

FindFirst_DOS:
            WIN32CALL FindFirstFile,edx,<O finddata>
            cmp eax,INVALID_HANDLE_VALUE
            je Exit_Error_Int21h
            mov ebx,[Addr_DTA]
            test ebx,ebx
            je Exit_Error_Int21h
            mov [ebx],eax                           ; [EBX],handle
            call UpdateDTA
            jmp Exit_Ok_Int21h

FindNext_DOS:
            mov ebx,[Addr_DTA]
            mov eax,[ebx]
            WIN32CALL FindNextFile,eax,<O finddata>
            test eax,eax
            jne @@Ok1
            mov ebx,[Addr_DTA]
            mov eax,[ebx]
            WIN32CALL FindClose,eax
            mov eax,18
            jmp Exit_Error_Int21h
@@Ok1:
            call UpdateDTA
            xor eax,eax
            jmp Exit_Ok_Int21h
endif