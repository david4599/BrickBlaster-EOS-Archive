;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Mod Player                                                           Ver 1.00
; copyright (c) 1996 Eclipse
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Support M.K. M!K! FLT4 FLT8 xCHN xxCH
.data

List_Functions_Mod   Label Dword
                    dd O Detect_Mod
                    dd O Next_Tick_Mod
                    dd 0


List_Normal_Func_Mod Label Dword
                    dd O Arpeggio           ; 0
                    dd O Porta_             ; 1
                    dd O Porta_             ; 2
                    dd O Porta_To_          ; 3
                    dd O Vibrato_           ; 4
                    dd O Volume_Slide2      ; 5
                    dd O Volume_Slide2      ; 6
                    dd O Tremelo_           ; 7
                    dd O Set_Panning        ; 8
                    dd O Sample_Offset      ; 9
                    dd O Volume_Slide       ; A
                    dd O Position_Jump      ; B
                    dd O Set_Volume_Effect  ; C
                    dd O Pattern_Break      ; D
                    dd O Extended_Func_Mod  ; E
                    dd O Set_Speed          ; F


List_Extended_Func_Mod  Label Dword
                    dd O Empty_Effect       ; 0 Effect etendu
                    dd O Fine_Porta_Up      ; 1
                    dd O Fine_Porta_Down    ; 2
                    dd O Empty_Effect       ; 3
                    dd O Empty_Effect       ; 4
                    dd O Set_Fine_Tune      ; 5
                    dd O Set_Jump           ; 6
                    dd O Empty_Effect       ; 7
                    dd O Empty_Effect       ; 8
                    dd O Retrig_Note_       ; 9
                    dd O Fine_Volume_Slide_Up       ; A
                    dd O Fine_Volume_Slide_Down     ; B
                    dd O Note_Cut           ; C
                    dd O Empty_Effect       ; D
                    dd O Pattern_Delay_     ; E
                    dd O Empty_Effect       ; F

List_Normal_Do_Func_Mod Label Dword
                    dd O Do_Arpeggio        ; 0
                    dd O Do_Porta_Up        ; 1
                    dd O Do_Porta_Down      ; 2
                    dd O Do_Porta_To        ; 3
                    dd O Do_Vibrato         ; 4
                    dd O Do_Porta_To_Volume_Slide   ; 5
                    dd O Do_Vibrato_Volume_Slide    ; 6
                    dd O Do_Tremelo         ; 7
                    dd O Empty_Effect       ; 8
                    dd O Empty_Effect       ; 9
                    dd O Do_Volume_Slide    ; A
                    dd O Empty_Effect       ; B
                    dd O Empty_Effect       ; C
                    dd O Empty_Effect       ; D
                    dd O Empty_Effect       ; E
                    dd O Empty_Effect       ; F


List_Extended_Do_Func_Mod  Label Dword
                    dd O Empty_Effect       ; 0 Effect etendu
                    dd O Empty_Effect       ; 1
                    dd O Empty_Effect       ; 2
                    dd O Empty_Effect       ; 3
                    dd O Empty_Effect       ; 4
                    dd O Empty_Effect       ; 5
                    dd O Empty_Effect       ; 6
                    dd O Empty_Effect       ; 7
                    dd O Empty_Effect       ; 8
                    dd O Do_Retrig_Note     ; 9
                    dd O Empty_Effect       ; A
                    dd O Empty_Effect       ; B
                    dd O Do_Note_Cut        ; C
                    dd O Do_Delay_Note      ; D
                    dd O Empty_Effect       ; E
                    dd O Empty_Effect       ; F

.code
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Detect Mod
;   Enter   :
;           ESI = Linear address of the module in memory
;
;   Return  :
;           Carry Off
;           Module found
;
;           Carry On
;           Not a module
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Detect_Mod:
            xor ebx,ebx
            mov eax,[esi+1080]              ; Set to Magic header
            cmp eax,'.K.M'
            jne @@Ok1
            mov bl,4
            jmp @@Ok100
@@Ok1:
            cmp eax,'!K!M'
            jne @@Ok2
            mov bl,4
            jmp @@Ok100
@@Ok2:
            cmp eax,'4TLF'
            jne @@Ok3
            mov bl,4
            jmp @@Ok100
@@Ok3:
            cmp eax,'ATCO'
            jne @@Ok4
            mov bl,4
            jmp @@Ok100
@@Ok4:
            cmp eax,'8TLF'
            jne @@Ok5
            mov bl,8
            jmp @@Ok100
@@Ok5:
            mov edx,eax
            and edx,'ZDT'
            cmp edx,'ZDT'
            jne @@Ok6
            shr eax,16+8
            sub al,'0'
            mov bl,al
            jmp @@Ok100
@@Ok6:
            mov edx,eax
            and edx,'NHC'*256
            cmp edx,'NHC'*256
            jne @@Ok7
            sub al,'0'
            mov bl,al
            jmp @@Ok100
@@Ok7:
            mov edx,eax
            and edx,'HC'*256*256
            cmp edx,'HC'*256*256
            jne @@Ok8
            sub ax,'00'
            mov bl,ah
            imul ax,10
            add bl,al
            jmp @@Ok100
@@Ok8:
            xor eax,eax
            xor ebx,ebx
            stc
            ret

@@Ok100:
            mov [Number_Channel],ebx
            push ebx
            push esi
            call Init_Sample_Mod
            call Load_Sample_Mod
            call Init_Mod
            pop esi
            pop ebx
            clc
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Init Sample mod
;   Enter   :
;           ESI = Linear address of the module in memory
;
;   Return  :
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Init_Sample_Mod:
            push esi
            xor eax,eax
            xor ebx,ebx
            xor ecx,ecx
            xor edx,edx
            xor edi,edi
            add esi,20+22                   ; Skip Song Name
@@Ok1:
            mov ax,[esi]                    ; Read sample Lenght
            mov bx,[esi+2]                  ; Read Volume and FineTune
            mov cx,[esi+4]                  ; Read Sample Loop lenght
            mov dx,[esi+6]                  ; Read Sample Loop Start
            xchg al,ah                      ; do Amiga swap
            xchg cl,ch                      ; do Amiga swap
            xchg dl,dh                      ; do Amiga swap
            add ax,ax                       ; Lenght*2
            add cx,cx                       ; Loop Lenght*2
            add dx,dx                       ; Loop start*2
            cmp eax,2                       ; Sample Size >2
            jbe @@Ok5                       ; No Skip Sample
            mov B [List_Volume_Sample+edi],bh
            and ebx,0fh
            imul ebx,86*2                   ;62*2
;            shl ebx,4+16+8                  ; Sign FineTune
;            sar ebx,4+16+8
            mov [List_FineTune_Sample+edi],ebx
;            mov ebx,edx
;            add ebx,ecx
;            cmp ebx,eax
;            jbe @@Ok2
;            mov edx,eax
;            sub edx,ecx
;@@Ok2:
            mov [List_Lenght_Sample+edi],eax
            mov [List_Loop_St_Sample+edi],ecx
            mov [List_Loop_Ln_Sample+edi],edx
@@Ok5:
            add edi,4
            add esi,30
            cmp edi,4*31
            jne @@Ok1
            pop esi
            push esi
            mov al,[esi+950]
            mov [_Song_Lenght   ],al
            mov al,[esi+948]
            mov [_Song_Restart],al
            mov ecx,128-1
            xor eax,eax
            add esi,952
            mov edi,O _Pattern_Order
            mov al,[esi]
@@Ok10:
            cmp al,[esi]
            jae @@Ok11
            mov al,[esi]
@@Ok11:
            movsb
            dec ecx
            jne @@Ok10
            mov [Number_Pattern],eax
            pop esi
            push esi                        ; On efface le Header du Mod
            mov edi,esi                     ; Qui ne sert plus a rien et
            add esi,1084                    ; permet de creer un debordement
;            mov ecx,[_Size_Module]           ; pour les samples pour la SB

            mov eax,[Number_Pattern]
            mov ecx,[Number_Channel]        ; eax [Number_Patterm]
            inc eax                         ; Plus 1 Begin To 0
            shl ecx,8
            imul ecx,eax
;            sub ecx,1084
            push ecx
            rep movsb
            pop ecx
            pop esi

            shr ecx,2                       ; Divise par 4 Dword
            push esi
@@Ok12:                                     ;  Met la pattern sous la forme de
            mov ax,[esi]                    ;
            ror ax,4                        ;  DWORD
            shl eax,16                      ; ÚÄÄÄÄÂÄÄÂÄÄÂÄÄÂÄÄÄÄÄ¿
            mov ax,[esi+2]                  ; ³ 00 ³ 0³0 ³ 0³0 00 ³
            rol ax,8                        ; ÃÄÄÄÄÅÄÄÁÄÄÅÄÄÅÄÄÄÄÄ´
            call Convert_Note               ; ³    ³  ³  ³  ³     ³
            mov [esi],eax                   ; ³  Note ³ No S³Effect
            add esi,4                       ; ³    ³  ³  ³  ³     ³
            dec ecx                         ; ÀÄÄÄÄÁÄÄÁÄÄÁÄÄÁÄÄÄÄÄÙ
            jne @@Ok12
            pop esi
            ret

Convert_Note:
            mov ebx,eax
            shr ebx,5*4
            call Search_Freq
            ror eax,5*4
            and eax,Not 0fffh
            or eax,ebx
            rol eax,5*4
            ret




;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Load Sample mod
;   Enter   :
;           ESI = Linear address of the module in memory
;
;   Return  :
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Load_Sample_Mod:
            mov edi,[_Addr_Module]
            mov eax,[Number_Pattern]
            mov ecx,[Number_Channel]        ; eax [Number_Patterm]
            inc eax                         ; Plus 1 Begin To 0
            shl ecx,8
            imul ecx,eax
            add edi,ecx
            lea esi,[edi+1084]
            xor ebx,ebx
@@Ok3:
            cmp [List_Lenght_Sample+ebx],2
            jbe @@Ok5
            mov ecx,[List_Lenght_Sample+ebx]
            mov eax,[Addr_Current_Drivers]
            call [eax.Dev_Func.Load_Sample_]
            cmp [List_Loop_Ln_Sample+ebx],2
            jbe @@Ok4
            mov eax,[List_Loop_St_Sample+ebx]
            add eax,[List_Loop_Ln_Sample+ebx]
            mov [List_Lenght_Sample+ebx],eax
@@Ok4:
            mov [List_Addr_Sample+ebx],edi
            add [List_Loop_St_Sample+ebx],edi
            add [List_Lenght_Sample+ebx],edi
            add edi,edx
@@Ok5:
            add ebx,4
            cmp ebx,4*31
            jne @@Ok3
            ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Init mod
;   Enter   :
;
;   Return  :
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Init_Mod:
            mov [_Current_BPM],125
            mov [_Current_Speed],6
            mov [Compt_Speed],6
            mov [_Current_Note],0
            mov [Pattern_Delay],0
            mov [Next_Current_Note],0
            mov [Do_Break],Off
            mov [_Index_Pattern_Order],0
            movzx ebx,[_Pattern_Order]
            mov [_Current_Pattern],bl
            movzx eax,[_Current_BPM]
            mov edi,[Addr_Current_Drivers]
            call [edi.Dev_Func.Set_BPM_]
            xor eax,eax
            mov ecx,[Number_Channel]
            add ecx,[Number_Channel_Sfx]
            mov esi,O Channel1
@@Ok5:
            mov [esi.MS.Voice],al
            mov [esi.MS.Jump_0e6],0
            mov ah,al
            xor ch,ch
            mov [esi.MS.Last_Effect],O Empty_Effect
            mov [esi.MS.Addr_Read_Again],O Do_Fonc_Delay
            mov [esi.MS.Current_Sample],(Max_Sample-1)*4
            and ah,3
            mov [esi.MS.Mute],Off
            je @@Ok6
            sub ah,3
            je @@Ok6
            mov ch,80h
@@Ok6:
            mov [esi.MS.Panning],ch
            add esi,Size Channel1
            inc al
            dec cl
            jne @@Ok5
            ;mov [Channel1.MS.Mute],On
            ;mov [Channel2.MS.Mute],On
            ;mov [Channel3.MS.Mute],On
            ;mov [Channel4.MS.Mute],On
            ret





;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Next Tick
;   Enter   :
;
;   Return  :
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Next_Tick_Mod:
            cmp [_Module_Playing],On
            jne @@Ok100
            dec [Compt_Speed]
            jne @@Ok1
            mov al,[_Current_Speed]
            test al,al
            je @@Ok1
            mov [Compt_Speed],al
            call General_Pattern_Mod
;            mov edi,[Addr_Current_Drivers]
;            call [edi.Dev_Func.Mix_Data_]
            ret
@@Ok1:
            call Do_Effect_Mod
@@Ok100:
;            mov edi,[Addr_Current_Drivers]
;            call [edi.Dev_Func.Mix_Data_]
            ret



;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;General Pattern
;   Enter   :
;
;   Return  :
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
General_Pattern_Mod:
            mov ecx,[Number_Channel]
            mov edi,O Channel1
@@Ok1:
            cmp [edi.MS.Flags_0e6],On
            jne @@Ok2
            cmp [edi.MS.Compt_jump_0e6],0
            je @@Ok2
            mov [edi.MS.Flags_0e6],Off
            mov al,[edi.MS.Jump_0e6]
            mov [_Current_Note],al
@@Ok2:
            add edi,Size Channel1
            dec cl
            jne @@Ok1
            cmp [Pattern_Delay],0
            jne @@Ok100
            cmp [Do_Break],On
            jne @@Ok3
            mov [Do_Break],Off
            jmp @@Ok4
@@Ok3:
            cmp [_Current_Note],63
            jbe @@Ok7
@@Ok4:
            mov al,[Next_Current_Note]
            mov [_Current_Note],al
            mov [Next_Current_Note],0
            inc [_Index_Pattern_Order]
            mov ecx,[Number_Channel]
            mov esi,O Channel1
@@Ok5:
            mov [esi.MS.Jump_0e6],0
            add esi,Size Channel1
            dec cl
            jne @@Ok5
            mov ebx,[_Index_Pattern_Order]
            cmp bl,[_Song_Lenght   ]
            jb @@Ok6
            mov bl,[_Song_Restart]
            mov [_Index_Pattern_Order],ebx
@@Ok6:
            movzx ebx,[_Pattern_Order+ebx]
            mov [_Current_Pattern],bl
@@Ok7:
            movzx ebx,[_Current_Pattern]
            mov eax,[Number_Channel]
            shl eax,8
            imul eax,ebx
            mov bl,[_Current_Note]
            shl ebx,2
            imul ebx,[Number_Channel]
            add eax,ebx
            mov esi,[_Addr_Module]
            add esi,eax                     ; ESI = Address of Current Pattern
            mov ecx,[Number_Channel]
            mov edi,O Channel1
@@Ok10:
            push ecx
            push esi
            push edi
            call Read_Channel
            mov esi,[Addr_Current_Drivers]
            call [esi.Dev_Func.Play_Voice_]
            pop edi
            pop esi
            pop ecx
            add esi,4
            add edi,Size Channel1
            dec cl
            jne @@Ok10
            inc [_Current_Note]
            ret
@@Ok100:
            dec [Pattern_Delay]
            ret





Read_Channel:
            mov edx,[esi]                   ; Read Current Dword
            mov cx,dx
            and cx,0fffh
            rol cx,8
            mov ebx,edx
            shr ebx,12
            and ebx,0ffh

            mov eax,ecx
            and ax,0f00fh
            cmp ax,0d00eh
            jne No_Fonc_Delay
            mov eax,ecx
            and ah,0fh
            je No_Fonc_Delay
            mov [edi.MS.Delay_Note],ah
            mov [edi.MS.Delay_Note_Offset],esi
            mov [edi.MS.Last_Effect],O Do_Delay_Note
            ret
Do_Fonc_Delay:
            mov esi,[edi.MS.Delay_Note_Offset]
            mov edx,[esi]                   ; Read Current Dword
            mov cx,dx
            and cx,0fffh
            rol cx,8
            mov ebx,edx
            shr ebx,12
            and ebx,0ffh

No_Fonc_Delay:
            shr edx,20
            cmp al,03h
            je Fonc_03_05
            cmp al,05h
            jne No_Fonc_03_05
Fonc_03_05:
            cmp [edi.MS.Frequence],0
            je NoNewNote
            test edx,edx
            je @@Ok0
            push ebx
            mov ebx,edx
            call calc_freq
            mov [edi.MS.Porta_Freq],bx
            pop ebx
@@Ok0:
            dec ebx
            jl NoNewNote
            shl ebx,2
            cmp ebx,[edi.MS.Current_Sample]
            je @@Ok2
            mov [edi.MS.Current_Sample],ebx
            mov eax,[List_Addr_Sample+ebx]
            mov [edi.MS.New_Sample],On
            mov [edi.MS.Current_Position],eax
            mov [edi.MS.Current_Low_Position],0
@@Ok2:
            mov eax,[List_FineTune_Sample+ebx]
            mov [edi.MS.FineTune],ax
            mov eax,[List_Volume_Sample+ebx]
            mov [edi.MS.Sample_Volume],al
            mov [edi.MS.Base_Sample_Volume],al
            jmp NoNewNote
;            dec ebx
;            jl NoNewNote
;            shl ebx,2
;            mov [edi.MS.Current_Sample],ebx
;            mov ebx,[edi.MS.Current_Sample]
;            mov eax,[List_FineTune_Sample+ebx]
;            mov [edi.MS.FineTune],ax
;            mov eax,[List_Volume_Sample+ebx]
;            mov [edi.MS.Sample_volume],al
;            mov eax,[List_Addr_Sample+ebx]
;            mov [edi.MS.New_Sample],On
;            mov [edi.MS.Current_Position],eax
;            mov [edi.MS.Current_Low_Position],0
;            jmp NoNewNote

No_Fonc_03_05:
            dec ebx
            jl NoNewSample
            shl ebx,2
;            cmp ebx,[edi.MS.Current_Sample]
;            jne @@Ok1
; A verifier
;            test edx,edx
;            je @@Ok2
;@@Ok1:
            mov [edi.MS.Current_Sample],ebx
            mov eax,[List_Addr_Sample+ebx]
            mov [edi.MS.New_Sample],On
            mov [edi.MS.Current_Position],eax
            mov [edi.MS.Current_Low_Position],0
;@@Ok2:
            mov ebx,[edi.MS.Current_Sample]
            mov eax,[List_FineTune_Sample+ebx]
            mov [edi.MS.FineTune],ax
            mov eax,[List_Volume_Sample+ebx]
            mov [edi.MS.Sample_Volume],al
            mov [edi.MS.Base_Sample_Volume],al
            jmp NewSample

NoNewSample:
            test edx,edx
            je NoNewNote
            mov ebx,[edi.MS.Current_Sample]
            mov eax,[List_Addr_Sample+ebx]
            mov [edi.MS.New_Sample],On
            mov [edi.MS.Current_Position],eax
            mov [edi.MS.Current_Low_Position],0
NewSample:
            mov ax,cx
            and ax,0f00fh
            cmp ax,0500eh
            jne No_Fonc_Fine
            mov ax,cx
            shl ah,4
            sar ax,12
            call Set_Fine_Tune
No_Fonc_Fine:
            test edx,edx
            je NoNewNote
            mov bx,dx
            call calc_freq
            mov [edi.MS.Frequence],bx
            push edi
            mov edi,[Addr_Current_Drivers]
            call [edi.Dev_Func.Get_Frequence_]
            pop edi
            mov [edi.MS.Compt_Frequence],eax
NoNewNote:
            mov bx,cx
            and ebx,0fh
            mov al,ch
            mov ecx,[List_Normal_Do_Func_Mod+4*ebx]
            and eax,0ffh
            mov [edi.MS.Last_Effect],ecx
            mov esi,[Addr_Current_Drivers]
            jmp [List_Normal_Func_Mod+4*ebx]

Extended_Func_Mod:
            movzx ebx,al
            shr ebx,4
            and eax,0fh
            mov ecx,[List_Extended_Do_Func_Mod+4*ebx]
            mov [edi.MS.Last_Effect],ecx
            mov esi,[Addr_Current_Drivers]
            jmp [List_Extended_Func_Mod+4*ebx]


Do_Effect_Mod:
            mov ecx,[Number_Channel]
            mov edi,O Channel1
@@Ok10:
            push ecx
            push edi
            mov esi,[Addr_Current_Drivers]
            call [edi.MS.Last_Effect]
            mov esi,[Addr_Current_Drivers]
            call [esi.Dev_Func.Play_Voice_]
            pop edi
            pop ecx
            add edi,Size Channel1
            dec cl
            jne @@Ok10
            ret