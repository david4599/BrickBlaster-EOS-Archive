;----------------------------------------------------------------------------
init_score:
;----------------------------------------------------------------------------

            lea ebp,player_1
            call _init_score
            mov ebx,panel_score_1_o
            call _print

            cmp dual_flag,On
            jne @@cont
            lea ebp,player_2
            call _init_score
            mov ebx,panel_score_2_o
            call _print
@@cont:
            ret


;----------------------------------------------------------------------------
_init_score:
;----------------------------------------------------------------------------

            mov W [ebp.player_score_txt+1],'00'
            mov W [ebp.player_score_txt+3],'00'
            mov W [ebp.player_score_txt+5],'00'

            mov [ebp.player_counter_score],0

            mov eax,bonus_extra_life
            mov [ebp.player_bonus_life],eax

            push sprite_buffer
            pop current_fonte_buffer
            lea esi,[ebp.player_score_txt]
            ret


;----------------------------------------------------------------------------
dec_score:
;----------------------------------------------------------------------------

            pushad
            cmp dual_flag,On
            je @@ok
            mov ebp,O player_1
@@ok:
            cmp option_night_flag,On
            jne @@cont
            shl ecx,1
@@cont:
            jecxz @@end
            lea esi,[ebp.player_score_txt]
@@again:
            cmp [ebp.player_counter_score],0
            je @@exit
            sub [ebp.player_counter_score],10

            mov ebx,5
            call calc_dec
            loop @@again
@@exit:
            push sprite_buffer
            pop current_fonte_buffer
            mov ebx,[ebp.player_panel]
            call _print
@@end:
            popad
            ret


;----------------------------------------------------------------------------
inc_score:
;----------------------------------------------------------------------------

            cmp difficulte,HARD
            jne @@not_hard
            add ecx,2
@@not_hard:

            cmp difficulte,MEDIUM
            jne @@not_medium
            add ecx,1
@@not_medium:

            pushad

            cmp dual_flag,On
            je @@ok
            mov ebp,O player_1
@@ok:
            cmp option_night_flag,On
            jne @@cont
            shl ecx,1
@@cont:
            jecxz @@end
            lea esi,[ebp.player_score_txt]
@@again:
            cmp [ebp.player_counter_score],999990
            je @@exit
            add [ebp.player_counter_score],10
            mov ebx,5
            call calc_inc
            loop @@again
@@exit:
            push sprite_buffer
            pop current_fonte_buffer
            mov ebx,[ebp.player_panel]
            call _print
@@end:
            popad
            ret



;----------------------------------------------------------------------------
display_level:
;----------------------------------------------------------------------------

            pushad
            mov ecx,current_level
            jecxz @@end
            mov W level_txt+1,'00'
            lea esi,level_txt
@@again:
            mov ebx,2
            call calc_inc
            loop @@again
            mov ebx,panel_level_o
            push sprite_buffer
            pop current_fonte_buffer
            call _print
@@end:
            popad
            ret

            .data
level_txt   db 1,'00',0
            .code

calcagain:
            mov byte ptr [esi+ebx],'0'
            dec ebx
;----------------------------------------------------------------------------
calc_inc:
;----------------------------------------------------------------------------
            cmp byte ptr [esi+ebx],1
            je calc_max
            inc byte ptr [esi+ebx]
            cmp byte ptr [esi+ebx],'9'
            ja calcagain
calc_max:
            ret

calcagain2:
            mov byte ptr [esi+ebx],'9'
            dec ebx
;----------------------------------------------------------------------------
calc_dec:
;----------------------------------------------------------------------------
            cmp byte ptr [esi+ebx],1
            je calc_max2
            dec byte ptr [esi+ebx]
            cmp byte ptr [esi+ebx],'0'
            jb calcagain2
calc_max2:
            ret


;----------------------------------------------------------------------------
Print_final:
;----------------------------------------------------------------------------

            push video_buffer
            pop current_fonte_buffer
            mov ebx,panel_hiscore_o
            mov transparence,On
            call _print
            mov transparence,Off

            mov esi,video_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            call flip_buffer
            ret


;----------------------------------------------------------------------------
Print_score:
;----------------------------------------------------------------------------

            lea esi,score_1.score_text

            cmp nbs_player,2
            jne @@ok
            lea esi,coop_score_1.score_text
@@ok:

            push video_buffer
            pop current_fonte_buffer
            mov ebx,panel_hiscore_o
            mov transparence,On
            call _print
            mov transparence,Off

            mov esi,video_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            call flip_buffer

            ret


;----------------------------------------------------------------------------
Print_name:
;----------------------------------------------------------------------------

            push edi
            mov edi,name_pos_y
            mov ebx,name_pos_x
            mov ecx,name_nbs_lgn
            mov edx,name_nbs_col
            call _Erase_Shape

            pushad
            push video_buffer
            pop current_fonte_buffer
            mov ebx,erase_o
            mov esi,name_adrs
            mov transparence,On
            mov next_flag,Off
            call _print
            mov next_flag,On
            mov transparence,Off
            popad

            call flip_screen

            pop edi
            ret


;----------------------------------------------------------------------------
;           lea esi,Texte
Print_menu:
;----------------------------------------------------------------------------

            cmp esi,last_menu
            je @@end

            push edi
            mov last_menu,esi

            mov ebx,panel_menu_o
            push sprite_buffer
            pop current_fonte_buffer
            call _Print

            call wait_synchro

            mov ecx,256*3
            mov eax,0
          ÿÿmov esi,offset palette
            call set_palette

            pop esi
            cmp esi,last_menu
            je @@end
            lea eax,menu_last.menu_text_2
            cmp esi,eax
            je @@end
            mov last_menu2,esi

            mov ebx,panel_menu2_o
            call _Print

@@end:
            ret

            .data
last_menu    dd ?
last_menu2   dd ?
            .code


;----------------------------------------------------------------------------
Print_off:
;----------------------------------------------------------------------------

            lea esi,option_text_off

;----------------------------------------------------------------------------
;           lea esi,Texte
Print:
;----------------------------------------------------------------------------

            mov ebx,panel_info_o
            push sprite_buffer
            pop current_fonte_buffer

;----------------------------------------------------------------------------
;           mov ebx,Texte_pos
;           lea esi,Texte
_Print:
;----------------------------------------------------------------------------

            pushad
            mov Fonte_Ptr,ebx

            cmp byte ptr [esi],1
            jne @@again
            inc esi
@@again:
            lodsb
            cmp al,13
            je @@next_ligne
            or al,al
            je @@end

            push esi

            lea edi,Fonte
            mov ecx,Fonte_size
            repne scasb
            dec edi

            lea esi,Fonte
            sub edi,esi

            mov esi,[Fonte_Tbl+edi*4]
            add esi,Fonte_Buffer

            mov edi,ebx
            add edi,current_fonte_buffer

            push ebx
            mov edx,Fonte_size_x
            mov ebp,Fonte_size_y
            mov eax,screen_x
            sub eax,edx
            mov ebx,fonte_screen_x
            sub ebx,edx

            cmp transparence,On
            je @@_transparence

            align
@@ligne:
            mov ecx,edx
            rep movsb
            add esi,ebx
            add edi,eax

            dec ebp
            jnz @@ligne

            pop ebx
            pop esi
            add ebx,edx
            jmp @@again
@@end:
            popad
            ret


@@next_ligne:
            cmp next_flag,Off
            je @@end
            mov ebx,Fonte_Ptr
            add ebx,(screen_x*Fonte_Next_Line)
            mov Fonte_Ptr,ebx
            add esi,4
            jmp @@again

            .data
next_flag   dd On
            .code

@@_transparence:
            align
@@_ligne:
            mov ecx,edx
            push eax
@@_draw:
            lodsb
            or al,al
            jz @@_cont
            mov B [edi],al
@@_cont:
            inc edi
            loop @@_draw
            pop eax
            add esi,ebx
            add edi,eax

            dec ebp
            jnz @@_ligne

            pop ebx
            pop esi
            add ebx,edx
            jmp @@again
            popad
            ret

            .data
Fonte_ptr            dd ?
current_fonte_buffer dd ?
transparence         dd Off

fonte_screen_x      = 800

Fonte_Adrs          = 001+(fonte_screen_x*001)

Fonte_size_x        = 15
Fonte_size_y        = 22
Fonte_next_char     = 16
Fonte_Next_Line     = 30

Fonte               db 'abcdefghijklmnopqrstuvwxyz0123456789+-#!?:.& '
Fonte_Size          =$-Fonte
                    db ' ' ; invalid

Fonte_Tbl           label dword
                    v1=Fonte_Adrs
                    rept Fonte_Size
                    dd v1
                    v1=v1+Fonte_next_char
                    endm
            .code