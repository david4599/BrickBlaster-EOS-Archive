;----------------------------------------------------------------------------
edit_on:
;----------------------------------------------------------------------------

            call wait_keyboard_release
            cmp game_mode,EDIT
            je edit_off

            mov demo_counter,DELAI_DEMO_MAX
            mov game_mode,READY_TO_PLAY
            mov computer_flag,Off
            mov demo_flag,Off
            mov test_flag,Off

            call init_sprites
            call init_first_ball
            call init_panel
            call init_palette
            call init_score

            call reset_magnetic
            call reset_ghost

            mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            call init_options
            call init_monster

            mov game_mode,EDIT
            call init_cursor_edit

            mov esi,panel_editor_o
            mov edi,panel_editor_pos_y
            mov ebx,panel_editor_pos_x
            mov ecx,panel_editor_size_y
            mov edx,panel_editor_size_x
            call draw_shape

            mov edi,arrow_pos_1
            call draw_box_1

            mov edi,arrow_pos_6
            call draw_box_2

            mov current_block,brique_classic_o
            mov current_code,normale+1
            mov current_couleur,0

            mov test_1.sprite_status,Off
            mov panel_nbs_ball_1.sprite_status,Off
            mov panel_nbs_ball_2.sprite_status,Off

            lea esi,option_text_editor
            call print
            jmp rebuild_all


;----------------------------------------------------------------------------
Init_Cursor_edit:
;----------------------------------------------------------------------------

            mov ball_1.sprite_status,Off
            mov ball_2.sprite_status,Off
            mov cursor_1.sprite_size_x,brique_size_x
            mov cursor_1.sprite_size_y,brique_size_y
            mov cursor_1.sprite_adrs,cursor_editor_o
            push cursor_1.sprite_adrs
            pop  cursor_1.sprite_current_adrs

            mov cursor_1.sprite_min_x,bord_x
            mov cursor_1.sprite_min_y,bord_y+32
            mov cursor_1.sprite_max_x,limite_x-brique_size_x
            mov cursor_1.sprite_max_y,limite_y-brique_size_y
            mov cursor_1.sprite_pos_x,bord_x
            mov cursor_1.sprite_pos_y,bord_y
            mov cursor_1.sprite_status,On

            mov cursor_1.sprite_nbs_shape,1
            mov cursor_1.sprite_shape_speed,1
            ret


;----------------------------------------------------------------------------
edit_off:
;----------------------------------------------------------------------------

            mov demo_counter,DELAI_DEMO
            mov game_mode,READY_TO_PLAY

            mov edi,panel_editor_pos_y
            mov ebx,panel_editor_pos_x
            mov ecx,panel_editor_size_y
            mov edx,panel_editor_size_x
            call erase_shape

            mov panel_nbs_ball_1.sprite_status,On
            cmp dual_flag,On
            jne @@ok
            mov panel_nbs_ball_2.sprite_status,On
@@ok:

            lea esi,option_text_ready
            call print
            jmp start_game


;----------------------------------------------------------------------------
refresh_editor:
;----------------------------------------------------------------------------

            cmp game_mode,EDIT
            jne @@end

            mov ebp,_key_map
            cmp B [ebp+space],On
            je @@draw
            cmp B [ebp+83],On
            je @@erase
            call read_click
            jz @@cont
            cmp bl,2
            je @@erase
@@draw:
            mov edi,cursor_1.sprite_pos_y
            mov esi,cursor_1.sprite_pos_x
            call _trunk_data
            mov ebx,esi
            mov ecx,cursor_1.sprite_size_y
            mov edx,cursor_1.sprite_size_x
            mov esi,current_block
            add esi,current_couleur
            pushad
            call _erase_shape
            popad
            call draw_shape
            mov ebp,current_code
            call modif_level
            ret
@@erase:
            mov edi,cursor_1.sprite_pos_y
            mov esi,cursor_1.sprite_pos_x
            call _trunk_data
            mov ebx,esi
            mov ecx,cursor_1.sprite_size_y
            mov edx,cursor_1.sprite_size_x
            call erase_shape
            mov ebp,0
            call modif_level
            ret

@@cont:
            mov ebp,_key_map
            cmp B [ebp+key_F1],On
            je @@f1
            cmp B [ebp+key_F2],On
            je @@f2
            cmp B [ebp+key_F3],On
            je @@f3
            cmp B [ebp+key_F4],On
            je @@f4

            cmp B [ebp+key_F5],On
            je @@f6
            cmp B [ebp+key_F6],On
            je @@f7
            cmp B [ebp+key_F7],On
            je @@f8
            cmp B [ebp+key_F8],On
            je @@f9

            cmp B [ebp+key_F9],On
            je @@f5
            cmp B [ebp+key_F10],On
            je xchg_level

            cmp B [ebp+key_F11],On
            je @@read_level
            cmp B [ebp+key_F12],On
            je @@write_level

            cmp B [ebp+up],On
            je @@dec_y
            cmp B [ebp+down],On
            je @@inc_y
            cmp B [ebp+right],On
            je @@inc_x
            cmp B [ebp+left],On
            je @@dec_x

            cmp B [ebp+Ctrl],On
            jne @@end
            cmp B [ebp+82],On
            je ins_level
@@end:
            ret

@@dec_y:
            cmp cursor_1.sprite_pos_y,bord_y+brique_size_y
            jb @@end
            sub cursor_1.sprite_pos_y,brique_size_y
            attente 4
            ret
@@inc_y:
            cmp cursor_1.sprite_pos_y,limite_y-brique_size_y
            jae @@end
            add cursor_1.sprite_pos_y,brique_size_y
            attente 4
            ret
@@dec_x:
            cmp cursor_1.sprite_pos_x,bord_x+brique_size_x
            jb @@end
            sub cursor_1.sprite_pos_x,brique_size_x
            attente 5
            ret
@@inc_x:
            cmp cursor_1.sprite_pos_x,limite_x-brique_size_x
            jae @@end
            add cursor_1.sprite_pos_x,brique_size_x
            attente 5
            ret

@@f1:
            call wait_keyboard_release
            mov current_block,brique_classic_o
            mov  ebx,normale+001b
            call @@change_brique_type
            mov edi,arrow_pos_1
            call draw_box_1
            ret

@@f2:
            call wait_keyboard_release
            mov current_block,brique_multi_o
            mov ebx,normale+100b
            call @@change_brique_type
            mov edi,arrow_pos_2
            call draw_box_1
            ret

@@f3:
            call wait_keyboard_release
            mov current_block,brique_beton_o
            mov ebx,incassable
            call @@change_brique_type
            mov edi,arrow_pos_3
            call draw_box_1
            ret

@@f4:
            call wait_keyboard_release
            mov current_block,brique_transp_o
            mov ebx,transparente+001b
            call @@change_brique_type
            mov edi,arrow_pos_4
            call draw_box_1
            ret

@@f5:
            call wait_keyboard_release
            mov current_block,brique_teleport_o
            mov ebx,teleporteuse
            call @@change_brique_type
            mov edi,arrow_pos_5
            call draw_box_1
            ret

@@change_brique_type:
            mov eax,current_code
            and eax,couleur_de_brique
            or  eax,ebx
            mov current_code,eax
            ret

@@f6:
            call wait_keyboard_release
            mov ebx,verte
            call @@change_brique_color
            mov edi,arrow_pos_6
            call draw_box_2
            ret

@@f7:
            call wait_keyboard_release
            mov ebx,bleu
            call @@change_brique_color
            mov edi,arrow_pos_7
            call draw_box_2
            ret

@@f8:
            call wait_keyboard_release
            mov ebx,violet
            call @@change_brique_color
            mov edi,arrow_pos_8
            call draw_box_2
            ret

@@f9:
            call wait_keyboard_release
            mov ebx,orange
            call @@change_brique_color
            mov edi,arrow_pos_9
            call draw_box_2
            ret

@@change_brique_color:
            mov eax,current_code
            and eax,not couleur_de_brique
            or eax,ebx
            mov current_code,eax
            mov eax,ebx
            shr eax,6
            imul eax,next_color
            mov current_couleur,eax
            ret


;----------------------------------------------------------------------------
@@write_level:
;----------------------------------------------------------------------------
            call write_level
            ret


;----------------------------------------------------------------------------
@@read_level:
;----------------------------------------------------------------------------

            call read_level
            call create_wall
            ret


;----------------------------------------------------------------------------
xchg_level:
;----------------------------------------------------------------------------

            call wait_keyboard_release

            mov eax,current_level
            dec eax
            imul eax,nbs_brique_x*nbs_brique_y
            add eax,level_adrs
            push eax
            push eax

            pop esi
            lea edi,level_clipboard_1
            mov ecx,nbs_brique_x*nbs_brique_y
            rep movsb

            pop edi
            lea esi,level_clipboard_2
            mov ecx,nbs_brique_x*nbs_brique_y
            rep movsb

            lea esi,level_clipboard_1
            lea edi,level_clipboard_2
            mov ecx,nbs_brique_x*nbs_brique_y
            rep movsb

            call create_wall
            ret

            .data
level_clipboard_1 db nbs_brique_y*nbs_brique_x dup (0)
level_clipboard_2 db nbs_brique_y*nbs_brique_x dup (0)
            .code


;----------------------------------------------------------------------------
ins_level:
;----------------------------------------------------------------------------

            call wait_keyboard_release

            cmp level_number,80
            je @@end

            inc level_number

            mov eax,level_number
            mov current_level,eax
            dec eax
            imul eax,nbs_brique_x*nbs_brique_y
            add eax,level_adrs

            cmp B [eax],-1
            jne Error_File

            mov edi,eax
            mov ecx,nbs_brique_x*nbs_brique_y
            mov al,0
            rep stosb

            call create_wall
@@end:
            ret


;----------------------------------------------------------------------------
modif_level:
;----------------------------------------------------------------------------

            mov eax,cursor_1.sprite_pos_y
            sub eax,bord_y
            shr eax,4
            imul eax,nbs_brique_x
            mov ebx,cursor_1.sprite_pos_x
            sub ebx,bord_x
            shr ebx,5
            add ebx,eax

            mov eax,current_level
            dec eax
            imul eax,nbs_brique_x*nbs_brique_y
            add eax,level_adrs

            add eax,ebx

            mov ebx,ebp
            mov B [eax],bl
            ret


;----------------------------------------------------------------------------
draw_box_1:
;----------------------------------------------------------------------------

            mov ebx,arrow_pos_x
            mov ecx,arrow_size_y
            mov edx,arrow_size_x
            mov esi,arrow_o
            pushad
            mov edi,old_box_1
            mov esi,arrow_del_o
            call draw_shape
            popad
            mov old_box_1,edi
            call draw_shape
            ret

            .data
old_box_1   dd arrow_pos_1
            .code


;----------------------------------------------------------------------------
draw_box_2:
;----------------------------------------------------------------------------

            mov ebx,arrow_pos_x
            mov ecx,arrow_size_y
            mov edx,arrow_size_x
            mov esi,arrow_o
            pushad
            mov edi,old_box_2
            mov esi,arrow_del_o
            call draw_shape
            popad
            mov old_box_2,edi
            call draw_shape
            ret

            .data
old_box_2   dd arrow_pos_6
            .code


;----------------------------------------------------------------------------
trunk_data:
;----------------------------------------------------------------------------

            cmp game_mode,EDIT
            jne @@end

            cmp [edx.sprite_mode],Panel
            jne _trunk_data
@@end:
            ret


;----------------------------------------------------------------------------
_trunk_data:
;----------------------------------------------------------------------------

            sub edi,bord_y
            sub esi,bord_x
            and edi,00000000000000001111111111110000b
            and esi,00000000000000001111111111100000b
            add edi,bord_y
            add esi,bord_x
            ret

            .data
current_block   dd brique_classic_o
current_code    dd normale+1
current_couleur dd 0
            .code