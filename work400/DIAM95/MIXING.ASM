;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Software Mixing driver                                               Ver 1.00
; copyright (c) 1996 Eclipse
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
.data
Size_Mix_Plus       = 32
Taille_Loop2        = 4
Taille_Loop         = 1 shl Taille_Loop2
Taille_Boucle       = 16


Call_Mixing         dd 0
Tbl_Addr_Mix        label dword
                    ii=Taille_Loop*Taille_Boucle
                     rept Taille_Loop
                    dd ii
                     ii=ii-Taille_Boucle
                     endm

Tbl_Decal_Mix       label dword
                    ii=Taille_Loop*8
                     rept Taille_Loop
                    dd -ii
                     ii=ii-8                ; 8 Pour Stereo
                     endm

Count       dd 16c8000h                     ; this value is divided by the NOTE
                                            ; FREQUENCY

Loop_Ecx    dd 0

.code
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Make Mixing Table Volume
;   Enter   :
;
;   Return  :
;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Make_Volume_Table:
            mov edx,[_Addr_Volume_Table]
            test edx,0fh
            je @@Ok00
            and edx,Not 15
            add edx,16
@@Ok00:
            mov [_Addr_Volume_Table],edx
            add edx,65*255*4
            mov [_Addr_Buffer_Mixing],edx
            mov edi,edx
            xor eax,eax
            mov ecx,16384
            rep stosd
@@Ok01:
            mov edi,[_Addr_Volume_Table]
            mov ebp,[Number_Channel]
            add ebp,[Number_Channel_Sfx]
            cmp [_Mixing_Stereo],On
            jne @@Ok0
            shr ebp,1                       ; Stereo /2
            adc ebp,0
;            cmp [_Mixing_Real_Stereo],On
;            jne @@Ok0
;            mov ebp,[Number_Channel]
;            mov eax,ebp
;            shr eax,1
;            add ebp,eax
;            shr ebp,1
;            adc ebp,0
@@Ok0:
            xor esi,esi
            mov cl,64
@@Ok1:
            xor eax,eax
            push ecx
            mov eax,esi
            mov edx,100 shl 8
            mul edx
	mov ecx,100
	div ecx
	xor edx,edx
	div ebp
	mov ecx,eax
	xor bl,bl
@@Ok2:
	movsx eax,bl
	imul ecx
            shr eax,8
;            cmp [_Mixing_Real_Stereo],On
;            jne @@Ok3
;            shr eax,2
;@@Ok3:
            stosd
            inc bl
            jne @@Ok2
            pop ecx
            add esi,4
            dec cl
            jne @@Ok1
            ret

Init_Mixing_Data:
            mov cl,Taille_Loop
            mov eax,[_Addr_Volume_Table]
            xor edi,edi
@@Ok10:
            mov D [edi+Mix_Sample_Loop+7],eax
            mov D [edi+Mix_Sample_No_Loop+7],eax
            add edi,Taille_Boucle
            dec cl
            jne @@Ok10
            mov eax,[_Replay_Rate]
            xor edx,edx
            mov ecx,eax
            mov eax,Const_Mod
            shld edx,eax,16
            shl eax,16
            div ecx
	mov [Count],eax         ;save COUNT value
            ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Get Frequence Mixing
;   Enter   :
;           EBX = Frequence
;
;   Return  :
;           EAX = Sound Card internal frequence
;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Get_Frequence_Mixing:
            and ebx,0fffh
            je @@Ok1
            push edx
            mov eax,[Count]
	xor edx,edx
	div ebx
            pop edx
@@Ok1:
            ret


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Set BPM Mixing
;   Enter   :
;           Al = New BPM
;
;   Return  :
;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Set_BPM_Mixing:
            mov ebx,[_Replay_Rate]
            lea ebx,[ebx+4*ebx]
            add eax,eax                     ; Calcule La nouvelle Taille Du Buffer
            xor edx,edx
            xchg ebx,eax
            div ebx
            and al,Not 3
;            add eax,4
            mov [_Mixing_Size_Buffer],eax
            cmp [_Mixing_Stereo],On
            jne @@Ok1
            add eax,eax
@@Ok1:
            cmp [_Mixing_16],On
            jne @@Ok2
            add eax,eax
@@Ok2:
            mov [_Mixing_Size_Buffer_Full],eax
            ret


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Load Sample
;   Enter   :
;           ESI = Linear Address of Sample
;           ECX = Size of Sample
;
;   Return  :
;           Carry Off
;           EDI = Current Address Of Sample
;           EDX = Size of the Current Sample
;           Ok
;
;           Carry On
;           Not enough Memory
;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Load_Sample_Mixing:
            xor edx,edx
            push ecx
@@CopySample:
            mov al,[esi+edx]
            mov [edi+edx],al
            inc edx
            dec ecx
            jne @@CopySample
            mov eax,Size_Mix_Plus*256
            cmp [List_Loop_Ln_Sample+ebx],2
            jbe @@NoLoop
@@RepeatLoop:
            mov ecx,[List_Loop_St_Sample+ebx]
            mov ebp,ecx
            add ebp,[List_Loop_Ln_Sample+ebx]
@@CopyLoop:
            mov al,[esi+ecx]
            mov [edi+edx],al
            inc ecx
            inc edx
            cmp ecx,ebp
            jae @@RepeatLoop
            dec ah
            jne @@CopyLoop
            pop ecx
            add esi,ecx
            ret
@@NoLoop:
            mov [edi+edx],al
            inc edx
            dec ah
            jne @@NoLoop
            pop ecx
            add esi,ecx
            ret

;            cmp [List_Loop_Ln_Sample+ebx],2
;            jbe @@Ok0
;            add ebp,[List_Loop_St_Sample+ebx]
;            add ebp,[List_Loop_Ln_Sample+ebx]
;@@Ok0:
;            pushad                          ; Decale tout les samples
;            std
;            add ecx,esi
;            mov edi,[_Size_Module]
;            add edi,[_Addr_Module]
;            lea esi,[edi-Size_Mix_Plus]
;            sub ecx,edi
;            neg ecx
;            js @@Ok1
;;            shr ecx,2
;;            inc ecx
;;            rep movsd
;            rep movsb
;@@Ok1:
;            cld
;            popad
;            push esi
;            push ecx
;            cmp [List_Loop_Ln_Sample+ebx],2
;            jbe @@Ok10
;            mov edi,ebp
;            mov ecx,Size_Mix_Plus
;            add esi,[List_Loop_St_Sample+ebx]
;@@Ok2:
;            movsb
;            cmp esi,ebp
;            jb @@Ok3
;            sub esi,[List_Loop_Ln_Sample+ebx]
;@@Ok3:
;            dec ecx
;            jne @@Ok2
;            pop ecx
;            pop esi
;            mov edi,esi
;            add esi,ecx
;            add esi,Size_Mix_Plus
;            clc
;            ret
;@@Ok10:
;            lea edi,[esi+ecx]
;            mov ecx,Size_Mix_Plus/4
;            xor eax,eax
;            rep stosd                       ; On met des blancs de securite
;            pop ecx
;            pop esi
;            mov edi,esi
;            add esi,ecx
;            add esi,Size_Mix_Plus
;            clc
;            ret

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Clear Memory
;   Enter   :
;
;   Return  :
;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Clear_Memory_Mixing:
            ret


;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; a priori windows 95 n'accepte pas de faire de code automodifie
; passage du code and data


;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Mix The Current Channel Into A Buffer
;   Enter   :
;
;           EDI = Channel Structure
;           ECX = Size Of Mixing
;
;   Return  :
;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
_Channel_Mixing:
Channel_Mixing:
            mov ebx,[edi.MS.Current_Sample]
            cmp [List_Lenght_Sample+ebx],2
            jbe @@Ok100
            mov [edi.MS.New_Sample],Off
            mov esi,[edi.MS.Current_Position]
            cmp esi,[List_Lenght_Sample+ebx]
            ja @@Ok100
            mov [Panning_Left_Right],0
            cmp [_Mixing_Stereo],Off
            je @@Ok2
            cmp [edi.MS.Panning],64
            jbe @@Ok2
            mov [Panning_Left_Right],4
@@Ok2:
            mov edx,[List_Loop_Ln_Sample+ebx]
            mov eax,[List_Loop_St_Sample+ebx]
            add eax,edx
            mov ebp,O Mix_Sample_Loop
            cmp edx,2
            ja @@Ok10
            mov eax,[List_Lenght_Sample+ebx]
            mov ebp,O Mix_Sample_No_Loop
            mov [Size_Sample+2],eax
@@Ok10:
            mov [Call_Mixing],ebp
            mov [BufRep+2],edx
            mov [End_Loop_Sample+2],eax
            movzx eax,[edi.MS.Sample_Volume]
            mul [_Master_Volume]
            shl eax,2
            cmp ah,40h
            jb @@Ok21
            mov ah,3fh
@@Ok21:
            mov ebx,eax
            cmp [edi.MS.Mute],On
            jne @@Ok3
            xor ebx,ebx
@@Ok3:
            mov ecx,[edi.MS.Compt_Frequence]
            mov eax,[_Mixing_Size_Buffer]
            push edi
            push eax
                    mov ebp,[edi.MS.Current_Low_Position]
            and eax,Taille_Loop-1
                    mov edi,[Tbl_Decal_Mix+4*eax]
            mov eax,[Tbl_Addr_Mix+4*eax]
                    add edi,[_Addr_Buffer_Mixing]
            add [Call_Mixing],eax
                    mov edx,ecx
            pop eax
                    shl edx,16
            shr eax,Taille_Loop2
                    sar ecx,16
            inc eax

            db 81h,0c7h
Panning_Left_Right Label Dword
            dd 0
            mov [Loop_Ecx],eax
            call [Call_Mixing]
            pop edi
            mov [edi.MS.Current_Position],esi
            mov [edi.MS.Current_Low_Position],ebp
@@Ok100:
            ret








Align 4
Mix_Sample_Loop:
@@Ok1:
            ii=0
        rept Taille_Loop
            mov bl,[esi]
            add ebp,edx
            mov eax,[4*ebx+12345678h]
            adc esi,ecx
            db 01h,47h
            db ii
            ii=ii+8
        endm
Mix_Loop:
End_Loop_Sample Label Dword
            cmp esi,12345678h
            jb @@Ok2
BufRep label dword
            sub esi,12345678h
            jmp Mix_Loop
@@Ok2:
            add edi,Taille_Loop*8
            dec [Loop_Ecx]
            jne Mix_Sample_Loop
            ret

Align 4
Mix_Sample_No_Loop:
@@Ok1:
            ii=0
        rept Taille_Loop
            mov bl,[esi]
            add ebp,edx
            mov eax,[4*ebx+12345678h]
            adc esi,ecx
            db 01h,47h
            db ii
            ii=ii+8
        endm
Size_Sample Label Dword
            cmp esi,12345678h
            ja @@Ok2
            add edi,Taille_Loop*8
            dec [Loop_Ecx]
            jne Mix_Sample_No_Loop
@@Ok2:
            ret

End_Diamond_Autogen        label dword
_End_Diamond_Autogen        dd $-Channel_Mixing

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Transfert Buffer    Transfert Buffer to DMA Buffer
;   Enter   :
;
;           ECX = Size Of Mixing
;
;   Return  :
;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Align 4
_Buffer_To_DMA_Mixing:
Buffer_To_DMA_Mixing:
            mov esi,[_Addr_Buffer_Mixing]
            mov edi,[Linear_Addr_Dma1]
            mov ecx,[Size_Addr_Dma1]
            test edi,edi
            je @@Ok1
            call Transfert_Buffer
@@Ok1:
            mov edi,[Linear_Addr_Dma2]
            mov ecx,[Size_Addr_Dma2]
            test edi,edi
            je @@Ok2
            call Transfert_Buffer
@@Ok2:
            mov ecx,[_Mixing_Size_Buffer]
            mov edi,[_Addr_Buffer_Mixing]
            lea ecx,[ecx+ecx+4]
            xor eax,eax
            rep stosd
            ret


Transfert_Buffer:
            mov dl,cl
            cmp [_Mixing_16],On
            je @@Ok200
            mov ebp,80808080h
            cmp [_Mixing_Stereo],Off
            je @@Ok100
            cmp [_Mixing_Real_Stereo],On
            je Mixing_True_Stereo_8
            and dl,0fh
            je @@Ok1
            dec edi
@@Ok0:
            mov al,[esi+1]
            inc edi
            xor eax,ebp
            add esi,4
            mov [edi],al
            dec dl
            jne @@Ok0
            inc edi
@@Ok1:
            shr ecx,4
            je @@Ok5
Align 4
@@Ok2:
            push ecx
            mov al,[esi+8+1]
            mov bl,[esi+8+16+1]
            mov cl,[esi+8+32+1]
            mov dl,[esi+8+48+1]
            mov ah,[esi+12+1]
            mov bh,[esi+12+16+1]
            mov ch,[esi+12+32+1]
            shl eax,16
            mov dh,[esi+12+48+1]
            shl ebx,16
            mov al,[esi+1]
            shl ecx,16
            mov bl,[esi+16+1]
            shl edx,16
            mov cl,[esi+32+1]
            mov dl,[esi+48+1]
            mov ah,[esi+4+1]
            mov bh,[esi+4+16+1]
            mov ch,[esi+4+32+1]
            mov dh,[esi+4+48+1]
            xor eax,ebp
            xor ebx,ebp
            xor ecx,ebp
            xor edx,ebp
            mov [edi],eax
            mov [edi+4],ebx
            mov [edi+8],ecx
            mov [edi+12],edx
            add esi,32*2
            pop ecx
            add edi,16
            dec ecx
            jne @@Ok2
@@Ok5:
            ret

@@Ok100:
            and dl,0fh
            je @@Ok102
            dec edi
@@Ok101:
            mov al,[esi+1]
            inc edi
            xor eax,ebp
            add esi,8
            mov [edi],al
            dec dl
            jne @@Ok101
            inc edi
@@Ok102:
            shr ecx,4
            je @@Ok105
Align 4
@@Ok103:
            push ecx
            mov al,[esi+16+1]
            mov bl,[esi+16+32+1]
            mov cl,[esi+16+64+1]
            mov dl,[esi+16+96+1]
            mov ah,[esi+24+1]
            mov bh,[esi+24+32+1]
            mov ch,[esi+24+64+1]
            shl eax,16
            mov dh,[esi+24+96+1]
            shl ebx,16
            mov al,[esi+1]
            shl ecx,16
            mov bl,[esi+32+1]
            shl edx,16
            mov cl,[esi+64+1]
            mov dl,[esi+96+1]
            mov ah,[esi+8+1]
            mov bh,[esi+8+32+1]
            mov ch,[esi+8+64+1]
            mov dh,[esi+8+96+1]
            xor eax,ebp
            xor ebx,ebp
            xor ecx,ebp
            xor edx,ebp
            mov [edi],eax
            mov [edi+4],ebx
            mov [edi+8],ecx
            mov [edi+12],edx
            add esi,32*2*2                  ; Mono
            pop ecx
            add edi,16
            dec ecx
            jne @@Ok103
@@Ok105:
            ret

@@Ok200:
            cmp [_Mixing_Stereo],Off
            je @@Ok300
            cmp [_Mixing_Real_Stereo],On
            je Mixing_True_Stereo_16
            and dl,0fh
            je @@Ok202
            sub edi,2
@@Ok201:
            mov eax,[esi]
            add edi,2
            add esi,4
            mov [edi],eax
            dec dl
            jne @@Ok201
            add edi,2
@@Ok202:
            shr ecx,4
            je @@Ok205
Align 4
@@Ok203:
            mov eax,[esi+4]
            mov ebx,[esi+4+8]
            shl eax,16
            mov ebp,[esi+4+16]
            shl ebx,16
            mov edx,[esi+4+24]
            shl ebp,16
            add esi,16*2                       ; Mono
            mov ax,[esi-16*2]
            add edi,16
            shl edx,16
            dec ecx
            mov bx,[esi+8-16*2]
            mov [edi-16],eax
            mov bp,[esi+16-16*2]
            mov [edi+4-16],ebx
            mov dx,[esi+24-16*2]
            mov [edi+8-16],ebp
            mov [edi+12-16],edx
            jne @@Ok203
@@Ok205:
            ret

@@Ok300:
            and dl,0fh
            je @@Ok302
            sub edi,2
@@Ok301:
            mov eax,[esi]
            add edi,2
            add esi,8
            mov [edi],eax
            dec dl
            jne @@Ok301
            add edi,2
@@Ok302:
            shr ecx,4
            je @@Ok305
Align 4
@@Ok303:
            mov eax,[esi+8]
            mov ebx,[esi+8+16]
            shl eax,16
            mov ebp,[esi+8+32]
            shl ebx,16
            mov edx,[esi+8+48]
            shl ebp,16
            add esi,16*2*2                     ; Mono
            mov ax,[esi-16*2*2]
            add edi,16
            shl edx,16
            dec ecx
            mov bx,[esi+16-16*2*2]
            mov [edi-16],eax
            mov bp,[esi+32-16*2*2]
            mov [edi+4-16],ebx
            mov dx,[esi+48-16*2*2]
            mov [edi+8-16],ebp
            mov [edi+12-16],edx
            jne @@Ok303
@@Ok305:
            ret

Mixing_True_Stereo_8:
            shr ecx,2
            mov ebp,8000h
@@Ok200:
            mov eax,[esi]
            mov ebx,[esi+4]
            mov ebp,eax
            lea eax,[2*eax+eax]
            add eax,ebx
            lea ebx,[2*ebx+ebx]
            sar eax,2
            add ebx,ebp
            sar ebx,2
;            xor eax,ebp
;            xor ebx,ebp
            mov [edi],ah
            mov [edi+1],bh
            add esi,8
            add edi,2
            dec ecx
            jne @@Ok200
            ret


Mixing_True_Stereo_16:
            shr ecx,2
@@Ok200:
            mov eax,[esi]
            mov ebx,[esi+4]
            mov ebp,eax
;            mov edx,ebx
            lea eax,[2*eax+eax]
            add eax,ebx
            lea ebx,[2*ebx+ebx]
            sar eax,2
            add ebx,ebp
            sar ebx,2
            add esi,8
            mov [edi],ax
            mov [edi+2],bx
            add edi,4
            dec ecx
            jne @@Ok200
            ret