;----------------------------------------------------------------------------
; Gestion des HiScores.
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Display_score_from_final:
;----------------------------------------------------------------------------

            ;call remove_wall
            ;call draw_sprites
            ;call refresh_sprites

                        ;call init_palette
                        ;
                        ;lea esi,final_text
                        ;call print_final
                        ;
                        ;mov ecx,-1
                        ;call wait_click

            lea esi,palette
            lea edi,palette_bak
            mov ecx,768
            rep movsb

            call load_final_anim

            cmp dual_flag,On
            je @@exit

            mov shade_volume,Off
            mov shade_org,0
            mov shade_len,256
            call Shade_Off

            lea edi,palette
            lea esi,palette_bak
            mov ecx,768
            rep movsb

                        call init_palette

                        lea esi,final_text
                        call print_final

@@wait2:
            call wait_synchro
            call read_click
            jnz @@wait2
            call wait_keyboard_release

                        mov ecx,-1
                        call wait_click

                        ;lea edx,File_Credit_M
                        ;call display_intro
                        ;jc @@exit_credit
                        ;
                        ;lea edx,File_Credit_G
                        ;call display_intro
                        ;jc @@exit_credit
                        ;
                        ;lea edx,File_Credit_C
                        ;call display_intro
                        ;jc @@exit_credit
                        ;
                        ;lea edx,File_Credit_W
                        ;call display_intro
                        ;jc @@exit_credit
                        ;
                        ;lea edx,File_Credit_e
                        ;call display_intro
                        ;jc @@exit_credit

@@exit_credit:
            lea edi,palette
            lea esi,palette_bak
            mov ecx,768
            rep movsb

            call _display_score
@@exit:
            ret

palette_bak db 768 dup (0)


;----------------------------------------------------------------------------
Display_score_from_menu:
;----------------------------------------------------------------------------

            mov shade_org,0
            mov shade_len,256
            call Shade_Off

            call load_picture_hiscore

            mov player_1.player_counter_score,0
            mov player_2.player_counter_score,0
            call _display_score

            ret


;----------------------------------------------------------------------------
Display_score:
;----------------------------------------------------------------------------

            cmp dual_flag,On
            je @@exit

            mov shade_org,0
            mov shade_len,256
            call Shade_Off

            call _display_score

            mov shade_org,0
            mov shade_len,256
            call Shade_Off
            ret

@@exit:
            push current_module
            lea edx,Music_score
            call Load_Music

            call remove_wall
            call draw_sprites
            call refresh_sprites
            call init_palette

            mov eax,' eno'
            cmp player_2.player_nbs_ball,-1
            je @@ok
            mov eax,' owt'
@@ok:
            mov D winner,eax

            lea esi,final_dual
            call print_final

@@wait:
            call wait_synchro
            call read_click
            jnz @@wait
            call wait_keyboard_release

            mov ecx,-1
            call wait_click

            pop edx
            call Load_Music
            ret


;----------------------------------------------------------------------------
remove_wall:
;----------------------------------------------------------------------------

            push sprite_buffer

            push true_background_buffer
            pop sprite_buffer

            mov esi,bord_x
            mov edi,bord_y
            mov ebx,bord_x
            mov ecx,screen_y
            mov edx,limite_x-bord_x
            call draw_shape

            pop sprite_buffer
            ret


;----------------------------------------------------------------------------
_Display_score:
;----------------------------------------------------------------------------

            push current_module

            lea edx,Music_score
            call Load_Music

            call Load_Score

            call detect_new_score

            mov esi,true_background_buffer
            mov edi,video_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            call draw_buffer

            call print_score

            mov shade_org,0
            mov shade_len,256
            call Shade_On

            call get_name

            call wait_keyboard_release
@@wait:
            call wait_synchro
            call read_click
            jnz @@wait

            pop edx
            call Load_Music

            ret


;----------------------------------------------------------------------------
detect_new_score:
;----------------------------------------------------------------------------

            mov eax,player_1.player_counter_score

            lea esi,score_1.score_value
            cmp nbs_player,2
            jne @@ok
            lea esi,coop_score_1.score_value
@@ok:
            mov ecx,nbs_score
            mov name_pos_x,(bord_x+8)+(12*fonte_size_x)
            mov name_pos_y,(bord_y+22)
@@again:
            cmp eax,D [esi]
            jae @@insert_new_score
            add esi,size struc_score
            add name_pos_y,fonte_next_line
            loop @@again
@@exit:
            mov name_adrs,Off
            ret

@@insert_new_score:
            push esi
            dec ecx
            jecxz @@end
            mov eax,ecx
            imul eax,size struc_score
            mov ecx,eax
            mov edi,esi
            add edi,size struc_score

            @@insert:
            mov al, B [esi+ecx-1]
            mov B [edi+ecx-1],al
            loop @@insert
            mov score_15.score_end,0
            mov coop_score_15.score_end,0
@@end:
            pop esi

            push player_1.player_counter_score
            pop [esi.score_value]

            mov ax,W player_1.player_score_txt+1
            mov W [esi.score_text+0],ax
            mov ax,W player_1.player_score_txt+3
            mov W [esi.score_text+2],ax
            mov ax,W player_1.player_score_txt+5
            mov W [esi.score_text+4],ax

            mov ax,W level_txt+1
            mov W [esi.score_level],ax

            lea eax,[esi.score_name]
            mov name_adrs,eax

            ret


;----------------------------------------------------------------------------
Get_name:
;----------------------------------------------------------------------------

            cmp name_adrs,Off
            je @@end

            mov ah,Use_Int_09
            mov bx,Off
            Int_EOS

            mov edi,name_adrs
            mov ecx,name_size
            mov al,' '
            rep stosb

            mov edi,name_adrs
            mov name_adrs_min,edi
            call print_name
@@again:
            call wait_synchro
            call print_cursor

            mov ah,1
            _int 16h
            jz @@again
            mov ah,0
            _int 16h

            cmp al,13
            je @@stop
            cmp ah,1
            je @@stop
            cmp ah,14
            je @@del
            cmp al,20h
            jb @@again
            cmp al,80h
            jae @@again
            or al,20h

            cmp B [edi],' '
            jb @@again

            stosb

            call print_name
            jmp @@again
@@del:
            cmp edi,name_adrs_min
            je @@again
            dec edi
            mov B [edi],' '
            call print_name
            jmp @@again

@@stop:
            mov ah,Use_Int_09
            mov bx,On
            Int_EOS

            call save_score
            ret

@@end:
            mov ecx,-1
            call wait_click
            ret


            .data
name_adrs     dd ?
name_adrs_min dd ?
name_pos_y   dd ?
name_pos_x   dd ?
name_nbs_lgn dd fonte_size_y
name_nbs_col dd name_size*Fonte_next_char
            .code


;----------------------------------------------------------------------------
Print_Cursor:
;----------------------------------------------------------------------------

            inc cursor_delai
            cmp cursor_delai,10
            jb @@end
            mov cursor_delai,0

            push edi
            mov eax,edi
            sub eax,name_adrs_min
            imul eax,fonte_size_x
            add eax,name_pos_x
            mov ebx,eax
            mov edi,name_pos_y
            mov ecx,fonte_size_y
            mov edx,fonte_size_x
            mov esi,Cursor_o
            add esi,cursor_cli
            call _erase_shape
            call draw_shape
            xor cursor_cli,fonte_size_x
            pop edi
@@end:
            ret

            .data
cursor_delai dd 0
cursor_cli   dd 0
            .code


;----------------------------------------------------------------------------
Load_Score:
;----------------------------------------------------------------------------

            mov eax,'.scr'
            call Init_File
            mov ax,3d00h
            _int 21h
            jc @@end
            mov bx,ax

            lea edx,score_1
            mov ecx,score_size
            mov ax,3f00h
            _int 21h

            mov ax,3e00h
            _int 21h

            call Code_Score
@@end:
            ret


;----------------------------------------------------------------------------
Save_Score:
;----------------------------------------------------------------------------

            call Code_Score

            mov eax,'.scr'
            call Init_File
            mov ax,3d02h
            _int 21h
            jc @@create
@@write:
            mov bx,ax

            lea edx,score_1
            mov ecx,score_size
            mov ax,4000h
            _int 21h

            mov ax,3e00h
            _int 21h

            call Code_Score

            ret

@@create:
            mov eax,'.scr'
            call Init_File
            mov ecx,0
            mov ax,3c00h
            _int 21h
            jnc @@write

            call Code_Score

            ret


;----------------------------------------------------------------------------
Code_Score:
;----------------------------------------------------------------------------

            mov ecx,score_size
            lea edi,score_1
            mov esi,edi
@@decod:
            lodsb
            xor al,cl
            stosb
            loop @@decod

            ret


;----------------------------------------------------------------------------
; Hi-Scores
;----------------------------------------------------------------------------

            .data

NBS_SCORE           = 15

name_size           = 15

struc_score           struc
  score_value           dd ?
  score_text            db '000000  '
  score_level           db '00  '
  score_name            db '???????????????'
  score_end             db ?
struc_score           ends

score_1       struc_score <1 ,'000000  ','00  ','???????????????',13 >
score_2       struc_score <2 ,'000000  ','00  ','???????????????',13 >
score_3       struc_score <3 ,'000000  ','00  ','???????????????',13 >
score_4       struc_score <4 ,'000000  ','00  ','???????????????',13 >
score_5       struc_score <5 ,'000000  ','00  ','???????????????',13 >
score_6       struc_score <6 ,'000000  ','00  ','???????????????',13 >
score_7       struc_score <7 ,'000000  ','00  ','???????????????',13 >
score_8       struc_score <8 ,'000000  ','00  ','???????????????',13 >
score_9       struc_score <9 ,'000000  ','00  ','???????????????',13 >
score_10      struc_score <10,'000000  ','00  ','???????????????',13 >
score_11      struc_score <11,'000000  ','00  ','???????????????',13 >
score_12      struc_score <12,'000000  ','00  ','???????????????',13 >
score_13      struc_score <13,'000000  ','00  ','???????????????',13 >
score_14      struc_score <14,'000000  ','00  ','???????????????',13 >
score_15      struc_score <15,'000000  ','00  ','???????????????',00 >

coop_score_1  struc_score <1 ,'000000  ','00  ','???????????????',13 >
coop_score_2  struc_score <2 ,'000000  ','00  ','???????????????',13 >
coop_score_3  struc_score <3 ,'000000  ','00  ','???????????????',13 >
coop_score_4  struc_score <4 ,'000000  ','00  ','???????????????',13 >
coop_score_5  struc_score <5 ,'000000  ','00  ','???????????????',13 >
coop_score_6  struc_score <6 ,'000000  ','00  ','???????????????',13 >
coop_score_7  struc_score <7 ,'000000  ','00  ','???????????????',13 >
coop_score_8  struc_score <8 ,'000000  ','00  ','???????????????',13 >
coop_score_9  struc_score <9 ,'000000  ','00  ','???????????????',13 >
coop_score_10 struc_score <10,'000000  ','00  ','???????????????',13 >
coop_score_11 struc_score <11,'000000  ','00  ','???????????????',13 >
coop_score_12 struc_score <12,'000000  ','00  ','???????????????',13 >
coop_score_13 struc_score <13,'000000  ','00  ','???????????????',13 >
coop_score_14 struc_score <14,'000000  ','00  ','???????????????',13 >
coop_score_15 struc_score <15,'000000  ','00  ','???????????????',00 >

Score_Size   = size struc_score*nbs_score*2

            .code