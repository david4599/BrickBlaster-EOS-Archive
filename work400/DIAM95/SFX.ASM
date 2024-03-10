
Play_Sample_Diamond:
            movzx ebx,bx
            movzx edx,dx
            cmp edx,[Number_Channel_Sfx]
            jae @@Ok100
            mov edi,O Channel1
            add edx,[Number_Channel]
            imul edx,Size Channel1
            add edi,edx
            dec ebx
            jl @@Ok100
            shl ebx,2
            mov [edi.MS.Current_Sample],ebx
            mov eax,[List_Addr_Sample+ebx]
            mov [edi.MS.New_Sample],On
            mov [edi.MS.Current_Position],eax
            mov [edi.MS.Current_Low_Position],0
            mov eax,[List_FineTune_Sample+ebx]
            mov [edi.MS.FineTune],ax
            mov eax,[List_Volume_Sample+ebx]
            mov [edi.MS.Sample_Volume],al
            movzx ebx,cx
            mov [edi.MS.Frequence],bx
            push edi
            mov edi,[Addr_Current_Drivers]
            call [edi.Dev_Func.Get_Frequence_]
            pop edi
            mov [edi.MS.Compt_Frequence],eax
@@Ok100:
            ret


Play_Sample_Sfx:
            push W [Master_Volume]
            mov al,[Master_Volume_Sfx]
            mov [Master_Volume],al
            mov edi,O Channel1
            mov eax,[Number_Channel]
            imul eax,Size Channel1
            add edi,eax
            mov ecx,[Number_Channel_Sfx]
            test ecx,ecx
            je @@Ok100
@@Ok10:
            push ecx
            push esi
            push edi
            mov esi,[Addr_Current_Drivers]
            call [esi.Dev_Func.Play_Voice_]
            pop edi
            pop esi
            pop ecx
            add esi,4
            add edi,Size Channel1
            dec cl
            jne @@Ok10
@@Ok100:
            pop W [Master_Volume]
            ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Load External Sample
; Must be a Iff File
;
;   Enter   :
;           ESI = Linear Address Sample
;
;   Return  :
;           Carry Off
;           EAX = Sample Number
;
;           Carry On
;           Error
;           EAX = 0
;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
_Load_External_Sample:
Load_External_Sample:
            arg addr:dword
            push ebp
            mov ebp,esp
            push ebx
            push ecx
            push edx
            push esi
            push edi
            mov esi,[addr]
            cmp D [esi],'MROF'
            jne @@Error
            mov ecx,[esi+4]
            xchg cl,ch
            rol ecx,16
            xchg cl,ch
            cmp D [esi+8],'XVS8'
            jne @@Error
            sub ecx,12
            add esi,12
            mov eax,'RDHV'
            call GetIffChunk
            jc @@Error
            mov ebx,128
@@Loop:
            cmp [List_Addr_Sample+4*ebx],0
            je @@Found_Free_Sample
            inc ebx
            cmp ebx,256
            jne @@Loop
@@Found_Free_Sample:
            mov eax,[esi+edi+16]
            xchg al,ah
            rol eax,16
            xchg al,ah
            shr eax,8+2
            mov [List_Volume_Sample+4*ebx],eax
            mov eax,'YDOB'
            call GetIffChunk
            jc @@Error
            mov [List_Lenght_Sample+4*ebx],edx
            add edi,esi
            xchg esi,edi
            sub edi,12
            mov [List_Addr_Sample+4*ebx],edi
            add [List_Lenght_Sample+4*ebx],edi
            mov ecx,edx
            rep movsb
            mov ecx,Size_Mix_Plus
            xor eax,eax
            rep stosb
            mov eax,ebx
            pop edi
            pop esi
            pop edx
            pop ecx
            pop ebx
            pop ebp
            inc eax
            clc
            ret

@@Error:
            pop edi
            pop esi
            pop edx
            pop ecx
            pop ebx
            pop ebp
            xor eax,eax
            stc
            ret

; Enter : ESI=Address of the Iff first chunk
;         EAX=Chunk name
;
; Exit:
;         clc
;         EDI=Offset to data in chunk
;         EDX=Size of chunk
;
;
;
GetIffChunk:
            xor edi,edi
@@Search:
            cmp [esi+edi],eax
            je @@Found
            mov edx,[esi+edi+4]
            xchg dl,dh
            rol edx,16
            xchg dl,dh
            lea edi,[edi+edx+8]
            cmp edi,ecx
            jae @@Error
            jmp @@Search
@@Found:
            mov edx,[esi+edi+4]
            xchg dl,dh
            rol edx,16
            xchg dl,dh
            add edi,8
            clc
            ret
@@Error:
            stc
            ret