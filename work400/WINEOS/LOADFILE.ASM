SDATA
Global      Test_Linked     : proc

SFILE       Struc
Name_File   db 12 dup (0)
Size_File   dd 0
Pos_File    dd 0
SFILE       ends

SH_EOS      Struc
Sign        db 4 dup (0)
Nb_File     dd 0
            db 12 dup (0)
SH_EOS      Ends

Max_Files   = 256

Header_EOS Label byte
            SH_EOS <>
Header_File Label byte
            Rept Max_Files
             SFILE <>
            endm


;Addr_Header_File dd 0

Linked              db Off

Msg_Not_Found       db '    ş File Not Found : '
Name_Tmp            db 128 dup (0)

Name_Executable     db 128 dup (0)

Pos_Header          dd 0
File_Size           dd 0            ; Contient la taille du fichier compresser
                                    ; ou non
Use_Handle          db Off          ; Off pour utiliser sans les handles
                                    ; On pour allouer avec les handles
From_Memory         db Off          ; On pour simule le chargement

Source      df 0

SCODE

Test_Linked:
            pushad
            PushDS
            PushES
ifdef WIN32
            mov esi,[Environment_Addr]
else
            xor esi,esi
            mov ax,[Environment_Sel]
            mov ds,ax
            mov ax,_CS[Data32_Sel]
            mov es,ax
endif
            mov edi,O Name_Executable
@@Ok1:
            lodsb
            dec al
            jne @@Ok1
            lodsb
@@Ok2:
            movsb
            cmp B [esi],0
            jne @@Ok2
            PushES
            PopDS
            mov ax,3d00h
            mov edx,O Name_Executable
            _int 21h
            jnc @@Ok20
            mov edi,O Name_Tmp
            mov ecx,128
@@Ok11:
            mov al,[edx]
            mov [edi],al
            inc edx
            inc edi
            dec cx
            je @@Ok12
            cmp al,36
            je @@Ok12
            cmp al,0
            jne @@Ok11
@@Ok12:
            dec edi
            mov B [edi],13
            mov B [edi+1],10
            mov B [edi+2],36
            mov ah,Exit_Error
            mov edx,offset Msg_Not_Found
            Int_EOS
@@Ok20:
            mov ebx,eax
            mov ax,4202h
            mov cx,-1
            mov dx,-4
            _int 21h
            mov ah,3fh
            mov ecx,4
            mov edx,offset Pos_Header
            _int 21h
            mov ax,4200h
            mov ecx,[Pos_Header]
            mov edx,ecx
            shr ecx,16
            _int 21h
            mov ah,3fh
            mov ecx,20
            mov edx,offset Header_EOS
            _int 21h
            cmp D [Header_EOS],'SOE'
            jne @@Ok30
            mov [Linked],On
            mov ecx,[Header_EOS.SH_EOS.Nb_File]
            imul ecx,Size SFILE
;            mov ah,Allocate_Memory
            mov edx,O Header_File
;            Int_EOS
;            mov [Addr_Header_File],edx
            mov ah,3fh
            _int 21h
            mov ecx,eax
            mov al,0ffh
@@Ok10:
            xor [edx],al
            rol al,3
            inc edx
            xor al,12h
            add al,45h
            dec ecx
            jne @@Ok10
            mov ah,3eh
            _int 21h
@@Ok30:
            PopES
            PopDS
            popad
            ret

Get_Header:
            call Transfert_Name
            PushDS
            PushES
            PopDS
;            mov edi,[Addr_Header_File]
            mov edi,O Header_File
            mov esi,O Name_Tmp
            mov ecx,[Header_EOS.Nb_File]
@@Ok1:
            mov ebx,12
            push esi
            push edi
@@Ok2:
            mov al,[edi]
            or al,al
            je @@Ok3
            cmp al,[esi]
            jne @@Ok5
            inc edi
            inc esi
            dec ebx
            jne @@Ok2
@@Ok3:
            pop edi
            pop esi
            mov eax,[edi.SFILE.Size_File]
            mov ebx,[edi.SFILE.Pos_File]
            mov [Size_Tmp],eax
            mov [Pos_Tmp],ebx
            PopDS
            clc
            ret
@@Ok5:
            pop edi
            pop esi
            add edi,Size SFILE
            dec ecx
            jne @@Ok1
            PopDS
            stc
            ret

Transfert_Name:
            mov edi,offset Name_Tmp
            xor ecx,ecx
@@Ok1:
            cmp B [esi],0
            je @@Ok2
            inc esi
            inc ecx
            jmp @@Ok1
@@Ok2:
            dec esi
            mov al,[esi]
            cmp al,'\'
            je @@Ok4
            cmp al,':'
            je @@Ok4
            dec ecx
            jne @@Ok2
            dec esi
@@Ok4:
            inc esi
            mov al,[esi]
            or al,al
            je @@Ok5
            call Capsup
            mov _ES[edi],al
            inc edi
            jmp @@Ok4
@@Ok5:
            ret

Capsup:
	cmp al,'a'
            jb @@Ok1
	cmp al,'z'
            ja @@Ok1
	sub al,20h
@@Ok1:
	ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load Internal file Handle  Load a file which is link with LLINK           ³
;³                     if the file is not present the program stop and      ³
;³                     display a error message                              ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Load_Internal_File_Handle                                    ³
;³       EDX = Offset of file name                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³       EAX = Logical address of buffer (work with Data32_Sel)             ³
;³       ECX = Number of bytes read                                         ³
;³       ESI = Physical address of buffer (work with Zero_Sel)              ³
;³       EDI = Handle of Memory                                             ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Load_Internal_File_Handle_EOS:
            push ebx
            push ecx
            push edx
            push esi
            push edi
            push ebp
            PushDS
            PushES
            push edx
            LoadES
            mov _ES[Use_Handle],On
            jmp Load_Internal_File_EOS2

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load Internal file   Load a file which is link with LLINK                 ³
;³                     if the file is not present the program stop and      ³
;³                     display a error message                              ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Load_Internal_File                                           ³
;³       EDX = Offset of file name                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³       EAX = Logical address of buffer (work with Data32_Sel)             ³
;³       ECX = Number of bytes read                                         ³
;³       ESI = Physical address of buffer (work with Zero_Sel)              ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SDATA
Size_Tmp dd 0
Pos_Tmp dd 0
SCODE

Load_Internal_File_EOS:
            push ebx
            push ecx
            push edx
            push esi
            push edi
            push ebp
            PushDS
            PushES
            push edx
            LoadES
            mov _ES[Use_Handle],Off
Load_Internal_File_EOS2:
            cmp _ES[Linked],Off
            je @@Ok10
            mov esi,edx
            call Get_Header
            jc @@Ok10_2
            pop edx
            push edx
            PushDS
            mov ax,3d00h
            LoadDS
            mov edx,O Name_Executable
            _int 21h
            PopDS
            jc @@Ok10_2
            pop edx
            push edx
           ÿmov _ES[Diet_Handle],eax
            mov ebx,eax
            mov ax,4200h
            mov ecx,_ES[Pos_Tmp]
            mov edx,ecx
            shr ecx,16
            _int 21h
            mov eax,'SOE'
            call Load_File
            jc @@Ok10_2
            pop edx
            jmp @@Ok15

@@Ok10:
            mov ax,3D00h
            _int 21h                 ; Open the file
           ÿjc @@Ok10_2
           ÿmov _ES[Diet_Handle],eax
            mov eax,'zld'
            call Load_File
@@Ok10_2:
            pop esi
            jnc @@Ok15
            mov edi,O Name_Tmp
            mov cl,128
@@Ok11:
            mov al,[esi]
            call Capsup
            mov _ES[edi],al
            inc esi
            inc edi
            dec cl
            je @@Ok12
            cmp al,36
            je @@Ok12
            test al,al
            jne @@Ok11
@@Ok12:
            dec edi
            mov B _ES[edi],13
            mov B _ES[edi+1],10
            mov B _ES[edi+2],36
            mov ah,Exit_Error
            mov edx,O Msg_Not_Found
            LoadDS
            Int_EOS
@@Ok15:
            PopES
            PopDS
            pop ebp
            pop edi
            pop esi
            pop edx
            pop ecx
            pop ebx
            mov ecx,_CS[File_Size]
            mov esi,_CS[Diet_True_Buffer]
            cmp _CS[Use_Handle],Off
            je @@Ok20
            mov edi,_CS[Diet_Handle_Mem]
@@Ok20:
            Clear_Carry
            mIRETD

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load External file Handle  Load a external file and uncompress it if it   ³
;³                           has been compress with Diet 1.44               ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Load_External_File_Handle                                    ³
;³       EDX = Offset of file name                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = Logical address of buffer (work with Data32_Sel)             ³
;³       ECX = Number of bytes read                                         ³
;³       ESI = Physical address of buffer (work with Zero_Sel)              ³
;³       EDI = Handle of Memory                                             ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³       EAX = 1 File Not Found                                             ³
;³             2 Not Enough Memory                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Load_External_File_Handle_EOS:
            push ebx
            push ecx
            push edx
            push esi
            push edi
            push ebp
            PushDS
            PushES
            LoadES
            mov _ES[Use_Handle],On
            jmp Load_External_File_EOS2



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load External file   Load a external file and uncompress it if it has     ³
;³                     been compress with Diet 1.44                         ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Load_External_File                                           ³
;³       EDX = Offset of file name                                          ³
;³                                                                          ³
;³Out :                                                                     ³
;³       Carry = 0                                                          ³
;³        All done                                                          ³
;³       EAX = Logical address of buffer (work with Data32_Sel)             ³
;³       ECX = Number of bytes read                                         ³
;³       ESI = Physical address of buffer (work with Zero_Sel)              ³
;³                                                                          ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Error                                                             ³
;³       EAX = 1 File Not Found                                             ³
;³             2 Not Enough Memory                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Load_External_File_EOS:
            push ebx
            push ecx
            push edx
            push esi
            push edi
            push ebp
            PushDS
            PushES
            LoadES
            mov _ES[Use_Handle],Off
Load_External_File_EOS2:
            mov ax,3D00h
            _int 21h                 ; Open the file
           ÿjnc @@Ok0
            mov eax,1
            jmp @@Ok1
@@Ok0:
           ÿmov _ES[Diet_Handle],eax
            mov ebx,eax
            mov _ES[Pos_Tmp],0
            mov ax,4202h
            xor ecx,ecx
            xor edx,edx
            _int 21h
            shl edx,16
            mov dx,ax
            mov _ES[Size_Tmp],edx
            mov ax,4200h
            xor ecx,ecx
            xor edx,edx
            _int 21h
            mov eax,'zld'
            call Load_File
            jc @@Ok1
            PopES
            PopDS
            pop ebp
            pop edi
            pop esi
            pop edx
            pop ecx
            pop ebx
            mov ecx,_CS[File_Size]
            mov esi,_CS[Diet_True_Buffer]
            cmp _CS[Use_Handle],Off
            je @@Ok10
            mov edi,_CS[Diet_Handle_Mem]
@@Ok10:
            Clear_Carry
            mIRETD
@@Ok1:
            PopES
            PopDS
            pop ebp
            pop edi
            pop esi
            pop edx
            pop ecx
            pop ebx
            Set_Carry
            mIRETD









;Public Load_File,Diet_Buffer_Size


next_byte	macro
            shr bp,1
            dec dl
            jnz @@no_next_byte
            lodsw
            mov bp,ax
            mov dl,10h
            pushfd
            mov eax,esi
            sub eax,Diet_Buffer
            cmp eax,Diet_Buffer_Size
            jb @@no_next_buffer
            call Read_LZ
@@no_next_buffer:
            popfd
@@no_next_byte:
	endm


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Load_File
; ---------
; Charge un fichier en memoire et le decompacte si compactage Diet 1.44.
;
;
; Entr‚e: EDX=File_Name
;
; Sortie: c=0 EAX=File_Buffer
;         c=1 EAX=1 File error
;                 2 Out of memory
;
;
; Exemple : mov edx,offset File_Name
;         	call Load_File
;	jc Error
;         	mov File_Buffer,eax
;
;
; Taille du buffer de d‚compression variable (par d‚faut 32k) :
;
;           mov Diet_Buffer_size,4000h  ; N'utiliser que 16k.				      de d‚compression.
;
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Variables
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SDATA
Diet_Buffer_Size	dd 8000h
Diet_Buffer_Size10	dd ?
Diet_Buffer		dd ?
Diet_File_Buffer	dd ?
Diet_True_Buffer    dd ?
Diet_Handle_Mem     dd ?
Diet_Handle         dd ?
Diet_Handle_2       dd ?
Diet_File_Header    label word
		db 17 dup (0)
SCODE
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Load_File:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            PushDS
            push eax
            LoadDS
           ÿmov ecx,17
           ÿmov edx,Offset Diet_File_Header
            mov ebx,Diet_Handle
           ÿmov ah,3Fh
           ÿ_int 21h
            mov ecx,eax
            pop eax                 ; Read File header
            PopDS
           ÿjc Diet_Error_File
            cmp ecx,17
            jb Not_Compressed
            cmp W _CS[Diet_File_Header+6],ax
            jnz Not_Compressed
            shr eax,16
            cmp B _CS[Diet_File_Header+8],al
            je Unpack_Diet_144


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Not_Compressed:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            cmp _ES[Linked],Off
            je @@Ok1
            mov ax,4200h                    ; Accepter des fichiers non
                                            ; compresser et Linked
            mov ecx,_ES[Pos_Tmp]
            mov edx,ecx
            shr ecx,16
            _int 21h
            mov edx,_ES[Size_Tmp]
            mov _ES[File_Size],edx
            jmp @@Ok2
@@Ok1:
            mov ax,4202h            ; Get length
            xor ecx,ecx
            xor edx,edx
            _int 21h
            jc Diet_Error_File
            shl edx,16
            mov dx,ax
            mov _ES[File_Size],edx
            push edx

            mov ax,4200h
            xor edx,edx
            _int 21h

            pop edx
@@Ok2:
            mov ecx,edx

            mov ah,Allocate_Memory_Handle
            cmp _CS[Use_Handle],Off
            jne @@Ok3
            mov ah,Allocate_Memory
@@Ok3:
            Int_EOS
            jc Diet_Error_Mem
            mov _ES[Diet_True_Buffer],eax
            mov _ES[Diet_File_Buffer],edx
            mov _ES[Diet_Handle_Mem],edi
            PushDS
            LoadDS
           ÿmov ah,3Fh
           ÿ_int 21h                 ; Read File header
            PopDS
           ÿjc Diet_Error_File

            mov ah,3Eh
           ÿ_int 21h                 ; Close the file

            mov eax,_ES[Diet_File_Buffer]
            clc
            ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Diet_Error_Mem:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

           ÿmov ebx,_ES[Diet_Handle]
            mov ah,3Eh
           ÿ_int 21h                 ; Close the file
            mov eax,2
            stc
            ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Diet_Error_File:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

           ÿmov ebx,_ES[Diet_Handle]
            mov ah,3Eh
           ÿ_int 21h                 ; Close the file
            mov eax,1
            stc
            ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Unpack_Diet_144:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            PushES
            PopDS                          ; DS= Data32_Sel
            movzx edx,byte ptr Diet_File_Header+0eh
            shr edx,2
            shl edx,16
            mov dx,word ptr Diet_File_Header+0fh
            mov [File_Size],edx
            mov [From_Memory],Off
            mov ah,Allocate_Memory_Handle
            cmp _CS[Use_Handle],Off
            jne @@Ok1
            mov ah,Allocate_Memory
@@Ok1:
            Int_EOS                 ; EDI=buffer destination
            jc Diet_Error_Mem       ; Size=Taille du fichier non compress‚
            mov Diet_True_Buffer,eax
            mov Diet_File_Buffer,edx
            mov Diet_Handle_Mem,edi

            mov ecx,Diet_Buffer_Size
            add ecx,10h
            mov Diet_Buffer_Size10,ecx

            mov edx,ecx
                        mov ah,Allocate_Memory_Handle
                        cmp _CS[Use_Handle],Off
                        jne @@Ok2
                        mov ah,Allocate_Memory
            @@Ok2:
            Int_EOS                 ; ESI=buffer d'origine
            jc Diet_Error_Mem       ; Size=Variable
            mov Diet_Buffer,edx
                        mov Diet_Handle_2,edi
            mov esi,edx

            mov ecx,Diet_Buffer_Size10
            mov ebx,Diet_Handle
           ÿmov ah,3Fh
           ÿ_int 21h                 ; Read File
           ÿjc Diet_Error_File

            mov edi,Diet_File_Buffer
            call UnLZ

                        mov ah,DeAllocate_Memory_Handle
                        cmp _CS[Use_Handle],Off
                        jne @@Ok3
                        mov ah,DeAllocate_Memory
            @@Ok3:
                        mov edi,Diet_Handle_2
            Int_EOS

           ÿmov ebx,Diet_Handle
            mov ah,3Eh
           ÿ_int 21h                 ; Close the file

            mov eax,Diet_File_Buffer
            clc
            ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Read_LZ:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

            pushad
            PushES
            PushDS
            PopES
            mov ecx,_CS[Diet_Buffer_Size10]

            push esi
            sub esi,_CS[Diet_Buffer]
            sub ecx,esi
            pop esi

            push ecx

            mov edi,_CS[Diet_Buffer]
            cld
            rep movsb

            mov edx,edi
            pop edi
            PopES
            mov ecx,_CS[Diet_Buffer_Size10]
            sub ecx,edi
            cmp [From_Memory],On
            je @@From_Memory
            mov ebx,_CS[Diet_Handle]
           ÿmov ah,3Fh
           ÿ_int 21h                 ; Read File
            popad
           ÿjc Diet_Error_File

            mov esi,_CS[Diet_Buffer]
            ret

@@From_Memory:
            PushDS
            lds esi,F [Source]
            mov edi,edx
            rep movsb
            PopDS
            mov D [Source],esi
            popad
            mov esi,_CS[Diet_Buffer]
            ret



;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
UnLZ:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

            lodsw
            mov bp,ax
            mov dl,10h
            xor ecx,ecx
            xor ebx,ebx

loc_27:
            next_byte
            jnc loc_30
            movsb
            jmp loc_27
loc_30:
            next_byte
            lodsb
            mov ebx,-1
            mov bl,al
            jc loc_44
_loc_30a:
            next_byte
            jc loc_37
            cmp bh,bl
            jne loc_41
_loc_30b:
            next_byte
            jc loc_27
            ret
loc_37:
            mov cl,3

locloop_38:
            next_byte
            rcl bh,1
            loop locloop_38

            dec bh
loc_41:
            mov cl,2

locloop_42:
            mov al,byte ptr _ES[ebx+edi]
            stosb
            loop locloop_42
            jmp loc_27
loc_44:
            next_byte
            rcl bh,1
_loc_44:
            next_byte
            jc loc_55
            mov dh,2
            mov cl,3

locloop_49:
            next_byte
            jc loc_54
_locloop_49:
            next_byte
            rcl bh,1
            shl dh,1
            loop locloop_49

loc_54:
            sub bh,dh
loc_55:
            mov dh,2
            mov cl,4

locloop_56:
            inc dh
            next_byte
            jc loc_63
            loop locloop_56
_loc_56b:
            next_byte
            jnc loc_64
            inc dh
_loc_56c:
            next_byte
            jnc loc_63
            inc dh
loc_63:
            mov cl,dh
            jmp locloop_42
loc_64:
            next_byte
            jc loc_70
            mov cl,3
            mov dh,0

locloop_67:
            next_byte
            rcl dh,1
            loop locloop_67

            add dh,9
            jmp loc_63
loc_70:
            lodsb
            mov cl,al
            add cx,11h
            jmp locloop_42

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Unpack_From_Memory_EOS:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ESI buffer Origin
; Return :
; EDI buffer Destination
;
            push ebx
            push edx
            push ebp
            PushDS
            PushES
            call Unpack_From_Memory2
            jc @@Ok1
            mov eax,Diet_File_Buffer
            mov ecx,File_Size
            mov esi,Diet_True_Buffer
            mov edi,Diet_Handle_Mem
            PopES
            PopDS
            pop ebp
            pop edx
            pop ebx
            Clear_Carry
            mIRETD
@@Ok1:
            PopES
            PopDS
            pop ebp
            pop edx
            pop ebx
            Set_Carry
            mIRETD


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Unpack_From_Memory2:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            mov eax,ds
            LoadDS
            mov D [Source],esi
            mov W [Source+4],ax
            cld
            PushDS
            PopES
           ÿmov ecx,17
            lds esi,[Source]
           ÿmov edi,Offset Diet_File_Header
            rep movsb
            PushES
            PopDS                  ; DS=Data32_Sel
            mov D [Source],esi
            mov eax,'zld'
            cmp W _CS[Diet_File_Header+6],ax
            jnz @@Error
            shr eax,16
            cmp B _CS[Diet_File_Header+8],al
            jnz @@Error
            movzx edx,byte ptr Diet_File_Header+0eh
            shr edx,2
            shl edx,16
            mov dx,word ptr Diet_File_Header+0fh
            mov [File_Size],edx
            mov [From_Memory],On
            mov ah,Allocate_Memory_Handle
            Int_EOS                 ; EDI=buffer destination
            jc Diet_Error_Mem       ; Size=Taille du fichier non compress‚
            mov Diet_True_Buffer,eax
            mov Diet_File_Buffer,edx
            mov Diet_Handle_Mem,edi

            mov ecx,Diet_Buffer_Size
            add ecx,10h
            mov Diet_Buffer_Size10,ecx

            mov edx,ecx
            mov ah,Allocate_Memory
            Int_EOS                 ; ESI=buffer d'origine
            jc Diet_Error_Mem       ; Size=Variable
            mov Diet_Buffer,edx
            mov esi,edx

            pushad
            mov edi,edx
            mov ecx,Diet_Buffer_Size10
            PushDS
            lds esi,F [Source]
            mov edi,edx
            rep movsb
            PopDS
            mov D [Source],esi
            popad

            mov edi,Diet_File_Buffer
            call UnLZ

            mov ah,DeAllocate_Memory
            Int_EOS

            clc
            ret
@@Error:
            stc
            ret