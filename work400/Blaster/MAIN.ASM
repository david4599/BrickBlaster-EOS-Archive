
            call wait_synchro       ; prise en charge des message de windows

            if dos_mode
            call Init_Memory

            lea edx,Ecran_Mono
            mov bx,0
            mov cx,0
            mov ah,Set_String_Mono
            Int_EOS

            endif

            mov ah,Use_Int_09
            mov bx,On
            Int_EOS
            mov _key_map,eax

ifndef WIN32
            call create_timer

            ;call init_snap
endif
            call read_config_user

            call detect_mouse
            jc Exit

ifdef WIN32
            call Detect_Joystick
            jc @@No_Joy
            mov [Joy_Addr],eax
@@No_Joy:
endif
            call Read_Config_Sound

            call Read_Level

            call Read_File_Test

            call Read_File_Config

            call init_video_card

            call init_random

            lea edx,Music_intro
            call Load_Music_Intro

            call search_level_number

            lea edx,File_Editor
            call display_intro_2

            lea edx,File_Credit_B
            call display_intro

;----------------------------------------------------------------------------
intro:
;----------------------------------------------------------------------------

            mov game_mode,MENU
            mov demo_flag,Off
            mov test_flag,Off
            mov computer_flag,Off
            call get_menu
            jnc @@demo

            cmp eax,m_play
            je @@play
            cmp eax,m_score_1
            je @@hiscore_1
            cmp eax,m_score_2
            je @@hiscore_2
            cmp eax,m_credit
            je @@credit
            cmp eax,m_demo
            je @@demo
            cmp eax,m_quit
            je @@exit

            jmp intro

@@demo:

            mov eax,1
            call get_random
            inc eax
            mov nbs_player,eax

            mov eax,1
            call get_random
            add eax,'0'
            mov world,al
            mov B [file_fond+10],al
            mov B [file_palette+6],al

            mov game_mode,PLAYING
            mov demo_counter,DELAI_DEMO
            mov demo_flag,On
            mov test_flag,Off
            mov computer_flag,Off
            call new_game
            jmp intro
@@play:
            mov demo_flag,Off
            mov test_flag,Off
            mov computer_flag,Off
            cmp nbs_player,2
            jne @@ok
            cmp control_2,COMPUTER
            jne @@ok
            mov test_flag,On
            mov demo_flag,On
            mov computer_flag,On
@@ok:
            mov game_mode,READY_TO_PLAY

            mov edx,Music_world
            call Load_Music

            call new_game

            lea edx,Music_intro
            call Load_Music

            jmp intro
@@hiscore_1:
            mov nbs_player,1
            call display_score_from_menu
            mov nbs_player,1
            jmp intro
@@hiscore_2:
            mov nbs_player,2
            call display_score_from_menu
            mov nbs_player,1
            jmp intro
@@credit:
            ;call fade_music

            lea edx,Music_credit
            call Load_Music

@@credit_again:
            call load_intro_anim

            mov ah,get_info
            Int_EOS
            cmp ah,023h
            je @@exit_credit

            lea edx,File_Credit_M
            call display_intro
            jc @@exit_credit

            mov ah,get_info
            Int_EOS
            cmp ah,023h
            je @@exit_credit

            lea edx,File_Credit_G
            call display_intro
            jc @@exit_credit

            mov ah,get_info
            Int_EOS
            cmp ah,023h
            je @@exit_credit

            lea edx,File_Credit_C
            call display_intro
            jc @@exit_credit

            mov ah,get_info
            Int_EOS
            cmp ah,023h
            je @@exit_credit

            lea edx,File_Credit_W
            call display_intro
            jc @@exit_credit

            mov ah,get_info
            Int_EOS
            cmp ah,023h
            je @@exit_credit

            lea edx,File_Credit_e
            call display_intro
            jc @@exit_credit

            mov ah,get_info
            Int_EOS
            cmp ah,023h
            je @@exit_credit
            jmp @@credit_again


@@exit_credit:
            lea edx,Music_intro
            call Load_Music
            jmp intro
@@exit:
            mov shade_volume,On
            mov shade_org,0
            mov shade_len,256
            call Shade_Off

            if debug_mode
            lea edx,Exit_Txt
            endif
            jmp Exit

            .data
game_mode    dd Off
demo_counter dd Off
            .code

;----------------------------------------------------------------------------
get_menu:
;----------------------------------------------------------------------------

            mov shade_org,0
            mov shade_len,256
            call Shade_Off

            call load_picture_menu

            mov esi,background_buffer
            mov edi,video_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            call draw_buffer

            call init_sprites
            mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            call init_options
            call init_cursor_menu

            mov esi,icon_logo_o
            mov edi,icon_logo_pos_y
            mov ebx,icon_logo_pos_x
            mov ecx,icon_logo_size_y
            mov edx,icon_logo_size_x
            call draw_shape

            mov esi,panel_note_o
            mov edi,panel_note_pos_y
            mov ebx,panel_note_pos_x
            mov ecx,panel_note_size_y
            mov edx,panel_note_size_x
            call draw_shape

            mov shade_org,0
            mov shade_len,256
            call Shade_On

            play_sound iff_restart

            mov current_menu,1
            mov fade_option_flag,Off

            ;lea esi,menu_begin.menu_text
            ;call print_menu
            ;lea esi,menu_last.menu_text

@@restart_menu:

@@wait:
            call wait_synchro
            call read_click
            jnz @@wait
            call wait_keyboard_release

            call display_menu_icon

@@again2:
            mov last_menu,-1
            mov last_menu2,-1
            mov ecx,DELAI_DATTENTE
@@again:
            push ecx

            call erase_sprites
            call refresh_mouse
            call refresh_text
            call draw_sprites

            call fade_options
            call flip_sprites

            mov event_number,Off
            call detect_button_music
            jc @@click

            call detect_button
            mov event_number,eax
            Send eax,10,5

            mov ecx,1
            call wait_click
            jnz @@click

            pop ecx

            call detect_reset_ecx

            Send ecx,10,6
            loop @@again

            mov difficulte,MEDIUM
            mov control_2 ,COMPUTER
            mov nbs_player,1
            mov dual_flag ,Off
            mov coop_flag,Off

            mov fade_option_flag,Off

            xor eax,eax
            clc
            ret

@@click:
            pop ecx
            mov ecx,DELAI_DATTENTE

            mov ebp,_key_map
            cmp B [ebp+escape],On
            jne @@ok1
            mov event_number,m_quit
@@ok1:
            cmp event_number,Off
            je @@again

;            cmp B [ebp+plus],On
;            jne @@inc
;            call inc_volume
;            jmp @@again2
;@@inc:
;            cmp B [ebp+moins],On
;            jne @@dec
;            call dec_volume
;            jmp @@again2
;@@dec:
            play_sound iff_option

            mov fade_option_flag,Off

            mov eax,event_number

            cmp eax,m_nothing
            je @@restart_menu

            cmp eax,m_paddle
            je @@paddle
            cmp eax,m_joy_ana
            je @@joy_ana
            cmp eax,m_cancel_3
            je @@cancel_3

            cmp eax,m_misc
            je @@misc
            cmp eax,m_cancel_2
            je @@cancel_2

            cmp eax,m_play
            je @@play
            cmp eax,m_cancel
            je @@cancel

            cmp eax,m_solo
            je @@solo
            cmp eax,m_dual
            je @@dual
            cmp eax,m_coop
            je @@coop

            cmp eax,m_computer
            je @@computer
            cmp eax,m_keyboard
            je @@keyboard
            cmp eax,m_joystick
            je @@joystick

            cmp eax,m_space
            je @@space
            cmp eax,m_eclipse
            je @@eclipse
            cmp eax,m_coin_coin
            je @@coin_coin

            cmp eax,m_easy
            je @@easy
            cmp eax,m_normal
            je @@normal
            cmp eax,m_hard
            je @@hard

            mov difficulte,MEDIUM
            mov control_2 ,COMPUTER
            mov nbs_player,1
            mov dual_flag ,Off
            mov coop_flag,Off
            stc
            ret
@@joystick:
            mov current_menu,7
            mov control_2,JOYSTICK
            jmp @@restart_menu
@@cancel_3:
            mov current_menu,3
            jmp @@restart_menu
@@joy_ana:
            mov current_menu,4
            mov paddle_flag,Off
            jmp @@restart_menu
@@paddle:
            mov current_menu,4
            mov paddle_flag,On
            jmp @@restart_menu
@@misc:
            mov current_menu,6
            jmp @@restart_menu
@@cancel_2:
            mov current_menu,1
            jmp @@restart_menu
@@play:
            inc current_menu
            jmp @@restart_menu
@@cancel:
            dec current_menu
            cmp current_menu,3
            jne @@restart_menu
            cmp nbs_player,2
            je @@restart_menu
            dec current_menu
            jmp @@restart_menu
@@solo:
            mov nbs_player,1
            mov dual_flag,Off
            mov coop_flag,Off
            inc current_menu
            jmp @@play
@@coop:
            mov nbs_player,2
            mov dual_flag,Off
            mov coop_flag,On
            jmp @@play
@@dual:
            mov nbs_player,2
            mov dual_flag,On
            mov coop_flag,Off
            jmp @@play
@@computer:
            mov control_2,COMPUTER
            jmp @@play
@@keyboard:
            mov control_2,KEYBOARD
            jmp @@play
@@easy:
            mov difficulte,EASY
            mov eax,m_play
            stc
            ret
@@normal:
            mov difficulte,MEDIUM
            mov eax,m_play
            stc
            ret
@@hard:
            mov difficulte,HARD
            mov eax,m_play
            stc
            ret

@@space:
            lea eax,music_game0
            mov music_world,eax
            mov world,'0'
            mov B [file_fond+10],'0'
            mov B [file_palette+6],'0'
            call Read_Level
            jmp @@play
@@eclipse:
            lea eax,music_game1
            mov music_world,eax
            mov world,'1'
            mov B [file_fond+10],'1'
            mov B [file_palette+6],'1'
            call Read_Level
            jmp @@play
@@coin_coin:
            ;lea eax,music_game2
            ;mov music_world,eax
            ;mov world,'2'
            ;mov B [file_fond+10],'1'
            ;mov B [file_palette+6],'2'
            ;call Read_Level
            jmp @@play

            .data
music_world dd O music_intro
world       db '0'
difficulte  dd MEDIUM
control_2   dd COMPUTER
nbs_player  dd 1
dual_flag   dd Off
coop_flag   dd Off
            .code


;----------------------------------------------------------------------------
display_menu_icon:
;----------------------------------------------------------------------------

            cmp current_menu,1
            jne @@ok1
            mov esi,icon_menu_1_o
@@ok1:
            cmp current_menu,2
            jne @@ok2
            mov esi,icon_menu_2_o
@@ok2:
            cmp current_menu,3
            jne @@ok3
            mov esi,icon_menu_3_o
@@ok3:
            cmp current_menu,4
            jne @@ok4
            mov esi,icon_menu_6_o
@@ok4:
            cmp current_menu,5
            jne @@ok5
            mov esi,icon_menu_4_o
@@ok5:
            cmp current_menu,6
            jne @@ok6
            mov esi,icon_menu_5_o
@@ok6:
            cmp current_menu,7
            jne @@ok7
            mov esi,icon_menu_7_o
@@ok7:
            mov edi,icon_menu_pos_y
            mov ebx,icon_menu_pos_x
            mov ecx,icon_menu_size_y
            mov edx,icon_menu_size_x
            call draw_shape
            ret


;----------------------------------------------------------------------------
refresh_text:
;----------------------------------------------------------------------------

            mov eax,cursor_1.sprite_pos_y
            add eax,cursor_menu_size_y
            mov panel_info.sprite_pos_y,eax
            mov eax,cursor_1.sprite_pos_x
            sub eax,panel_menu_size_x/2
            add eax,cursor_menu_size_x/2
            mov panel_info.sprite_pos_x,eax
            ret


;----------------------------------------------------------------------------
detect_reset_ecx:
;----------------------------------------------------------------------------

            mov eax,cursor_1.sprite_pos_x
            cmp eax,back_x
            jne @@reset
            mov ebx,cursor_1.sprite_pos_y
            cmp ebx,back_y
            jne @@reset
            ret
@@reset:
            mov back_x,eax
            mov back_y,ebx
            mov ecx,DELAI_DATTENTE
            ret

            .data
back_x      dd 0
back_y      dd 0
            .code


;----------------------------------------------------------------------------
detect_button:
;----------------------------------------------------------------------------

            lea edx,menu_begin
@@search:
            cmp [edx.menu_number],last
            je @@end
            mov eax,current_menu
            cmp [edx.menu_number],eax
            jne @@next

            mov eax,[edx.menu_pos_x]
            cmp cursor_1.sprite_pos_x,eax
            jb @@next
            mov eax,[edx.menu_pos_y]
            cmp cursor_1.sprite_pos_y,eax
            jb @@next
            mov eax,[edx.menu_size_x]
            cmp cursor_1.sprite_pos_x,eax
            ja @@next
            mov eax,[edx.menu_size_y]
            cmp cursor_1.sprite_pos_y,eax
            jb @@ok
@@next:
            add edx,size struc_menus
            jmp @@search
@@ok:
            lea edi,[edx.menu_text_2]
            lea esi,[edx.menu_text]
            call print_menu

            mov fade_option_flag,On
            mov fade_option_count,1
            mov eax,[edx.menu_pal]
            mov fade_option_pal,eax
            mov eax,[edx.menu_pal_size]
            mov fade_option_pal_size,eax

            mov eax,[edx.menu_action]
            ret
@@end:
            lea edi,[edx.menu_text_2]
            lea esi,[edx.menu_text]
            call print_menu

            mov fade_option_flag,Off

            xor eax,eax
            ret

            .data
current_menu dd ?
event_number dd ?
            .code


;----------------------------------------------------------------------------
detect_button_music:
;----------------------------------------------------------------------------

            mov eax,panel_music_vu_pos_x
            cmp cursor_1.sprite_pos_x,eax
            jb @@next
            mov eax,panel_music_vu_pos_y
            sub eax,10
            cmp cursor_1.sprite_pos_y,eax
            jb @@next
            mov eax,panel_music_vu_pos_x
            add eax,panel_music_vu_size_x
            cmp cursor_1.sprite_pos_x,eax
            ja @@next
            mov eax,panel_music_vu_pos_y
            add eax,panel_music_vu_size_y
            add eax,10
            cmp cursor_1.sprite_pos_y,eax
            jb @@ok
@@next:
            clc
            ret
@@ok:
            call read_click
            jz @@end
            mov eax,cursor_1.sprite_pos_x
            sub eax,panel_music_vu_pos_x
            mov user_volume,al
            mov master_volume,al
            cmp eax,1
            jae @@ok2
            mov eax,1
@@ok2:
            cmp eax,64
            jbe @@ok3
            mov eax,64
@@ok3:
            mov ball_1.sprite_size_x,eax
@@end:
            stc
            ret


;----------------------------------------------------------------------------
Init_Cursor_Menu:
;----------------------------------------------------------------------------

           lea edx,Begin_Sprites
@@loop:
           cmp [edx.sprite_mode],last
           je @@end
           mov [edx.sprite_status],Off
@@next:
           add edx,size struc_sprites
           jmp @@loop
@@end:
           mov cursor_1.sprite_size_x, cursor_menu_size_x
           mov cursor_1.sprite_size_y, cursor_menu_size_y
           mov cursor_1.sprite_adrs,cursor_menu_o
           push cursor_1.sprite_adrs
           pop cursor_1.sprite_current_adrs

           mov cursor_1.sprite_min_x,bord_x
           mov eax,limite_x
           sub eax,cursor_1.sprite_size_x
           mov cursor_1.sprite_max_x,eax

           mov cursor_1.sprite_min_y,bord_y
           mov eax,screen_y
           sub eax,cursor_1.sprite_size_y
           mov cursor_1.sprite_max_y,eax

           mov cursor_1.sprite_pos_x,260;318
           mov cursor_1.sprite_pos_y,200;269
           mov cursor_1.sprite_status,On

           ;mov cursor_1.sprite_nbs_shape,8
           ;mov cursor_1.sprite_current_shape,8
           ;mov cursor_1.sprite_shape_speed,5
           ;mov cursor_1.sprite_current_speed,5
           ;mov cursor_1.sprite_next_shape,cursor_menu_next

           lea edx,Panel_Info
           mov [edx.sprite_status],On
           mov [edx.sprite_sens_x],Off
           mov [edx.sprite_sens_y],Off
           mov [edx.sprite_angle],Off
           mov [edx.sprite_new_xy],Off
           mov [edx.sprite_old_xy],Off
           mov [edx.sprite_new_xy_dx],Off
           mov [edx.sprite_old_xy_dx],Off
           mov [edx.sprite_min_x],0
           mov [edx.sprite_min_y],0

           mov [edx.sprite_adrs],panel_menu_o
           mov [edx.sprite_size_x],panel_menu_size_x
           mov [edx.sprite_size_y],panel_menu_size_y
           mov [edx.sprite_pos_x],panel_menu_pos_x
           mov [edx.sprite_pos_y],panel_menu_pos_y
           push [edx.sprite_size_x]
           pop  [edx.sprite_old_size_x]
           push [edx.sprite_size_y]
           pop  [edx.sprite_old_size_y]
           push [edx.sprite_adrs]
           pop  [edx.sprite_current_adrs]

           mov eax,screen_y
           sub eax,[edx.sprite_size_y]
           mov [edx.sprite_max_y],eax

           mov eax,screen_x
           sub eax,[edx.sprite_size_x]
           mov [edx.sprite_max_x],eax

           lea edx,Panel_Score
           mov [edx.sprite_status],On
           mov [edx.sprite_sens_x],Off
           mov [edx.sprite_sens_y],Off
           mov [edx.sprite_angle],Off
           mov [edx.sprite_new_xy],Off
           mov [edx.sprite_old_xy],Off
           mov [edx.sprite_new_xy_dx],Off
           mov [edx.sprite_old_xy_dx],Off
           mov [edx.sprite_min_x],0
           mov [edx.sprite_min_y],0
           mov [edx.sprite_max_x],screen_x
           mov [edx.sprite_max_y],screen_y
           mov [edx.sprite_adrs],panel_menu2_o
           mov [edx.sprite_size_x],panel_menu2_size_x
           mov [edx.sprite_size_y],panel_menu2_size_y
           mov [edx.sprite_pos_x],panel_menu2_pos_x
           mov [edx.sprite_pos_y],panel_menu2_pos_y
           push [edx.sprite_size_x]
           pop  [edx.sprite_old_size_x]
           push [edx.sprite_size_y]
           pop  [edx.sprite_old_size_y]
           push [edx.sprite_adrs]
           pop  [edx.sprite_current_adrs]

           lea edx,ball_1
           mov [edx.sprite_status],On
           mov [edx.sprite_sens_x],Off
           mov [edx.sprite_sens_y],Off
           mov [edx.sprite_angle],Off
           mov [edx.sprite_new_xy],Off
           mov [edx.sprite_old_xy],Off
           mov [edx.sprite_new_xy_dx],Off
           mov [edx.sprite_old_xy_dx],Off
           mov [edx.sprite_min_x],0
           mov [edx.sprite_min_y],0
           mov [edx.sprite_max_x],screen_x
           mov [edx.sprite_max_y],screen_y
           mov [edx.sprite_adrs],panel_music_vu_red_o
           movzx eax,user_volume
           cmp eax,1
           jae @@ok2
           mov eax,1
@@ok2:
           cmp eax,64
           jbe @@ok3
           mov eax,64
@@ok3:
           mov [edx.sprite_size_x],eax
           mov [edx.sprite_size_y],panel_music_vu_size_y
           mov [edx.sprite_pos_x],panel_music_vu_pos_x
           mov [edx.sprite_pos_y],panel_music_vu_pos_y
           push [edx.sprite_size_x]
           pop  [edx.sprite_old_size_x]
           push [edx.sprite_size_y]
           pop  [edx.sprite_old_size_y]
           push [edx.sprite_adrs]
           pop  [edx.sprite_current_adrs]

           ;mov [edx.sprite_nbs_shape],1
           ;mov [edx.sprite_current_shape],8
           ;mov [edx.sprite_shape_speed],5
           ;mov [edx.sprite_current_speed],5
           ;mov [edx.sprite_next_shape],cursor_menu_next

           ret


;----------------------------------------------------------------------------
display_Intro_2:
;----------------------------------------------------------------------------

            pushad

            call wait_keyboard_release

            call load_external_gif

            mov shade_org,0
            mov shade_len,256
            call Shade_On

            mov ah,Play_Module
            Int_EOS

            mov ecx,200
            call wait_click
            jnc @@end

            popad
            stc
            ret

@@end:
            popad
            clc
            ret


;----------------------------------------------------------------------------
display_Intro:
;----------------------------------------------------------------------------

            pushad

            call wait_keyboard_release

            call load_gif

            mov shade_org,256-32
            mov shade_len,32
            call Shade_On

            mov ah,Play_Module
            Int_EOS

            attente 5

            mov shade_org,0
            mov shade_len,256-32
            call Shade_On

            mov ecx,150
            call wait_click
            jnc @@end

            popad
            stc
            ret

@@end:
            popad
            clc
            ret


;----------------------------------------------------------------------------
prev_level:
;----------------------------------------------------------------------------

            dec current_level
            cmp current_level,1
            jae _next_level
            mov eax,level_number
            mov current_level,eax
            jmp _next_level


;----------------------------------------------------------------------------
next_level:
;----------------------------------------------------------------------------

            inc current_level
            mov eax,current_level
            cmp eax,level_number
            jbe _next_level

            cmp game_mode,EDIT
            je @@ok
            cmp computer_flag,On
            je @@cont
            cmp demo_flag,On
            je @@ok

@@cont:
            call display_score_from_final
            ret

@@ok:
            mov current_level,1

_next_level:
            cmp game_mode,EDIT
            je @@ok0

            call telepod_ship_off

            mov shade_org,0
            mov shade_len,256
            call Shade_Off
@@ok0:

            call next_fond

            cmp game_mode,EDIT
            je @@ok1

            mov shade_org,0
            mov shade_len,256
            call Shade_On
@@ok1:

            cmp game_mode,EDIT
            je rebuild_all

            cmp computer_flag,On
            je @@ok

            cmp demo_flag,On
            je @@cont
@@ok:
            mov game_mode,READY_TO_PLAY
            lea esi,option_text_ready
            call print
@@cont:
            jmp start_game

            .data
current_level       dd 1
            .code


;----------------------------------------------------------------------------
new_game:
;----------------------------------------------------------------------------

            mov shade_org,0
            mov shade_len,256
            call Shade_Off

            call load_picture_game

            mov esi,background_buffer
            mov edi,video_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            call draw_buffer

            ;mov shade_org,0
            ;mov shade_len,256
            ;call Shade_On

;----------------------------------------------------------------------------
start_new_game:
;----------------------------------------------------------------------------

            ;lea esi,option_text_ready
            ;call print

            mov eax,start_level
            mov current_level,eax

            mov eax,nbs_ball_start
            mov player_1.player_nbs_ball,eax
            mov player_2.player_nbs_ball,eax

            call init_score

            cmp computer_flag,On
            je @@no_random

            cmp demo_flag,On
            jne @@no_random
            mov eax,level_number
            dec eax
            call get_random
            inc eax
            mov current_level,eax
            lea esi,option_text_demo
            call print
@@no_random:

            call next_fond

            mov shade_org,0
            mov shade_len,256
            call Shade_On


;----------------------------------------------------------------------------
start_game:
;----------------------------------------------------------------------------

            call init_sprites
            call init_cursor
            call init_cursor
            call init_first_ball
            call init_panel
            call init_palette

            call reset_magnetic
            call reset_ghost

            call init_start_game


;----------------------------------------------------------------------------
rebuild_all:
;----------------------------------------------------------------------------

            call create_wall

            call init_demo
            call init_options
            call init_monster

            call telepod_ship_on

;----------------------------------------------------------------------------
main:
;----------------------------------------------------------------------------

            Send game_mode,10,6

            call    erase_sprites
            call detect_new_option
            call detect_current_option_end
            call detect_new_life_player_1
            call detect_new_life_player_2
            call detect_large_cursor_player_1
            call detect_small_cursor_player_1
            call detect_large_cursor_player_2
            call detect_small_cursor_player_2
            call detect_shoot_player_1
            call detect_shoot_player_2
            call create_monster
            call detect_init_palette
            call detect_collision_cursor
            call       refresh_mouse
            call detect_start_game
            call       refresh_ball
            call       refresh_shoot
            call       refresh_monster
            call       refresh_options
            call       refresh_sprites
            call       refresh_editor
            call detect_game_over_player_1
            jc start_game
            call detect_game_over_player_2
            jc start_game
            cmp game_mode,NEW_PLAY
            je @@play_again
            call detect_next_level
            jnc next_level
            call    draw_telepod
            call    draw_brique_incassable
            call    draw_sprites
            call wait_synchro
            call fade_options
            call flip_sprites
            call flip_telepod

;----------------------------------------------------------------------------test keyboard

            mov ebp,_key_map

            cmp debug_game,Off
            je @@pass1
            cmp B [ebp+all],key_e
            je edit_on

            ;cmp B [ebp+key_h],On
            ;jne @@pass1
            ;call snap_iff
@@pass1:

            cmp debug_game,On
            je @@pass2
            cmp game_mode,EDIT
            jne @@no_inc
@@pass2:
            cmp B [ebp+all],plus
            je next_level
            cmp B [ebp+all],moins
            je prev_level
@@no_inc:

;            cmp B [ebp+all],plus
;            jne @@inc
;            call inc_volume
;@@inc:
;            cmp B [ebp+all],moins
;            jne @@dec
;            call dec_volume
;@@dec:

            cmp B [ebp+all],escape  ; ESC
            je @@exit

            cmp game_mode,EDIT
            je main

            cmp debug_game,Off
            je @@pass3
            cmp B [ebp+all],key_r
            je start_game
            cmp B [ebp+all],key_d
            je demo_on
            cmp B [ebp+all],key_t
            je test_on
@@pass3:

            cmp B [ebp+all],key_p
            je pause

            cmp computer_flag,On
            je @@cont
            cmp demo_flag,On
            jne @@cont
            cmp test_flag,On
            je @@cont
            call read_click
            jnz @@exit
            dec demo_counter
            cmp demo_counter,off
            jne @@cont
            ret
@@cont:
            ;cmp game_mode,GAME_OVER
            ;je @@new

            mov ebp,_key_map
            cmp B [ebp+all],space   ; SPACE
            jne main

            cmp computer_flag,On
            je @@play_again

            cmp demo_flag,On
            jne @@play_again

@@exit:
            call wait_synchro
            call read_click
            jnz @@exit
            call wait_keyboard_release

            cmp game_mode,EDIT
            je edit_off

            ret

@@play_again:
            call wait_synchro
            call read_click
            jnz @@play_again
            call wait_keyboard_release

            cmp computer_flag,On
            je @@ok
            mov demo_flag,Off
            mov test_flag,Off
@@ok:

            mov game_mode,READY_TO_PLAY
            play_sound iff_restart
            lea esi,option_text_ready
            call print

            jmp start_new_game

;----------------------------------------------------------------------------new game
@@inc_speed:
            call wait_keyboard_release
            mov current_option,option_fast_ball_o
            mov player_1.player_current_option,option_fast_ball_o
            mov player_2.player_current_option,option_fast_ball_o
            jmp main

;----------------------------------------------------------------------------new game
@@dec_speed:
            call wait_keyboard_release
            mov current_option,option_slow_ball_o
            mov player_1.player_current_option,option_slow_ball_o
            mov player_2.player_current_option,option_slow_ball_o
            jmp main


;----------------------------------------------------------------------------
refresh_all:
;----------------------------------------------------------------------------

@@again:
            push ecx
            call    erase_sprites
            call       refresh_mouse
            call       refresh_ball
            call       refresh_shoot
            call       refresh_monster
            call       refresh_options
            call       refresh_sprites
            call       refresh_editor
            call    draw_telepod
            call    draw_brique_incassable
            call    draw_sprites
            call wait_synchro
            call fade_options
            call flip_sprites
            call flip_telepod
            pop ecx
            loop @@again
            ret


;----------------------------------------------------------------------------
pause:
;----------------------------------------------------------------------------

            call wait_keyboard_release
            lea esi,option_text_paused
            call print
            mov ecx,1
            call refresh_all
@@wait:
            mov ebp,_key_map
            cmp B [ebp+all],Off
            jne @@ok
            call wait_synchro
            call read_click
            jz @@wait
@@ok:
            call wait_keyboard_release
            call print_off
            jmp main


;----------------------------------------------------------------------------
demo_on:
;----------------------------------------------------------------------------

            call wait_keyboard_release
            cmp demo_flag,On
            je demo_off
            mov demo_counter,DELAI_DEMO
            mov game_mode,PLAYING
            mov test_flag,Off
            mov demo_flag,On
            mov computer_flag,Off
            lea esi,option_text_demo
            call print
            jmp start_game

            .data
demo_flag dd Off
            .code


;----------------------------------------------------------------------------
demo_off:
;----------------------------------------------------------------------------

            mov demo_counter,DELAI_DEMO
            mov game_mode,READY_TO_PLAY
            lea esi,option_text_ready
            call print
            mov computer_flag,Off
            mov test_flag,Off
            mov demo_flag,Off
            jmp start_game


;----------------------------------------------------------------------------
test_on:
;----------------------------------------------------------------------------

            call wait_keyboard_release
            cmp demo_flag,On
            je test_off
            mov demo_counter,DELAI_DEMO_MAX
            mov game_mode,PLAYING
            mov demo_flag,On
            mov test_flag,On
            mov computer_flag,Off
            lea esi,option_text_test
            call print
            jmp start_game

            .data
test_flag     dd Off
computer_flag dd Off
            .code


;----------------------------------------------------------------------------
test_off:
;----------------------------------------------------------------------------

            call print_off
            mov test_flag,Off
            mov demo_flag,Off
            mov computer_flag,Off
            jmp main


;----------------------------------------------------------------------------
error_mem:
;----------------------------------------------------------------------------
            if debug_mode
            lea edx,Mem_Txt
            endif
            jmp Exit
;----------------------------------------------------------------------------
error_file:
;----------------------------------------------------------------------------
            if debug_mode
            lea edx,File_Txt
            endif
            jmp Exit
;----------------------------------------------------------------------------
error_vesa:
;----------------------------------------------------------------------------
            if debug_mode
            lea edx,Vesa_Txt
            endif
;----------------------------------------------------------------------------
exit:
;----------------------------------------------------------------------------

            push edx

            call write_config_user

            mov ah,Restore_Video_Mode
            Int_EOS

            if debug_mode
            cmp screen,0
            je @@cont
            lea edx,About
            mov ah,Direct_Send
            Int_EOS
@@cont:
            endif

            mov ah,Stop_Module
            Int_EOS

            mov ah,Clear_Module
            Int_EOS

            call Close_Vesa_Bank

ifndef WIN32
            call dispose_timer
endif
            mov ah,Use_Int_09
            mov bx,Off
            Int_EOS

            pop edx

            if debug_mode
            mov ah,Exit_Error
            Int_EOS
            endif

            mov ax,4c00h
            _int 21h


;----------------------------------------------------------------------------
Init_Sprites:
;----------------------------------------------------------------------------

            lea edx,Begin_Sprites
@@loop:
            cmp [edx.sprite_mode],Last
            je @@end

            mov eax,sprite_buffer
            mov [edx.sprite_buffer_adrs],eax
            mov [edx.sprite_screen_x],screen_x

            lea eax,player_1
            mov [edx.sprite_player],eax

            cmp [edx.sprite_mode],Profil
            je @@next
            cmp [edx.sprite_mode],Panel
            je @@next

            mov [edx.sprite_size_x],ball_size
            mov [edx.sprite_size_y],ball_size
            mov [edx.sprite_adrs],ball_orange_o
            push [edx.sprite_size_x]
            pop  [edx.sprite_old_size_x]
            push [edx.sprite_size_y]
            pop  [edx.sprite_old_size_y]
            push [edx.sprite_adrs]
            pop  [edx.sprite_current_adrs]

            mov [edx.sprite_nbs_shape],1
            mov [edx.sprite_current_shape],1
            mov [edx.sprite_shape_speed],1
            mov [edx.sprite_current_speed],1
            mov [edx.sprite_next_shape],0

            mov [edx.sprite_new_xy],0
            mov [edx.sprite_old_xy],0
            mov [edx.sprite_new_xy_dx],0
            mov [edx.sprite_old_xy_dx],0

            mov [edx.sprite_min_x],bord_x

            mov eax,limite_x
            sub eax,[edx.sprite_size_x]
            mov [edx.sprite_max_x],eax

            mov [edx.sprite_min_y],bord_y

            mov eax,screen_y
            sub eax,[edx.sprite_size_y]
            mov [edx.sprite_max_y],eax

            mov [edx.sprite_pos_x],Off
            mov [edx.sprite_pos_y],Off
            mov [edx.sprite_sens_x],Off
            mov [edx.sprite_sens_y],off
            mov [edx.sprite_angle],Off

            mov [edx.sprite_rebond],On

            mov eax,speed_delai
            mov [edx.sprite_speed_counter],eax

            mov [edx.sprite_to_delete],Off
            mov [edx.sprite_delete],Off
            mov [edx.sprite_status],Off

            mov [edx.sprite_magnetic],Off
            mov [edx.sprite_decal_x],Off

@@next:
            add edx,size struc_sprites
            jmp @@loop
@@end:
            ret


;----------------------------------------------------------------------------
Init_Demo:
;----------------------------------------------------------------------------

            cmp demo_flag,On
            jne @@end
            cmp test_flag,On
            je @@end

            lea edx,Ball_1
@@loop:
            cmp [edx.sprite_mode],Ball
            jne @@end

            mov [edx.sprite_status],On

            call random_speed

            call teleporte_ball

            mov [edx.sprite_rebond],On

            mov eax,speed_delai
            mov [edx.sprite_speed_counter],eax

            mov [edx.sprite_angle],Off

@@next:
            add edx,size struc_sprites
            jmp @@loop
@@end:
            ret


;----------------------------------------------------------------------------
Teleporte_ball:
;----------------------------------------------------------------------------

            cmp [edx.sprite_mode],shoot
            je @@end

            @@ag3:
            mov eax,limite_x-bord_x-200
            call get_random
            add eax,bord_x+100
            mov [edx.sprite_pos_x],eax

            mov eax,limite_y-bord_y-200
            call get_random
            add eax,bord_y+100
            mov [edx.sprite_pos_y],eax

            mov esi,0
            mov edi,0
            call test_random_pos
            jc @@ag3

            mov esi,[edx.sprite_size_y]
            mov edi,0
            call test_random_pos
            jc @@ag3

            mov esi,0
            mov edi,[edx.sprite_size_x]
            call test_random_pos
            jc @@ag3

            mov esi,[edx.sprite_size_y]
            mov edi,[edx.sprite_size_x]
            call test_random_pos
            jc @@ag3
@@end:
            ret


;----------------------------------------------------------------------------
add_ball:
;----------------------------------------------------------------------------

            lea edx,Ball_1
@@loop:
            cmp [edx.sprite_mode],Ball
            jne @@end
            cmp [edx.sprite_status],On
            je @@next
            call create_ball
            loop @@loop
            ret
@@next:
            add edx,size struc_sprites
            jmp @@loop
@@end:
            ret


;----------------------------------------------------------------------------
create_ball:
;----------------------------------------------------------------------------

            pushad

            mov ebp,current_player
            call init_ball

            call random_speed

            cmp [edx.sprite_sens_y],0
            js @@ok
            mov eax,[edx.sprite_sens_y]
            neg eax
            mov [edx.sprite_sens_y],eax
@@ok:
@@ag3:
            mov ebp,current_player
            mov ebp,[ebp.player_cursor]

            mov eax,[ebp.sprite_size_x]
            sub eax,ball_size
            sub eax,ball_size
            call get_random
            add eax,[ebp.sprite_pos_x]
            add eax,ball_size
            mov [edx.sprite_pos_x],eax

            mov eax,[ebp.sprite_size_y]
            call get_random
            add eax,[ebp.sprite_pos_y]
            sub eax,ball_size
            sub eax,[ebp.sprite_size_y]
            mov [edx.sprite_pos_y],eax

            mov esi,0
            mov edi,0
            call test_random_pos
            jc @@ag3

            mov esi,[edx.sprite_size_y]
            mov edi,0
            call test_random_pos
            jc @@ag3

            mov esi,0
            mov edi,[edx.sprite_size_x]
            call test_random_pos
            jc @@ag3

            mov esi,[edx.sprite_size_y]
            mov edi,[edx.sprite_size_x]
            call test_random_pos
            jc @@ag3

            popad
            ret


;----------------------------------------------------------------------------
Random_Speed:
;----------------------------------------------------------------------------

            mov eax,2
            call get_random
            add eax,2
            mov [edx.sprite_sens_x],eax
            inc eax
            mov [edx.sprite_sens_y],eax

            mov eax,1
            call get_random
            or eax,eax
            jz @@ok3
            dec [edx.sprite_sens_x]
            @@ok3:

            mov eax,1
            call get_random
            or eax,eax
            jz @@ok2
            inc [edx.sprite_sens_x]
            dec [edx.sprite_sens_y]
            mov [edx.sprite_angle],1
            @@ok2:

            mov eax,1
            call get_random
            or eax,eax
            jz @@ok1
            mov eax,[edx.sprite_sens_x]
            neg eax
            mov [edx.sprite_sens_x],eax
            @@ok1:

            mov eax,1
            call get_random
            or eax,eax
            jz @@ok
            mov eax,[edx.sprite_sens_y]
            neg eax
            mov [edx.sprite_sens_y],eax
            @@ok:

            ret


;----------------------------------------------------------------------------
Test_Random_Pos:
;----------------------------------------------------------------------------

            push edx
            mov eax,[edx.sprite_pos_y]
            add eax,esi
            sub eax,bord_y
            shr eax,4
            imul eax,nbs_brique_x
            pop edx
            mov ebx,[edx.sprite_pos_x]
            add ebx,edi
            sub ebx,bord_x
            shr ebx,5
            add ebx,eax
            push edx
            mov eax,current_level
            dec eax
            imul eax,nbs_brique_x*nbs_brique_y
            add eax,level_adrs
            add eax,ebx
            pop edx
            mov al,B [eax]
            and al,type_de_brique
            cmp al,incassable
            je @@bad
            clc
            ret
@@bad:
            stc
            ret


;----------------------------------------------------------------------------
Init_Cursor:
;----------------------------------------------------------------------------

            call _Init_Cursor_player_1
            mov eax,screen_center
            sub eax,vaisseau_size_x/2
            mov cursor_1.sprite_pos_x,eax

            mov cursor_2.sprite_status,Off
            call _init_cursor_player_2
            jc @@end

            mov eax,screen_center
            add eax,screen_center/4
            sub eax,vaisseau_size_x/2
            mov cursor_1.sprite_pos_x,eax
            mov eax,screen_center
            sub eax,screen_center/4
            sub eax,vaisseau_size_x/2
            mov cursor_2.sprite_pos_x,eax
@@end:
            ret


;----------------------------------------------------------------------------
_Init_Cursor_player_1:
;----------------------------------------------------------------------------

            cmp cursor_1.sprite_adrs,vaisseau_large_1_o
            jne @@ok
            push magnetic_flag
            call reset_magnetic
            pop magnetic_flag
@@ok:
            mov cursor_1.sprite_size_x,vaisseau_size_x
            mov cursor_1.sprite_size_y,vaisseau_size_y
            mov cursor_1.sprite_adrs,vaisseau_1_o
            push cursor_1.sprite_adrs
            pop cursor_1.sprite_current_adrs
            mov cursor_1.sprite_min_x,bord_x
            mov eax,limite_x
            sub eax,cursor_1.sprite_size_x
            mov cursor_1.sprite_max_x,eax
            mov cursor_1.sprite_min_y,limite_y
            mov cursor_1.sprite_max_y,limite_y
            mov cursor_1.sprite_pos_y,limite_y
            mov cursor_1.sprite_status,On

            mov cursor_1.sprite_nbs_shape,4
            mov cursor_1.sprite_current_shape,1
            mov cursor_1.sprite_shape_speed,5
            mov cursor_1.sprite_current_speed,5
            mov cursor_1.sprite_next_shape,0

            mov cursor_1_tir_left.sprite_size_x,vaisseau_tir_size_x
            mov cursor_1_tir_left.sprite_size_y,vaisseau_tir_size_y
            mov cursor_1_tir_left.sprite_status,Off
            mov cursor_1_tir_left.sprite_next_shape,vaisseau_tir_next_shape

            mov cursor_1_tir_right.sprite_size_x,vaisseau_tir_size_x
            mov cursor_1_tir_right.sprite_size_y,vaisseau_tir_size_y
            mov cursor_1_tir_right.sprite_status,Off
            mov cursor_1_tir_right.sprite_next_shape,vaisseau_tir_next_shape

            mov cursor_1_tir_big.sprite_size_x,vaisseau_tir_big_size_x
            mov cursor_1_tir_big.sprite_size_y,vaisseau_tir_big_size_y
            mov cursor_1_tir_big.sprite_status,Off
            mov cursor_1_tir_big.sprite_next_shape,vaisseau_tir_big_next_shape

            ret


;----------------------------------------------------------------------------
_Init_Cursor_player_2:
;----------------------------------------------------------------------------

            cmp nbs_player,2
            jne @@end

            cmp cursor_2.sprite_adrs,vaisseau_large_2_o
            jne @@ok
            push magnetic_flag
            call reset_magnetic
            pop magnetic_flag
@@ok:
            mov cursor_2.sprite_size_x,vaisseau_size_x
            mov cursor_2.sprite_size_y,vaisseau_size_y
            mov cursor_2.sprite_adrs,vaisseau_2_o
            push cursor_2.sprite_adrs
            pop cursor_2.sprite_current_adrs
            mov cursor_2.sprite_min_x,bord_x
            mov eax,limite_x
            sub eax,cursor_2.sprite_size_x
            mov cursor_2.sprite_max_x,eax
            mov cursor_2.sprite_min_y,limite_y
            mov cursor_2.sprite_max_y,limite_y
            mov cursor_2.sprite_pos_y,limite_y
            mov cursor_2.sprite_status,On

            mov cursor_2.sprite_nbs_shape,4
            mov cursor_2.sprite_current_shape,1
            mov cursor_2.sprite_shape_speed,5
            mov cursor_2.sprite_current_speed,5
            mov cursor_2.sprite_next_shape,0

            mov cursor_2_tir_left.sprite_size_x,vaisseau_tir_size_x
            mov cursor_2_tir_left.sprite_size_y,vaisseau_tir_size_y
            mov cursor_2_tir_left.sprite_status,Off
            mov cursor_2_tir_left.sprite_next_shape,vaisseau_tir_next_shape

            mov cursor_2_tir_right.sprite_size_x,vaisseau_tir_size_x
            mov cursor_2_tir_right.sprite_size_y,vaisseau_tir_size_y
            mov cursor_2_tir_right.sprite_status,Off
            mov cursor_2_tir_right.sprite_next_shape,vaisseau_tir_next_shape

            mov cursor_2_tir_big.sprite_size_x,vaisseau_tir_big_size_x
            mov cursor_2_tir_big.sprite_size_y,vaisseau_tir_big_size_y
            mov cursor_2_tir_big.sprite_status,Off
            mov cursor_2_tir_big.sprite_next_shape,vaisseau_tir_big_next_shape

            clc
            ret

@@end:
            stc
            ret


;----------------------------------------------------------------------------
Detect_Shoot_player_1:
;----------------------------------------------------------------------------

            cmp game_mode,PLAYING
            jne @@end
            cmp player_1.player_current_option,option_mini_shoot_o
            je @@ok
            cmp player_1.player_current_option,option_shoot_o
            jne @@end2
            je @@ok22

@@ok:
            call clear_cannon_big
            mov cursor_1_tir_left.sprite_status,On
            mov cursor_1_tir_right.sprite_status,On
            jmp @@ok23

@@ok22:
            call clear_cannon
            mov cursor_1_tir_big.sprite_status,On
@@ok23:


            cmp count_tir_left_1,0
            je @@co
            dec count_tir_left_1
            cmp count_tir_left_1,0
            jne @@co
                        mov cursor_1_tir_left.sprite_nbs_shape,1
            @@co:

            cmp count_tir_right_1,0
            je @@co2
            dec count_tir_right_1
            cmp count_tir_right_1,0
            jne @@co2
                        mov cursor_1_tir_right.sprite_nbs_shape,1
            @@co2:

            cmp count_tir_big_1,0
            je @@co3
            dec count_tir_big_1
            cmp count_tir_big_1,0
            jne @@co3
                        mov cursor_1_tir_big.sprite_nbs_shape,1
            @@co3:



            cmp computer_flag,On
            je @@player
            cmp demo_flag,On
            je @@auto_shoot
@@player:
            call read_click_player_1
            jz @@end
            cmp player_1.player_click_flag,On
            je @@click_on
            jne @@shoot
@@auto_shoot:
            cmp delai_auto_shoot_player_1,10
            jbe @@click_on
            mov delai_auto_shoot_player_1,0
@@shoot:

            lea edx,shoot_1
@@loop:
            cmp [edx.sprite_mode],shoot
            jne @@end
            cmp [edx.sprite_status],On
            je @@next

            play_sound iff_shoot

            mov [edx.sprite_status],On
            mov [edx.sprite_sens_x],0
            mov [edx.sprite_sens_y],-4
            mov [edx.sprite_angle],0
            mov eax,cursor_1.sprite_pos_y
                        sub eax,vaisseau_tir_size_y
            mov [edx.sprite_pos_y],eax

            cmp player_1.player_current_option,option_shoot_o
            jne @@ok1

            mov [edx.sprite_size_x],shoot_size_x
            mov [edx.sprite_size_y],shoot_size_y
            mov [edx.sprite_adrs],shoot_o
            mov [edx.sprite_rebond],Off
            mov current_option,off
            mov player_1.player_current_option,Off
            mov eax,cursor_1.sprite_pos_x
            mov ebx,cursor_1.sprite_size_x
            sub ebx,[edx.sprite_size_x]
            shr ebx,1
            add eax,ebx
            mov [edx.sprite_pos_x],eax

            mov panel_option.sprite_adrs,option_off
            mov panel_option.sprite_current_adrs,option_off
            mov last_print,-1

            mov [edx.sprite_player],O player_1

            mov [edx.sprite_nbs_shape],shoot_nbs_anim
            mov [edx.sprite_current_shape],shoot_nbs_anim
            mov [edx.sprite_shape_speed],shoot_speed
            mov [edx.sprite_current_speed],shoot_speed
            mov [edx.sprite_next_shape],shoot_next

@@ok1:

            cmp player_1.player_current_option,option_mini_shoot_o
            jne @@ok2

            mov [edx.sprite_size_x],mini_shoot_size_x
            mov [edx.sprite_size_y],mini_shoot_size_y
            mov [edx.sprite_adrs],mini_shoot_o
            mov [edx.sprite_rebond],On
            mov [edx.sprite_player],O player_1
            mov [edx.sprite_nbs_shape],1
            mov [edx.sprite_current_shape],1
            mov [edx.sprite_shape_speed],1
            mov [edx.sprite_current_speed],1
            mov [edx.sprite_next_shape],1
            mov eax,cursor_1.sprite_pos_x
            xor player_1.player_left_or_right,On
            cmp player_1.player_left_or_right,On
            je @@cont
                        add eax,vaisseau_decal_x_r+6
                        mov cursor_1_tir_right.sprite_shape_speed,vaisseau_tir_speed
                        mov cursor_1_tir_right.sprite_current_speed,vaisseau_tir_speed
                        mov cursor_1_tir_right.sprite_adrs,vaisseau_1_tir_right_o
                        push cursor_1_tir_right.sprite_adrs
                        pop cursor_1_tir_right.sprite_current_adrs
                        mov cursor_1_tir_right.sprite_nbs_shape,vaisseau_tir_nbs_anim
                        mov cursor_1_tir_right.sprite_current_shape,1
                        mov count_tir_right_1,12
                        jmp @@cont2
@@cont:
                        add eax,vaisseau_decal_x_l
                        mov cursor_1_tir_left.sprite_shape_speed,vaisseau_tir_speed
                        mov cursor_1_tir_left.sprite_current_speed,vaisseau_tir_speed
                        mov cursor_1_tir_left.sprite_adrs,vaisseau_1_tir_left_o
                        push cursor_1_tir_left.sprite_adrs
                        pop cursor_1_tir_left.sprite_current_adrs
                        mov cursor_1_tir_left.sprite_nbs_shape,vaisseau_tir_nbs_anim
                        mov cursor_1_tir_left.sprite_current_shape,1
                        mov count_tir_left_1,12
@@cont2:
            mov [edx.sprite_pos_x],eax
@@ok2:

            push [edx.sprite_adrs]
            pop [edx.sprite_current_adrs]

            mov [edx.sprite_min_x],bord_x

            mov eax,limite_x
            sub eax,[edx.sprite_size_x]
            mov [edx.sprite_max_x],eax

            mov [edx.sprite_min_y],bord_y

            mov eax,screen_y
            sub eax,[edx.sprite_size_y]
            mov [edx.sprite_max_y],eax

            mov player_1.player_click_flag,On
            ret

@@click_on:
            ret
@@end2:
            call clear_cannon
            call clear_cannon_big
@@end:
            mov player_1.player_click_flag,Off
            ret
@@next:
            add edx,size struc_sprites
            jmp @@loop


clear_cannon:
            mov init_mini_shoot_flag_1,Off
            cmp cursor_1_tir_left.sprite_status,On
            jne @@end
            mov [cursor_1_tir_left.sprite_status],Off
            mov [cursor_1_tir_right.sprite_status],Off
            mov [cursor_1_tir_left.sprite_delete],2
            mov [cursor_1_tir_right.sprite_delete],2
@@end:
            ret

clear_cannon_big:
            mov init_big_shoot_flag_1,Off
            cmp cursor_1_tir_big.sprite_status,On
            jne @@end
            mov [cursor_1_tir_big.sprite_status],Off
            mov [cursor_1_tir_big.sprite_delete],2
@@end:
            ret

count_tir_left_1         dd 0
count_tir_right_1        dd 0
count_tir_big_1            dd 0


;----------------------------------------------------------------------------
Detect_Shoot_player_2:
;----------------------------------------------------------------------------

            cmp nbs_player,2
            jne @@end
            cmp game_mode,PLAYING
            jne @@end
            cmp player_2.player_current_option,option_mini_shoot_o
            je @@ok
            cmp player_2.player_current_option,option_shoot_o
            jne @@end2
            je @@ok22

@@ok:
            call clear_cannon_big_2
            mov cursor_2_tir_left.sprite_status,On
            mov cursor_2_tir_right.sprite_status,On
            jmp @@ok23

@@ok22:
            call clear_cannon_2
            mov cursor_2_tir_big.sprite_status,On
@@ok23:

            cmp count_tir_left_2,0
            je @@co
            dec count_tir_left_2
            cmp count_tir_left_2,0
            jne @@co
                        mov cursor_2_tir_left.sprite_nbs_shape,1
            @@co:

            cmp count_tir_right_2,0
            je @@co2
            dec count_tir_right_2
            cmp count_tir_right_2,0
            jne @@co2
                        mov cursor_2_tir_right.sprite_nbs_shape,1
            @@co2:

            cmp count_tir_big_2,0
            je @@co3
            dec count_tir_big_2
            cmp count_tir_big_2,0
            jne @@co3
                        mov cursor_2_tir_big.sprite_nbs_shape,1
            @@co3:



            cmp demo_flag,On
            je @@auto_shoot

            call read_click_player_2
            jz @@end
            cmp player_2.player_click_flag,On
            je @@click_on
            jne @@shoot
@@auto_shoot:
            cmp delai_auto_shoot_player_2,10
            jbe @@click_on
            mov delai_auto_shoot_player_2,0
@@shoot:

            lea edx,shoot_1
@@loop:
            cmp [edx.sprite_mode],shoot
            jne @@end
            cmp [edx.sprite_status],On
            je @@next

            play_sound iff_shoot

            mov [edx.sprite_status],On
            mov [edx.sprite_sens_x],0
            mov [edx.sprite_sens_y],-4
            mov [edx.sprite_angle],0
            mov eax,cursor_2.sprite_pos_y
                        sub eax,vaisseau_tir_size_y
            mov [edx.sprite_pos_y],eax

            cmp player_2.player_current_option,option_shoot_o
            jne @@ok1

            mov [edx.sprite_size_x],shoot_size_x
            mov [edx.sprite_size_y],shoot_size_y
            mov [edx.sprite_adrs],shoot_o
            mov [edx.sprite_rebond],Off
            mov current_option,off
            mov player_2.player_current_option,Off
            mov eax,cursor_2.sprite_pos_x
            mov ebx,cursor_2.sprite_size_x
            sub ebx,[edx.sprite_size_x]
            shr ebx,1
            add eax,ebx
            mov [edx.sprite_pos_x],eax

            mov panel_option.sprite_adrs,option_off
            mov panel_option.sprite_current_adrs,option_off
            mov last_print,-1

            mov [edx.sprite_player],O player_2

            mov [edx.sprite_nbs_shape],shoot_nbs_anim
            mov [edx.sprite_current_shape],shoot_nbs_anim
            mov [edx.sprite_shape_speed],shoot_speed
            mov [edx.sprite_current_speed],shoot_speed
            mov [edx.sprite_next_shape],shoot_next

@@ok1:

            cmp player_2.player_current_option,option_mini_shoot_o
            jne @@ok2

            mov [edx.sprite_size_x],mini_shoot_size_x
            mov [edx.sprite_size_y],mini_shoot_size_y
            mov [edx.sprite_adrs],mini_shoot_o
            mov [edx.sprite_rebond],On
            mov [edx.sprite_player],O player_2
            mov [edx.sprite_nbs_shape],1
            mov [edx.sprite_current_shape],1
            mov [edx.sprite_shape_speed],1
            mov [edx.sprite_current_speed],1
            mov [edx.sprite_next_shape],1
            mov eax,cursor_2.sprite_pos_x
            xor player_2.player_left_or_right,On
            cmp player_2.player_left_or_right,On
            je @@cont
                        add eax,vaisseau_decal_x_r+6
                        mov cursor_2_tir_right.sprite_shape_speed,vaisseau_tir_speed
                        mov cursor_2_tir_right.sprite_current_speed,vaisseau_tir_speed
                        mov cursor_2_tir_right.sprite_adrs,vaisseau_2_tir_right_o
                        push cursor_2_tir_right.sprite_adrs
                        pop cursor_2_tir_right.sprite_current_adrs
                        mov cursor_2_tir_right.sprite_nbs_shape,vaisseau_tir_nbs_anim
                        mov cursor_2_tir_right.sprite_current_shape,1
                        mov count_tir_right_2,12
                        jmp @@cont2
@@cont:
                        add eax,vaisseau_decal_x_l
                        mov cursor_2_tir_left.sprite_shape_speed,vaisseau_tir_speed
                        mov cursor_2_tir_left.sprite_current_speed,vaisseau_tir_speed
                        mov cursor_2_tir_left.sprite_adrs,vaisseau_2_tir_left_o
                        push cursor_2_tir_left.sprite_adrs
                        pop cursor_2_tir_left.sprite_current_adrs
                        mov cursor_2_tir_left.sprite_nbs_shape,vaisseau_tir_nbs_anim
                        mov cursor_2_tir_left.sprite_current_shape,1
                        mov count_tir_left_2,12
@@cont2:
            mov [edx.sprite_pos_x],eax
@@ok2:

            push [edx.sprite_adrs]
            pop [edx.sprite_current_adrs]

            mov [edx.sprite_min_x],bord_x

            mov eax,limite_x
            sub eax,[edx.sprite_size_x]
            mov [edx.sprite_max_x],eax

            mov [edx.sprite_min_y],bord_y

            mov eax,screen_y
            sub eax,[edx.sprite_size_y]
            mov [edx.sprite_max_y],eax

            mov player_2.player_click_flag,On
@@click_on:
            ret
@@end2:
            call clear_cannon_2
            call clear_cannon_big_2
@@end:
            mov player_2.player_click_flag,Off
            ret
@@next:
            add edx,size struc_sprites
            jmp @@loop

clear_cannon_2:
            mov init_mini_shoot_flag_2,Off
            cmp cursor_2_tir_left.sprite_status,On
            jne @@end
            mov [cursor_2_tir_left.sprite_status],Off
            mov [cursor_2_tir_right.sprite_status],Off
            mov [cursor_2_tir_left.sprite_delete],2
            mov [cursor_2_tir_right.sprite_delete],2
@@end:
            ret

clear_cannon_big_2:
            mov init_big_shoot_flag_2,Off
            cmp cursor_2_tir_big.sprite_status,On
            jne @@end
            mov [cursor_2_tir_big.sprite_status],Off
            mov [cursor_2_tir_big.sprite_delete],2
@@end:
            ret

count_tir_left_2         dd 0
count_tir_right_2        dd 0
count_tir_big_2          dd 0


;----------------------------------------------------------------------------
Detect_Collision_Cursor:
;----------------------------------------------------------------------------

            cmp nbs_player,2
            jne @@end
            cmp game_mode,PLAYING
            jne @@end
            cmp current_option,option_collision_o
            jne @@ok
            cmp collision_flag,0
            js @@inverse

            mov eax,cursor_1.sprite_pos_x
            add eax,cursor_1.sprite_size_x
            mov cursor_2.sprite_min_x,eax

            mov ebx,cursor_2.sprite_pos_x
            sub ebx,cursor_1.sprite_size_x
            mov cursor_1.sprite_max_x,ebx
@@end:
            ret
@@ok:
            mov cursor_2.sprite_min_x,bord_x
            mov cursor_1.sprite_min_x,bord_x

            mov eax,limite_x
            sub eax,cursor_2.sprite_size_x
            mov cursor_2.sprite_max_x,eax

            mov eax,limite_x
            sub eax,cursor_1.sprite_size_x
            mov cursor_1.sprite_max_x,eax
            ret

@@inverse:
            mov eax,cursor_2.sprite_pos_x
            add eax,cursor_2.sprite_size_x
            mov cursor_1.sprite_min_x,eax

            mov ebx,cursor_1.sprite_pos_x
            sub ebx,cursor_2.sprite_size_x
            mov cursor_2.sprite_max_x,ebx
            ret

            .data
collision_flag      dd ?
            .code


;----------------------------------------------------------------------------
Init_Cursor_Game_Over:
;----------------------------------------------------------------------------

            pushad

            cmp cursor_1_tir_left.sprite_status,On
            jne @@o1
            mov [cursor_1_tir_left.sprite_status],Off
            mov [cursor_1_tir_right.sprite_status],Off
            mov [cursor_1_tir_left.sprite_delete],2
            mov [cursor_1_tir_right.sprite_delete],2
@@o1:
            cmp cursor_2_tir_left.sprite_status,On
            jne @@o2
            mov [cursor_2_tir_left.sprite_status],Off
            mov [cursor_2_tir_right.sprite_status],Off
            mov [cursor_2_tir_left.sprite_delete],2
            mov [cursor_2_tir_right.sprite_delete],2
@@o2:
            cmp cursor_1_tir_big.sprite_status,On
            jne @@o3
            mov [cursor_1_tir_big.sprite_status],Off
            mov [cursor_1_tir_big.sprite_delete],2
@@o3:
            cmp cursor_2_tir_big.sprite_status,On
            jne @@o4
            mov [cursor_2_tir_big.sprite_status],Off
            mov [cursor_2_tir_big.sprite_delete],2
@@o4:
            cmp [ebp.sprite_adrs],vaisseau_1_o
            jne @@ok1
            mov ecx,vaisseau_explo_1_size_x
            mov edx,vaisseau_explo_1_o
            mov ebx,vaisseau_explo_1_sub_x
@@ok1:
            cmp [ebp.sprite_adrs],vaisseau_2_o
            jne @@ok2
            mov ecx,vaisseau_explo_2_size_x
            mov edx,vaisseau_explo_2_o
            mov ebx,vaisseau_explo_2_sub_x
@@ok2:
            cmp [ebp.sprite_adrs],vaisseau_large_1_o
            jne @@ok3
            mov ecx,vaisseau_explo_large_1_size_x
            mov edx,vaisseau_explo_large_1_o
            mov ebx,vaisseau_explo_large_1_sub_x
@@ok3:
            cmp [ebp.sprite_adrs],vaisseau_large_2_o
            jne @@ok4
            mov ecx,vaisseau_explo_large_2_size_x
            mov edx,vaisseau_explo_large_2_o
            mov ebx,vaisseau_explo_large_2_sub_x
@@ok4:
            cmp [ebp.sprite_adrs],vaisseau_small_1_o
            jne @@ok5
            mov ecx,vaisseau_explo_small_1_size_x
            mov edx,vaisseau_explo_small_1_o
            mov ebx,vaisseau_explo_small_1_sub_x
@@ok5:
            cmp [ebp.sprite_adrs],vaisseau_small_2_o
            jne @@ok6
            mov ecx,vaisseau_explo_small_2_size_x
            mov edx,vaisseau_explo_small_2_o
            mov ebx,vaisseau_explo_small_2_sub_x
@@ok6:
            mov [ebp.sprite_size_x],ecx
            mov [ebp.sprite_size_y],vaisseau_explo_size_y
            mov [ebp.sprite_adrs],edx
            push [ebp.sprite_adrs]
            pop [ebp.sprite_current_adrs]

            mov eax,[ebp.sprite_pos_x]
            sub eax,ebx
            mov [ebp.sprite_min_x],eax
            mov [ebp.sprite_max_x],eax

            mov [ebp.sprite_min_y],limite_y-vaisseau_explo_sub_y
            mov [ebp.sprite_max_y],limite_y-vaisseau_explo_sub_y
            sub [ebp.sprite_pos_x],ebx
            mov [ebp.sprite_pos_y],limite_y-vaisseau_explo_sub_y
            mov [ebp.sprite_status],On

            mov [ebp.sprite_nbs_shape],vaisseau_explo_nbs_anim
            mov [ebp.sprite_current_shape],1
            mov [ebp.sprite_shape_speed],vaisseau_explo_speed
            mov [ebp.sprite_current_speed],vaisseau_explo_speed

            mov eax,vaisseau_explo_next_shape
            sub eax,ecx
            mov [ebp.sprite_next_shape],eax

            popad
            ret


;----------------------------------------------------------------------------
Init_Cursor_Telepod:
;----------------------------------------------------------------------------

            pushad

            cmp cursor_1_tir_left.sprite_status,On
            jne @@o1
            mov [cursor_1_tir_left.sprite_status],Off
            mov [cursor_1_tir_right.sprite_status],Off
            mov [cursor_1_tir_left.sprite_delete],2
            mov [cursor_1_tir_right.sprite_delete],2
@@o1:
            cmp cursor_2_tir_left.sprite_status,On
            jne @@o2
            mov [cursor_2_tir_left.sprite_status],Off
            mov [cursor_2_tir_right.sprite_status],Off
            mov [cursor_2_tir_left.sprite_delete],2
            mov [cursor_2_tir_right.sprite_delete],2
@@o2:
            cmp cursor_1_tir_big.sprite_status,On
            jne @@o3
            mov [cursor_1_tir_big.sprite_status],Off
            mov [cursor_1_tir_big.sprite_delete],2
@@o3:
            cmp cursor_2_tir_big.sprite_status,On
            jne @@o4
            mov [cursor_2_tir_big.sprite_status],Off
            mov [cursor_2_tir_big.sprite_delete],2
@@o4:
            cmp init_cursor_flag,On
            jne @@cont1

            cmp [ebp.sprite_adrs],vaisseau_1_o
            jne @@ok11
            mov ecx,vaisseau_telepod_red_on_size_x
            mov edx,vaisseau_telepod_red_on_o
            mov ebx,vaisseau_telepod_red_on_sub_x
@@ok11:
            cmp [ebp.sprite_adrs],vaisseau_2_o
            jne @@ok22
            mov ecx,vaisseau_telepod_green_on_size_x
            mov edx,vaisseau_telepod_green_on_o
            mov ebx,vaisseau_telepod_green_on_sub_x
@@ok22:
@@cont1:
            cmp init_cursor_flag,Off
            jne @@cont2

            cmp [ebp.sprite_adrs],vaisseau_1_o
            jne @@ok1
            mov ecx,vaisseau_telepod_red_off_size_x
            mov edx,vaisseau_telepod_red_off_o
            mov ebx,vaisseau_telepod_red_off_sub_x
@@ok1:
            cmp [ebp.sprite_adrs],vaisseau_2_o
            jne @@ok2
            mov ecx,vaisseau_telepod_green_off_size_x
            mov edx,vaisseau_telepod_green_off_o
            mov ebx,vaisseau_telepod_green_off_sub_x
@@ok2:
            cmp [ebp.sprite_adrs],vaisseau_large_1_o
            jne @@ok3
            mov ecx,vaisseau_telepod_red_large_size_x
            mov edx,vaisseau_telepod_red_large_o
            mov ebx,vaisseau_telepod_red_large_sub_x
@@ok3:
            cmp [ebp.sprite_adrs],vaisseau_large_2_o
            jne @@ok4
            mov ecx,vaisseau_telepod_green_large_size_x
            mov edx,vaisseau_telepod_green_large_o
            mov ebx,vaisseau_telepod_green_large_sub_x
@@ok4:
            cmp [ebp.sprite_adrs],vaisseau_small_1_o
            jne @@ok5
            mov ecx,vaisseau_telepod_red_small_size_x
            mov edx,vaisseau_telepod_red_small_o
            mov ebx,vaisseau_telepod_red_small_sub_x
@@ok5:
            cmp [ebp.sprite_adrs],vaisseau_small_2_o
            jne @@ok6
            mov ecx,vaisseau_telepod_green_small_size_x
            mov edx,vaisseau_telepod_green_small_o
            mov ebx,vaisseau_telepod_green_small_sub_x
@@ok6:
@@cont2:
            mov [ebp.sprite_size_x],ecx
            mov [ebp.sprite_size_y],vaisseau_telepod_size_y
            mov [ebp.sprite_adrs],edx
            push [ebp.sprite_adrs]
            pop [ebp.sprite_current_adrs]

            mov eax,[ebp.sprite_pos_x]
            sub eax,ebx
            mov [ebp.sprite_min_x],eax
            mov [ebp.sprite_max_x],eax

            mov [ebp.sprite_min_y],limite_y-vaisseau_telepod_sub_y
            mov [ebp.sprite_max_y],limite_y-vaisseau_telepod_sub_y
            sub [ebp.sprite_pos_x],ebx
            mov [ebp.sprite_pos_y],limite_y-vaisseau_telepod_sub_y
            mov [ebp.sprite_status],On

            mov [ebp.sprite_nbs_shape],vaisseau_telepod_nbs_anim
            mov [ebp.sprite_current_shape],1
            mov [ebp.sprite_shape_speed],vaisseau_telepod_speed
            mov [ebp.sprite_current_speed],vaisseau_telepod_speed

            mov eax,vaisseau_telepod_next_shape
            sub eax,ecx
            mov [ebp.sprite_next_shape],eax

            popad
            ret


;----------------------------------------------------------------------------
Detect_Large_Cursor_player_1:
;----------------------------------------------------------------------------

            cmp game_mode,PLAYING
            jne @@end

            cmp cursor_1.sprite_adrs,vaisseau_large_1_o
            je @@init_cursor
            cmp cursor_1.sprite_adrs,vaisseau_large_1_o+vaisseau_large_size_x
            je @@init_cursor

            cmp player_1.player_current_option,option_large_ship_o
            jne @@end

            play_sound iff_large

            mov cursor_1.sprite_size_x,vaisseau_large_size_x
            mov cursor_1.sprite_size_y,vaisseau_large_size_y
            mov cursor_1.sprite_adrs,vaisseau_large_1_o
            push cursor_1.sprite_adrs
            pop  cursor_1.sprite_current_adrs
            mov cursor_1.sprite_min_x,bord_x
            mov eax,limite_x
            sub eax,cursor_1.sprite_size_x
            mov cursor_1.sprite_max_x,eax
            mov cursor_1.sprite_min_y,limite_y
            mov cursor_1.sprite_max_y,limite_y
            mov cursor_1.sprite_pos_y,limite_y
            mov cursor_1.sprite_status,On

            mov cursor_1.sprite_nbs_shape,2
            mov cursor_1.sprite_current_shape,1
            mov cursor_1.sprite_shape_speed,10
            mov cursor_1.sprite_current_speed,10
            mov cursor_1.sprite_next_shape,0
            ret

@@init_cursor:
            cmp player_1.player_current_option,option_large_ship_o
            je @@end
            cmp cursor_1.sprite_adrs,vaisseau_large_1_o+vaisseau_large_size_x
            je @@end
            call _init_cursor_player_1
@@end:
            ret


;----------------------------------------------------------------------------
Detect_Small_Cursor_player_1:
;----------------------------------------------------------------------------

            cmp game_mode,PLAYING
            jne @@end

            cmp cursor_1.sprite_adrs,vaisseau_small_1_o
            je @@init_cursor

            cmp player_1.player_current_option,option_small_ship_o
            jne @@end

            play_sound iff_small

            push magnetic_flag
            call reset_magnetic
            pop magnetic_flag

            mov cursor_1.sprite_size_x,vaisseau_small_size_x
            mov cursor_1.sprite_size_y,vaisseau_small_size_y
            mov cursor_1.sprite_adrs,vaisseau_small_1_o
            push cursor_1.sprite_adrs
            pop  cursor_1.sprite_current_adrs
            mov cursor_1.sprite_min_x,bord_x
            mov eax,limite_x
            sub eax,cursor_1.sprite_size_x
            mov cursor_1.sprite_max_x,eax
            mov cursor_1.sprite_min_y,limite_y
            mov cursor_1.sprite_max_y,limite_y
            mov cursor_1.sprite_pos_y,limite_y
            mov cursor_1.sprite_status,On

            mov cursor_1.sprite_nbs_shape,2
            mov cursor_1.sprite_current_shape,1
            mov cursor_1.sprite_shape_speed,8
            mov cursor_1.sprite_current_speed,8
            mov cursor_1.sprite_next_shape,0
            ret

@@init_cursor:
            cmp player_1.player_current_option,option_small_ship_o
            je @@end
            call _init_cursor_player_1
@@end:
            ret


;----------------------------------------------------------------------------
Detect_Large_Cursor_player_2:
;----------------------------------------------------------------------------

            cmp nbs_player,2
            jne @@end

            cmp game_mode,PLAYING
            jne @@end

            cmp cursor_2.sprite_adrs,vaisseau_large_2_o
            je @@init_cursor
            cmp cursor_2.sprite_adrs,vaisseau_large_2_o+vaisseau_large_size_x
            je @@init_cursor

            cmp player_2.player_current_option,option_large_ship_o
            jne @@end

            play_sound iff_large

            mov cursor_2.sprite_size_x,vaisseau_large_size_x
            mov cursor_2.sprite_size_y,vaisseau_large_size_y
            mov cursor_2.sprite_adrs,vaisseau_large_2_o
            push cursor_2.sprite_adrs
            pop  cursor_2.sprite_current_adrs
            mov cursor_2.sprite_min_x,bord_x
            mov eax,limite_x
            sub eax,cursor_2.sprite_size_x
            mov cursor_2.sprite_max_x,eax
            mov cursor_2.sprite_min_y,limite_y
            mov cursor_2.sprite_max_y,limite_y
            mov cursor_2.sprite_pos_y,limite_y
            mov cursor_2.sprite_status,On

            mov cursor_2.sprite_nbs_shape,2
            mov cursor_2.sprite_current_shape,1
            mov cursor_2.sprite_shape_speed,10
            mov cursor_2.sprite_current_speed,10
            mov cursor_2.sprite_next_shape,0
            ret

@@init_cursor:
            cmp player_2.player_current_option,option_large_ship_o
            je @@end
            cmp cursor_2.sprite_adrs,vaisseau_large_2_o+vaisseau_large_size_x
            je @@end
            call _init_cursor_player_2
@@end:
            ret


;----------------------------------------------------------------------------
Detect_Small_Cursor_player_2:
;----------------------------------------------------------------------------

            cmp nbs_player,2
            jne @@end

            cmp game_mode,PLAYING
            jne @@end

            cmp cursor_2.sprite_adrs,vaisseau_small_2_o
            je @@init_cursor

            cmp player_2.player_current_option,option_small_ship_o
            jne @@end

            play_sound iff_small

            push magnetic_flag
            call reset_magnetic
            pop magnetic_flag

            mov cursor_2.sprite_size_x,vaisseau_small_size_x
            mov cursor_2.sprite_size_y,vaisseau_small_size_y
            mov cursor_2.sprite_adrs,vaisseau_small_2_o
            push cursor_2.sprite_adrs
            pop  cursor_2.sprite_current_adrs
            mov cursor_2.sprite_min_x,bord_x
            mov eax,limite_x
            sub eax,cursor_2.sprite_size_x
            mov cursor_2.sprite_max_x,eax
            mov cursor_2.sprite_min_y,limite_y
            mov cursor_2.sprite_max_y,limite_y
            mov cursor_2.sprite_pos_y,limite_y
            mov cursor_2.sprite_status,On

            mov cursor_2.sprite_nbs_shape,2
            mov cursor_2.sprite_current_shape,1
            mov cursor_2.sprite_shape_speed,8
            mov cursor_2.sprite_current_speed,8
            mov cursor_2.sprite_next_shape,0
            ret

@@init_cursor:
            cmp player_2.player_current_option,option_small_ship_o
            je @@end
            call _init_cursor_player_2
@@end:
            ret


;----------------------------------------------------------------------------
Init_First_Ball:
;----------------------------------------------------------------------------

            lea edx,Ball_1
            lea ebp,player_1
            call init_ball

                        cmp nbs_player,2
                        jne @@cont
                        lea edx,Ball_2
                        lea ebp,player_2
                        call init_ball
            @@cont:

            cmp computer_flag,On
            je @@ok
            cmp demo_flag,On
            je @@demo
@@ok:
            cmp game_mode,READY_TO_PLAY_AGAIN
            je @@end

            mov game_mode,READY_TO_PLAY
            lea esi,option_text_ready
            call print
@@end:
            ret
@@demo:
            mov ball_1.sprite_status,On
            mov ball_1.sprite_sens_x,+3
            mov ball_1.sprite_sens_y,-4

            cmp nbs_player,2
            jne @@end
            mov ball_2.sprite_status,On
            mov ball_2.sprite_sens_x,-3
            mov ball_2.sprite_sens_y,-4
            ret


;----------------------------------------------------------------------------
Init_Ball:
;----------------------------------------------------------------------------

                        mov [edx.sprite_player],ebp
                        mov ebp,[ebp.player_cursor]

            mov [edx.sprite_status],On
            mov [edx.sprite_ghost],Off
            mov [edx.sprite_sens_x],Off
            mov [edx.sprite_sens_y],Off
            mov [edx.sprite_angle],Off
            ; positionnement du curseur de d‚part en x
            mov eax,screen_center
            mov ebx,[ebp].sprite_size_x
            shr ebx,1
            sub eax,ebx
            mov [edx.sprite_pos_x],eax
            ; positionnement de la balle de d‚part en y
            mov eax,[ebp].sprite_pos_y
            mov ebx,[edx].sprite_size_y
            sub eax,ebx
            mov [edx.sprite_pos_y],eax
            mov eax,speed_delai
            mov [edx.sprite_speed_counter],eax
            mov [edx.sprite_rebond],On

            mov [edx.sprite_size_x],ball_size
            mov [edx.sprite_size_y],ball_size
            mov [edx.sprite_adrs],ball_orange_o

                        cmp dual_flag,On
                        jne @@ok
                        cmp ebp,O cursor_1
                        je @@ok
                        add [edx.sprite_adrs],9
            @@ok:

            push [edx.sprite_size_x]
            pop  [edx.sprite_old_size_x]
            push [edx.sprite_size_y]
            pop  [edx.sprite_old_size_y]
            push [edx.sprite_adrs]
            pop  [edx.sprite_current_adrs]

            mov [edx.sprite_to_delete],Off
            mov [edx.sprite_nbs_shape],1
            mov [edx.sprite_current_shape],1

            ret


;----------------------------------------------------------------------------
Refresh_Ball:
;----------------------------------------------------------------------------

            cmp game_mode,READY_TO_PLAY
            je @@end
            cmp game_mode,READY_TO_PLAY_AGAIN
            je @@end

            lea edx,Ball_1
@@loop:
            cmp [edx.sprite_status],kill
            je @@ok
            cmp [edx.sprite_mode],ball
            jne @@end
            cmp [edx.sprite_status],Off
            je @@next

            cmp current_option,option_iron_ball_o
            jne @@cont
            mov [edx.sprite_rebond],Off
            mov [edx.sprite_adrs],ball_blue_o
            mov [edx.sprite_current_adrs],ball_blue_o

                                                                        cmp [edx.sprite_ghost],On
                                                                        jne @@no_ghost
                                                                        mov [edx.sprite_adrs],ghost_ball_blue_o
                                                                        mov [edx.sprite_current_adrs],ghost_ball_blue_o
                                                            @@no_ghost:

                       cmp dual_flag,On
                       jne @@cont
                       cmp [edx.sprite_player],O player_1
                       je @@cont
                       add [edx.sprite_adrs],9
                       add [edx.sprite_current_adrs],9
@@cont:

            call detect_colision_cursor_player_1
            call detect_colision_cursor_player_2
@@ok:
            call detect_colision_wall
            call detect_colision_brique
            call detect_colision_monster

            call move_ball

            cmp current_option,option_telepod_o
            jne @@cont1
            call teleporte_ball
@@cont1:
            call detect_destruction

            call detect_inc_speed
            call detect_dec_speed
@@next:
            add edx,size struc_sprites
            jmp @@loop
@@end:
            cmp current_option,option_iron_ball_o
            je @@reset_current_option
            cmp current_option,option_telepod_o
            je @@reset_current_option
            cmp current_option,option_fast_ball_o
            je @@reset_current_option
            cmp current_option,option_slow_ball_o
            je @@reset_current_option
            ret

@@reset_current_option:
            mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            ret


;----------------------------------------------------------------------------
Refresh_Shoot:
;----------------------------------------------------------------------------

            lea edx,Shoot_1
@@loop:
            cmp [edx.sprite_mode],shoot
            jne @@end
            cmp [edx.sprite_status],Off
            je @@next
            call detect_colision_wall
            cmp game_mode,PLAYING
            jne @@cont
            call detect_colision_brique
            call detect_colision_monster
@@cont:
            call move_ball
@@next:
            add edx,size struc_sprites
            jmp @@loop
@@end:
            ret


;----------------------------------------------------------------------------
init_Monster:
;----------------------------------------------------------------------------

            mov counter_monster,Off

            ;mov eax,nbs_monster-1
            ;call get_random

            mov eax,current_level
            dec eax
            and eax,011b

            imul eax,monster_next
            add eax,monster_o
            mov current_monster_o,eax
            ret

            .data
current_monster_o       dd ?
            .code


;----------------------------------------------------------------------------
Create_Monster:
;----------------------------------------------------------------------------

            cmp game_mode,PLAYING
            jne @@end

            cmp difficulte,MEDIUM
            jne @@ok0
            mov eax,MONSTER_DELAI_MEDIUM
@@ok0:
            cmp difficulte,HARD
            jne @@ok1
            mov eax,MONSTER_DELAI_HARD
@@ok1:
            cmp difficulte,EASY
            jne @@ok2
            mov eax,MONSTER_DELAI_EASY
@@ok2:

            inc counter_monster
            cmp counter_monster,eax
            jb @@end
            call add_monster
@@end:
            ret


;----------------------------------------------------------------------------
Add_Monster:
;----------------------------------------------------------------------------

            mov counter_monster,Off

            lea edx,monster_1
@@loop:
            cmp [edx.sprite_mode],monster
            jne @@end
            cmp [edx.sprite_status],On
            je @@next
            cmp [edx.sprite_status],kill
            je @@next

            mov [edx.sprite_screen_x],monster_screen_x

            mov eax,monster_buffer
            mov [edx.sprite_buffer_adrs],eax

            mov [edx.sprite_status],On
            mov [edx.sprite_sens_x],1
            mov [edx.sprite_sens_y],1
            mov [edx.sprite_angle],0
            mov [edx.sprite_pos_y],bord_y

            mov [edx.sprite_size_x],monster_size_x
            mov [edx.sprite_size_y],monster_size_y

            mov eax,current_monster_o
            mov [edx.sprite_adrs],eax

            mov [edx.sprite_rebond],On

            push [edx.sprite_adrs]
            pop [edx.sprite_current_adrs]

            mov [edx.sprite_min_x],bord_x

            mov eax,limite_x
            sub eax,[edx.sprite_size_x]
            mov [edx.sprite_max_x],eax

            mov [edx.sprite_min_y],bord_y

            mov eax,screen_y
            sub eax,[edx.sprite_size_y]
            mov [edx.sprite_max_y],eax

            mov eax,[edx.sprite_max_x]
            sub eax,bord_x
            call get_random
            add eax,bord_x
            mov [edx.sprite_pos_x],eax

            mov [edx.sprite_nbs_shape],monster_nbs_anim
            mov [edx.sprite_current_shape],monster_nbs_anim
            mov [edx.sprite_shape_speed],monster_speed
            mov [edx.sprite_current_speed],monster_speed
            mov [edx.sprite_next_shape],1
@@end:
            ret
@@next:
            add edx,size struc_sprites
            jmp @@loop

            .data
counter_monster dd Off
            .code


;----------------------------------------------------------------------------
Del_Monster:
;----------------------------------------------------------------------------

            cmp [edx.sprite_status],kill
            je @@end
            mov [edx.sprite_status],kill

            mov [edx.sprite_sens_x],0
            mov [edx.sprite_sens_y],0
            mov [edx.sprite_angle],0
            sub [edx.sprite_pos_x],16
            sub [edx.sprite_pos_y],16
            mov [edx.sprite_size_x],explo_size_x
            mov [edx.sprite_size_y],explo_size_y
            mov eax,explo_o
            mov [edx.sprite_adrs],eax
            mov [edx.sprite_rebond],Off
            push [edx.sprite_adrs]
            pop [edx.sprite_current_adrs]
            mov [edx.sprite_min_x],bord_x
            mov eax,limite_x
            sub eax,[edx.sprite_size_x]
            mov [edx.sprite_max_x],eax
            mov [edx.sprite_min_y],bord_y
            mov eax,screen_y
            sub eax,[edx.sprite_size_y]
            mov [edx.sprite_max_y],eax

            mov [edx.sprite_to_delete],explo_nbs_anim
            add [edx.sprite_to_delete],2
            mov [edx.sprite_nbs_shape],explo_nbs_anim
            mov [edx.sprite_current_shape],1
            mov [edx.sprite_shape_speed],explo_speed
            mov [edx.sprite_current_speed],explo_speed
            mov [edx.sprite_next_shape],1
@@end:
            ret


;----------------------------------------------------------------------------
Refresh_Monster:
;----------------------------------------------------------------------------

            lea edx,Monster_1
@@loop:
            cmp [edx.sprite_mode],monster
            jne @@end
            cmp [edx.sprite_status],Off
            je @@next
            cmp [edx.sprite_status],kill
            je @@next
            call detect_colision_wall
            cmp game_mode,PLAYING
            jne @@cont
            call detect_colision_brique
            call detect_colision_cursor_player_1
            call detect_colision_cursor_player_2
@@cont:
           call move_ball

           cmp [edx.sprite_pos_y],0
           jg @@next
           inc [edx.sprite_counter_3]
           cmp [edx.sprite_counter_3],32
           jb @@next
           mov [edx.sprite_counter_3],0
           mov [edx.sprite_sens_y],-1

           ;mov eax,[edx.sprite_pos_x]
           ;send eax,15,15
           ;mov eax,[edx.sprite_pos_y]
           ;send eax,16,16
@@next:
           add edx,size struc_sprites
           jmp @@loop
@@end:
           ret


;----------------------------------------------------------------------------
detect_colision_monster:
;----------------------------------------------------------------------------

           pushad
           lea ebp,monster_1
@@loop:
           cmp [ebp.sprite_mode],monster
           jne @@end
           cmp [ebp.sprite_status],Off
           je @@next
           cmp [ebp.sprite_status],kill
           je @@next
           call _detect_colision_monster
@@next:
           add ebp,size struc_sprites
           jmp @@loop
@@end:
           popad
           ret


;----------------------------------------------------------------------------
destruction_monster:
;----------------------------------------------------------------------------

           lea edx,monster_1
@@loop:
           cmp [edx.sprite_mode],monster
           jne @@end
           cmp [edx.sprite_status],On
           jne @@next
           ;mov [edx.sprite_status],Off
           ;mov [edx.sprite_delete],2
           call del_monster
           play_sound iff_del_monster
@@next:
           add edx,size struc_sprites
           jmp @@loop
@@end:
           ret


;----------------------------------------------------------------------------
; edx=ball
; ebp=monster
_detect_colision_monster:
;----------------------------------------------------------------------------

           mov eax,[edx.sprite_pos_y]
           mov ebx,[edx.sprite_size_y]
           shr ebx,1
           add eax,ebx
           mov ebx,[ebp.sprite_pos_y]
           cmp eax,ebx
           jb @@end
           add ebx,[ebp.sprite_size_y]
           cmp eax,ebx
           ja @@end

           mov eax,[edx.sprite_pos_x]
           mov ebx,[edx.sprite_size_x]
           shr ebx,1
           add eax,ebx
           mov ebx,[ebp.sprite_pos_x]
           cmp eax,ebx
           jb @@end
           add ebx,[ebp.sprite_size_x]
           cmp eax,ebx
           ja @@end

           cmp [edx.sprite_rebond],Off
           je @@cont
           mov eax,15
           call get_random
           mov new_direction,eax
           call change_direction
@@cont:
           play_sound iff_del_monster

           push ecx
           push ebp
           mov ebp,[edx.sprite_player]
           mov ecx,3
           call inc_score
           pop ebp
           pop ecx


           ;mov [ebp.sprite_status],Off
           ;mov [ebp.sprite_delete],2
           push edx
           mov edx,ebp
           call del_monster
           pop edx
@@end:
           ret


;----------------------------------------------------------------------------
move_ball:
;----------------------------------------------------------------------------

           cmp [edx.sprite_magnetic],Off
           je @@ok
           cmp [edx.sprite_magnetic],O cursor_1
           je @@player_one
           cmp [edx.sprite_magnetic],O cursor_2
           je @@player_two
@@shoot_1:
            test magnetic_flag,PLAYER_ONE
            jz @@shoot_
            and magnetic_flag,not PLAYER_ONE
            jmp @@shoot_
@@shoot_2:
            test magnetic_flag,PLAYER_TWO
            jz @@shoot_
            and magnetic_flag,not PLAYER_TWO
@@shoot_:
           mov [edx.sprite_magnetic],Off
           mov [edx.sprite_decal_x],Off
@@ok:
           mov eax,[edx.sprite_pos_x]
           add eax,[edx.sprite_sens_x]
           mov [edx.sprite_pos_x],eax

           mov eax,[edx.sprite_pos_y]
           add eax,[edx.sprite_sens_y]
           mov [edx.sprite_pos_y],eax
@@end:
           ret

@@player_one:
            test magnetic_flag,PLAYER_ONE
            jz @@ok
           mov eax,[cursor_1.sprite_pos_x]
           add eax,[edx.sprite_decal_x]
           mov [edx.sprite_pos_x],eax
           mov eax,[cursor_1.sprite_pos_y]
           sub eax,[edx.sprite_size_y]
           mov [edx.sprite_pos_y],eax
           cmp computer_flag,On
           je @@ok2
           cmp demo_flag,On
           je @@shoot_1
@@ok2:
           push edx
           call read_click_player_1
           pop edx
           jz @@end
           jnz @@shoot_1

@@player_two:
            test magnetic_flag,PLAYER_TWO
            jz @@ok
           mov eax,[cursor_2.sprite_pos_x]
           add eax,[edx.sprite_decal_x]
           mov [edx.sprite_pos_x],eax
           mov eax,[cursor_2.sprite_pos_y]
           sub eax,[edx.sprite_size_y]
           mov [edx.sprite_pos_y],eax
           cmp demo_flag,On
           je @@shoot_2
           push edx
           call read_click_player_2
           pop edx
           jz @@end
           jnz @@shoot_2


;----------------------------------------------------------------------------
reset_magnetic:
;----------------------------------------------------------------------------

           lea edx,Ball_1
@@loop:
           cmp [edx.sprite_mode],ball
           jne @@end

           mov [edx.sprite_magnetic],Off
@@next:
           add edx,size struc_sprites
           jmp @@loop
@@end:
           mov magnetic_flag,Off
           ret

            .data
magnetic_flag dd Off
start_flag    dd Off
            .code


;----------------------------------------------------------------------------
reset_ghost:
;----------------------------------------------------------------------------

           lea edx,Ball_1
@@loop:
           cmp [edx.sprite_mode],ball
           jne @@end

           mov [edx.sprite_ghost],Off
@@next:
           add edx,size struc_sprites
           jmp @@loop
@@end:
           ret


;----------------------------------------------------------------------------
set_ghost:
;----------------------------------------------------------------------------

           lea edx,Ball_1
           mov ebp,current_player
@@loop:
           cmp [edx.sprite_mode],ball
           jne @@end
           cmp [edx.sprite_player],ebp
           jne @@next
           cmp [edx.sprite_ghost],On
           je @@next
           mov [edx.sprite_ghost],On
           add [edx.sprite_adrs],18
           add [edx.sprite_current_adrs],18
@@next:
           add edx,size struc_sprites
           jmp @@loop
@@end:
           call unghost_one_ball
           ret


;----------------------------------------------------------------------------
unghost_one_ball:
;----------------------------------------------------------------------------

           lea edx,Ball_1
           mov ebp,current_player
@@loop:
           cmp [edx.sprite_mode],ball
           jne @@end
           cmp [edx.sprite_status],On
           jne @@next
           cmp [edx.sprite_player],ebp
           jne @@next
           mov [edx.sprite_ghost],Off
           sub [edx.sprite_adrs],18
           sub [edx.sprite_current_adrs],18
           ret
@@next:
           add edx,size struc_sprites
           jmp @@loop
@@end:
           ret


;----------------------------------------------------------------------------
detect_inc_speed:
;----------------------------------------------------------------------------

            cmp [edx.sprite_sens_y],0
            jns @@cont
            dec [edx.sprite_speed_counter]
            cmp [edx.sprite_speed_counter],Off
            je @@detect_inc_speed_option
@@cont:
            cmp current_option,option_fast_ball_o
            jne @@end
@@detect_inc_speed:
            mov eax,speed_level
            mov [edx.sprite_speed_counter],eax
            call inc_speed_x
            call inc_speed_y
@@end:
            Send [edx.sprite_speed_counter],10,3
            ret

@@detect_inc_speed_option:
            play_sound iff_speed_up
            jmp @@detect_inc_speed

;----------------------------------------------------------------------------
detect_dec_speed:
;----------------------------------------------------------------------------

            cmp current_option,option_slow_ball_o
            jne @@end
            mov eax,speed_level
            mov [edx.sprite_speed_counter],eax
            call dec_speed_x
            call dec_speed_y
@@end:
            Send [edx.sprite_speed_counter],10,3
            ret


;----------------------------------------------------------------------------
inc_speed_x:
;----------------------------------------------------------------------------

            mov eax,speed_max_x
            add eax,[edx.sprite_angle]
            cmp [edx.sprite_sens_x],eax
            jge @@end
            neg eax
            cmp [edx.sprite_sens_x],eax
            jle @@end
            call detect_sens_x
            add [edx.sprite_sens_x],eax

@@end:      ret


;----------------------------------------------------------------------------
inc_speed_y:
;----------------------------------------------------------------------------

            mov eax,speed_max_y
            sub eax,[edx.sprite_angle]
            cmp [edx.sprite_sens_y],eax
            jge @@end
            neg eax
            cmp [edx.sprite_sens_y],eax
            jle @@end
            call detect_sens_y
            add [edx.sprite_sens_y],eax
@@end:      ret


;----------------------------------------------------------------------------
dec_speed_x:
;----------------------------------------------------------------------------

            mov eax,speed_min_x
            add eax,[edx.sprite_angle]
            cmp [edx.sprite_sens_x],eax
            jg @@ok
            neg eax
            cmp [edx.sprite_sens_x],eax
            jl @@ok
            ret
@@ok:
            call detect_sens_x
            sub [edx.sprite_sens_x],eax

            ret


;----------------------------------------------------------------------------
dec_speed_y:
;----------------------------------------------------------------------------

            mov eax,speed_min_y
            sub eax,[edx.sprite_angle]
            cmp [edx.sprite_sens_y],eax
            jg @@ok
            neg eax
            cmp [edx.sprite_sens_y],eax
            jl @@ok
            ret
@@ok:
            call detect_sens_y
            sub [edx.sprite_sens_y],eax
            ret


;----------------------------------------------------------------------------
detect_colision_wall:
;----------------------------------------------------------------------------

@@again_x:
           mov eax,[edx.sprite_pos_x]
           add eax,[edx.sprite_sens_x]
           cmp eax,[edx.sprite_max_x]
           jae @@inverse_sens_x
           cmp eax,[edx.sprite_min_x]
           jbe @@inverse_sens_x
           jmp @@again_y
@@inverse_sens_x:
           ;play_sound iff_wall
           cmp [edx.sprite_mode],shoot
           je @@shoot_off
           call inverse_sens_x
           jmp @@again_y

@@again_y:
           mov eax,[edx.sprite_pos_y]
           add eax,[edx.sprite_sens_y]
           cmp eax,[edx.sprite_max_y]
           jae @@inverse_sens_y
           cmp eax,[edx.sprite_min_y]
           jbe @@inverse_sens_y
           jmp @@next
@@inverse_sens_y:
           ;play_sound iff_wall
           cmp [edx.sprite_mode],shoot
           je @@shoot_off
           call inverse_sens_y
           jmp @@next
@@next:
           ret

@@shoot_off:
           mov [edx.sprite_delete],2
           mov [edx.sprite_status],off
           ret


;----------------------------------------------------------------------------
inverse_sens_xy:
;----------------------------------------------------------------------------

            call inverse_sens_x
            call inverse_sens_y
            ret


;----------------------------------------------------------------------------
inverse_sens_x:
;----------------------------------------------------------------------------

           mov eax,[edx.sprite_sens_x]
           neg eax
           mov [edx.sprite_sens_x],eax
           call detect_blocage
           ret


;----------------------------------------------------------------------------
inverse_sens_y:
;----------------------------------------------------------------------------

           mov eax,[edx.sprite_sens_y]
           neg eax
           mov [edx.sprite_sens_y],eax
           call detect_blocage
           ret


;----------------------------------------------------------------------------
calc_nbs_iteration_max:
;----------------------------------------------------------------------------

            mov eax,[edx.sprite_sens_x]
            or eax,eax
            jns @@ok1
            neg eax
@@ok1:
            mov ebx,[edx.sprite_sens_y]
            or ebx,ebx
            jns @@ok2
            neg ebx
@@ok2:
            cmp eax,ebx
            jae @@ok3
            mov eax,ebx
@@ok3:
            mov nbs_iteration_max,eax
            inc nbs_iteration_max

            cmp nbs_iteration_max,speed_max+2+angle_max
            ja @@break
            ret

@@break:
            ;Break_Point
            mov nbs_iteration_max,speed_max+2+angle_max
            ret


;----------------------------------------------------------------------------
calc_coordonnee_de_depart :
;----------------------------------------------------------------------------

            xor ebx,ebx

            mov eax,[edx.sprite_sens_x]
            or eax,eax
            jns @@ok1
            or ebx,01b
@@ok1:
            mov eax,[edx.sprite_sens_y]
            or eax,eax
            jns @@ok2
            or ebx,10b
@@ok2:
            cmp ebx,00b
            je @@mode1
            cmp ebx,11b
            je @@mode1
@@mode2:
            mov eax,[edx.sprite_pos_x]
            sal eax,16
            mov depart_x_1,eax

            mov eax,[edx.sprite_pos_y]
            sal eax,16
            mov depart_y_1,eax

            mov eax,[edx.sprite_pos_x]
            add eax,[edx.sprite_size_x]
            sal eax,16
            mov depart_x_2,eax

            mov eax,[edx.sprite_pos_y]
            add eax,[edx.sprite_size_y]
            sal eax,16
            mov depart_y_2,eax


            mov eax,[edx.sprite_pos_x]
            add eax,[edx.sprite_sens_x]
            sal eax,16
            mov dest_x_1,eax

            mov eax,[edx.sprite_pos_y]
            add eax,[edx.sprite_sens_y]
            sal eax,16
            mov dest_y_1,eax

            mov eax,[edx.sprite_pos_x]
            add eax,[edx.sprite_sens_x]
            add eax,[edx.sprite_size_x]
            sal eax,16
            mov dest_x_2,eax

            mov eax,[edx.sprite_pos_y]
            add eax,[edx.sprite_sens_y]
            add eax,[edx.sprite_size_y]
            sal eax,16
            mov dest_y_2,eax

            ret
@@mode1:
            mov eax,[edx.sprite_pos_x]
            add eax,[edx.sprite_size_x]
            sal eax,16
            mov depart_x_1,eax

            mov eax,[edx.sprite_pos_y]
            sal eax,16
            mov depart_y_1,eax

            mov eax,[edx.sprite_pos_x]
            sal eax,16
            mov depart_x_2,eax

            mov eax,[edx.sprite_pos_y]
            add eax,[edx.sprite_size_y]
            sal eax,16
            mov depart_y_2,eax


            mov eax,[edx.sprite_pos_x]
            add eax,[edx.sprite_size_x]
            add eax,[edx.sprite_sens_x]
            sal eax,16
            mov dest_x_1,eax

            mov eax,[edx.sprite_pos_y]
            add eax,[edx.sprite_sens_y]
            sal eax,16
            mov dest_y_1,eax

            mov eax,[edx.sprite_pos_x]
            add eax,[edx.sprite_sens_x]
            sal eax,16
            mov dest_x_2,eax

            mov eax,[edx.sprite_pos_y]
            add eax,[edx.sprite_size_y]
            add eax,[edx.sprite_sens_y]
            sal eax,16
            mov dest_y_2,eax

            ret


;----------------------------------------------------------------------------
create_table_de_trajectoire_axe_x :
;----------------------------------------------------------------------------

            push edx

            lea edi,table_detect.detect_table_x_1
            mov ebp,nbs_iteration_max
            mov eax,depart_x_1
            sar eax,1
            stosd
            dec ebp
@@table_x_1:
            mov eax,dest_x_1
            sub eax,depart_x_1
            cdq
            idiv ebp
            mov ebx,depart_x_1
            add ebx,eax
            mov depart_x_1,ebx
            sar ebx,16
            mov eax,ebx
            stosd
            dec ebp
            jnz @@table_x_1

            lea edi,table_detect.detect_table_x_2
            mov ebp,nbs_iteration_max
            mov eax,depart_x_2
            sar eax,1
            stosd
            dec ebp
@@table_x_2:
            mov eax,dest_x_2
            sub eax,depart_x_2
            cdq
            idiv ebp
            mov ebx,depart_x_2
            add ebx,eax
            mov depart_x_2,ebx
            sar ebx,16
            mov eax,ebx
            stosd
            dec ebp
            jnz @@table_x_2

            pop edx
            ret


;----------------------------------------------------------------------------
create_table_de_trajectoire_axe_y :
;----------------------------------------------------------------------------

            push edx

            lea edi,table_detect.detect_table_y_1
            mov ebp,nbs_iteration_max
            mov eax,depart_y_1
            sar eax,1
            stosd
            dec ebp
@@table_y_1:
            mov eax,dest_y_1
            sub eax,depart_y_1
            cdq
            idiv ebp
            mov ebx,depart_y_1
            add ebx,eax
            mov depart_y_1,ebx
            sar ebx,16
            mov eax,ebx
            stosd
            dec ebp
            jnz @@table_y_1

            lea edi,table_detect.detect_table_y_2
            mov ebp,nbs_iteration_max
            mov eax,depart_y_2
            sar eax,1
            stosd
            dec ebp
@@table_y_2:
            mov eax,dest_y_2
            sub eax,depart_y_2
            cdq
            idiv ebp
            mov ebx,depart_y_2
            add ebx,eax
            mov depart_y_2,ebx
            sar ebx,16
            mov eax,ebx
            stosd
            dec ebp
            jnz @@table_y_2

            pop edx
            ret

            .data
nbs_iteration_max   dd ?

depart_x_1          dd ?
depart_y_1          dd ?
depart_x_2          dd ?
depart_y_2          dd ?
dest_x_1            dd ?
dest_y_1            dd ?
dest_x_2            dd ?
dest_y_2            dd ?

struc_detect        struc
detect_table_x_1    dd speed_max+2+angle_max dup (0)
detect_table_y_1    dd speed_max+2+angle_max dup (0)
detect_table_x_2    dd speed_max+2+angle_max dup (0)
detect_table_y_2    dd speed_max+2+angle_max dup (0)
struc_detect        ends

table_detect        struc_detect <>
            .code


;----------------------------------------------------------------------------
detect_colision_brique:
;----------------------------------------------------------------------------

            call calc_nbs_iteration_max
            or eax,eax
            jz @@end

            call calc_coordonnee_de_depart
            call create_table_de_trajectoire_axe_x
            call create_table_de_trajectoire_axe_y

            mov new_direction,Off
            mov ecx,nbs_iteration_max
            lea edi,table_detect
@@again:
            push ecx
            xor ebp,ebp

            mov ebx,[edi.detect_table_x_1]
            mov eax,[edi.detect_table_y_1]
            call detect_brique
            jnc  @@ok1
            or ebp,01b
@@ok1:
            mov ebx,[edi.detect_table_x_2]
            mov eax,[edi.detect_table_y_2]
            call detect_brique
            jnc  @@ok2
            or ebp,10b
@@ok2:
            cmp ebp,0
            je @@cont
            cmp [edx.sprite_rebond],Off
            je @@cont
            cmp new_direction,Off
            jne @@cont

            xor ebx,ebx
            cmp [edx.sprite_sens_x],0
            jns @@ok5
            or ebx,01b
@@ok5:
            cmp [edx.sprite_sens_y],0
            jns @@ok6
            or ebx,10b
@@ok6:
            shl ebx,2
            or ebx,ebp
            mov new_direction,ebx
@@cont:
            add edi,4
            pop ecx
            loop @@again

@@end:
            call change_direction
            call clear_level_flag
            ret


;----------------------------------------------------------------------------
clear_level_flag:
;----------------------------------------------------------------------------

            pushad
            lea edi,level_flag
            mov ecx,nbs_brique_x*nbs_brique_y
            mov al,0
            rep stosb
            popad
            ret


;----------------------------------------------------------------------------
change_direction:
;----------------------------------------------------------------------------

            cmp new_direction,Off
            je @@end
            cmp [edx.sprite_mode],shoot
            je @@shoot_off

           mov eax,new_direction

            cmp eax,0001b
            je inverse_sens_x
            cmp eax,0010b
            je inverse_sens_y
            cmp eax,0101b
            je inverse_sens_x
            cmp eax,0110b
            je inverse_sens_y
            cmp eax,1001b
            je inverse_sens_y
            cmp eax,1010b
            je inverse_sens_x
            cmp eax,1101b
            je inverse_sens_y
            cmp eax,1110b
            je inverse_sens_x

            jmp inverse_sens_xy
 @@end:
            ret

@@shoot_off:
            mov [edx.sprite_delete],2
            mov [edx.sprite_status],off
            ret

            .data
new_direction dd ?
            .code


;----------------------------------------------------------------------------
detect_brique:
;----------------------------------------------------------------------------

            pushad
            cmp ebx,limite_x
            jae @@end
            cmp eax,limite_y
            jae @@end

            ;call draw_point

            sub ebx,bord_x
            or ebx,ebx
            jns @@ok1
            mov ebx,0
@@ok1:      shr ebx,5
            mov temp_x,ebx

            sub eax,bord_y
            or eax,eax
            jns @@ok2
            mov eax,0
@@ok2:      shr eax,4
            mov temp_y,eax

            imul eax,nbs_brique_x
            add ebx,eax

            lea esi,level_tbl
            mov al, B [esi+ebx]
            cmp al,absente
            je @@end
            cmp al,invalide
            je @@end
            cmp al,incassable
            jae @@collision
            cmp ebx,nbs_brique_y*nbs_brique_x
            jae @@end
            or ebx,ebx
            js @@end

            lea edi,level_flag
            cmp B [edi+ebx],On
            je @@end
            mov B [edi+ebx],On

            cmp [edx.sprite_mode],monster
            je @@exit

            dec B [esi+ebx]

            lea edi,brique_tbl

                        mov eax,D [edi+ebx*4]

            add D [edi+ebx*4],next_brique

            cmp B [esi+ebx],absente
            jne @@redraw_brique

                        push eax
                        push edx

            mov edi,temp_y
            shl edi,4
            add edi,bord_y
            mov ebx,temp_x
            shl ebx,5
            add ebx,bord_x
            mov ecx,brique_size_y
            mov edx,brique_size_x
            call erase_shape

                        pop edx

            push ecx
            push ebp
            mov ecx,1
            mov ebp,[edx.sprite_player]
            call inc_score
            pop ebp
            pop ecx

            call random_options

            play_sound iff_normale

                        pop eax
                        cmp D eax,brique_transp_o+(next_color*0)
                        je @@end
                        cmp D eax,brique_transp_o+(next_color*1)
                        je @@end
                        cmp D eax,brique_transp_o+(next_color*2)
                        je @@end
                        cmp D eax,brique_transp_o+(next_color*3)
                        je @@end

            popad
            stc
            ret

@@collision:
            cmp [edx.sprite_mode],monster
            je @@exit

            cmp al,teleporteuse
            jae @@teleportation

            play_sound iff_incassable

                        lea edi,brique_tbl
                        cmp D [edi+ebx*4],brique_reflet_o
                        jae @@exit

                        add D [edi+ebx*4],next_reflet*nbs_reflet
                        jmp @@redraw_brique
@@exit:
            popad
            stc
            ret

@@teleportation:
            call teleporte_ball

            play_sound iff_telepod
            popad
            stc
            ret
@@end:
            popad
            clc
            ret

@@redraw_brique:
            cmp B [esi+ebx],absente
            je @@end

            pushad
            mov edi,temp_y
            shl edi,4
            add edi,bord_y
            mov ebx,temp_x
            shl ebx,5
            add ebx,bord_x
            mov ecx,brique_size_y
            mov edx,brique_size_x
            call _erase_shape
            popad

            lea esi,brique_tbl
            mov esi,[esi+ebx*4]
            mov edi,temp_y
            shl edi,4
            add edi,bord_y
            mov ebx,temp_x
            shl ebx,5
            add ebx,bord_x
            mov ecx,brique_size_y
            mov edx,brique_size_x
            call draw_shape

            play_sound iff_multi
            popad
            stc
            ret

            .data
temp_x      dd ?
temp_y      dd ?
            .code


;----------------------------------------------------------------------------
detect_next_level:
;----------------------------------------------------------------------------

            cmp game_mode,EDIT
            je @@off
            cmp current_option,option_next_level_o
            je @@next

            lea esi,level_tbl
@@again:
            inc esi
            cmp B [esi-1],-1
            je @@end
            cmp B [esi-1],absente
            je @@again
            cmp B [esi-1],incassable
            jae @@again
@@off:
            stc
            ret
@@end:
            play_sound iff_next_level
            clc
            ret
@@next:
            mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            jmp @@end


;----------------------------------------------------------------------------
detect_colision_cursor_player_1:
;----------------------------------------------------------------------------

           ;cmp [edx.sprite_ghost],On
           ;je @@end_ghost

                       cmp dual_flag,On
                       jne @@ok
                       cmp [edx.sprite_player],O player_1
                       jne @@end
            @@ok:

           mov eax,[edx.sprite_sens_y]
           or eax,eax
           js @@end
           mov eax,[edx.sprite_pos_y]
           add eax,[edx.sprite_size_y]
           cmp eax,cursor_1.sprite_pos_y
           jb @@end
           mov eax,[edx.sprite_pos_x]
           add eax,[edx.sprite_size_x]
           cmp eax,cursor_1.sprite_pos_x
           jb @@end
           mov eax,[edx.sprite_pos_x]
           mov ebx,cursor_1.sprite_pos_x
           add ebx,cursor_1.sprite_size_x
           cmp eax,ebx
           jb @@inverse_sens_y
@@end:
           ret

@@end_ghost:
            cmp [edx.sprite_adrs],break_ball_blue_o
            je @@end
            cmp [edx.sprite_adrs],break_ball_orange_o
            je @@end

            mov eax,break_ball_orange_o
            cmp [edx.sprite_adrs],ghost_ball_orange_o
            je @@end2
            mov eax,break_ball_blue_o
@@end2:
            mov [edx.sprite_adrs],eax
            mov [edx.sprite_current_adrs],eax
            mov [edx.sprite_to_delete],break_nbs_anim
            add [edx.sprite_to_delete],2
            mov [edx.sprite_nbs_shape],break_nbs_anim
            mov [edx.sprite_current_shape],1
            mov [edx.sprite_shape_speed],break_speed
            mov [edx.sprite_current_speed],break_speed
            mov [edx.sprite_next_shape],break_next_shape
            mov [edx.sprite_sens_x],0
            mov [edx.sprite_sens_y],0
            ret

@@inverse_sens_y:
           cmp [edx.sprite_ghost],On
           je @@end_ghost

            cmp [edx.sprite_mode],monster
            je @@destruction

            lea ebp,cursor_1
            call detect_magnetic_player_1

            play_sound iff_cursor

            mov eax,[edx.sprite_sens_y]
            neg eax
            mov [edx.sprite_sens_y],eax

            call detect_sens_x
            jc @@sens_negatif_player_1

            mov eax,[edx.sprite_pos_x]
            add eax,[edx.sprite_size_x]
            mov ebx,cursor_1.sprite_pos_x
            add ebx,cursor_border
            cmp eax,ebx
            jb inverse_sens_x

            mov eax,[edx.sprite_pos_x]
            add eax,[edx.sprite_size_x]
            mov ebx,cursor_1.sprite_pos_x
            add ebx,cursor_1.sprite_size_x
            sub ebx,cursor_border
            cmp eax,ebx
            ja inc_angle_x

            call dec_angle_x

            ret

@@destruction:
            ;play_sound iff_del_monster
            ;mov [edx.sprite_status],Off
            ;mov [edx.sprite_delete],2
            ret


;----------------------------------------------------------------------------
@@sens_negatif_player_1:
;----------------------------------------------------------------------------

            mov eax,[edx.sprite_pos_x]
            mov ebx,cursor_1.sprite_pos_x
            add ebx,cursor_1.sprite_size_x
            sub ebx,cursor_border
            cmp eax,ebx
            ja inverse_sens_x

            mov eax,[edx.sprite_pos_x]
            mov ebx,cursor_1.sprite_pos_x
            add ebx,cursor_border
            cmp eax,ebx
            jb inc_angle_x

            call dec_angle_x

            ret


;----------------------------------------------------------------------------
detect_colision_cursor_player_2:
;----------------------------------------------------------------------------

           cmp nbs_player,2
           jne @@end

                       cmp dual_flag,On
                       jne @@ok
                       cmp [edx.sprite_player],O player_2
                       jne @@end
            @@ok:

           mov eax,[edx.sprite_sens_y]
           or eax,eax
           js @@end
           mov eax,[edx.sprite_pos_y]
           add eax,[edx.sprite_size_y]
           cmp eax,cursor_2.sprite_pos_y
           jb @@end
           mov eax,[edx.sprite_pos_x]
           add eax,[edx.sprite_size_x]
           cmp eax,cursor_2.sprite_pos_x
           jb @@end
           mov eax,[edx.sprite_pos_x]
           mov ebx,cursor_2.sprite_pos_x
           add ebx,cursor_2.sprite_size_x
           cmp eax,ebx
           jb @@inverse_sens_y
@@end:
           ret

@@end_ghost:
            cmp [edx.sprite_adrs],break_ball_green_o
            je @@end
            cmp [edx.sprite_adrs],break_ball_yellow_o
            je @@end

            mov eax,break_ball_green_o
            cmp [edx.sprite_adrs],ghost_ball_green_o
            je @@end2
            mov eax,break_ball_yellow_o
@@end2:
            mov [edx.sprite_adrs],eax
            mov [edx.sprite_current_adrs],eax
            mov [edx.sprite_to_delete],break_nbs_anim
            add [edx.sprite_to_delete],2
            mov [edx.sprite_nbs_shape],break_nbs_anim
            mov [edx.sprite_current_shape],1
            mov [edx.sprite_shape_speed],break_speed
            mov [edx.sprite_current_speed],break_speed
            mov [edx.sprite_next_shape],break_next_shape
            mov [edx.sprite_sens_x],0
            mov [edx.sprite_sens_y],0
            ret

@@inverse_sens_y:
           cmp [edx.sprite_ghost],On
           je @@end_ghost

            cmp [edx.sprite_mode],monster
            je @@destruction

            lea ebp,cursor_2
            call detect_magnetic_player_2

            play_sound iff_cursor

            mov eax,[edx.sprite_sens_y]
            neg eax
            mov [edx.sprite_sens_y],eax

            call detect_sens_x
            jc @@sens_negatif_player_2

            mov eax,[edx.sprite_pos_x]
            add eax,[edx.sprite_size_x]
            mov ebx,cursor_2.sprite_pos_x
            add ebx,cursor_border
            cmp eax,ebx
            jb inverse_sens_x

            mov eax,[edx.sprite_pos_x]
            add eax,[edx.sprite_size_x]
            mov ebx,cursor_2.sprite_pos_x
            add ebx,cursor_2.sprite_size_x
            sub ebx,cursor_border
            cmp eax,ebx
            ja inc_angle_x

            call dec_angle_x

            ret

@@destruction:
            ;play_sound iff_del_monster
            ;mov [edx.sprite_status],Off
            ;mov [edx.sprite_delete],2
            ret


;----------------------------------------------------------------------------
@@sens_negatif_player_2:
;----------------------------------------------------------------------------

            mov eax,[edx.sprite_pos_x]
            mov ebx,cursor_2.sprite_pos_x
            add ebx,cursor_2.sprite_size_x
            sub ebx,cursor_border
            cmp eax,ebx
            ja inverse_sens_x

            mov eax,[edx.sprite_pos_x]
            mov ebx,cursor_2.sprite_pos_x
            add ebx,cursor_border
            cmp eax,ebx
            jb inc_angle_x

            call dec_angle_x

            ret


;----------------------------------------------------------------------------
detect_magnetic_player_1:
;----------------------------------------------------------------------------

            test magnetic_flag,PLAYER_ONE
            jnz detect_magnetic
@@end:
            mov [edx.sprite_magnetic],Off
            ret


;----------------------------------------------------------------------------
detect_magnetic_player_2:
;----------------------------------------------------------------------------

            test magnetic_flag,PLAYER_TWO
            jnz detect_magnetic
@@end:
            mov [edx.sprite_magnetic],Off
            ret


;----------------------------------------------------------------------------
detect_magnetic:
;----------------------------------------------------------------------------

            mov [edx.sprite_magnetic],ebp

            mov ebx,[ebp.sprite_size_x]
            sub ebx,[edx.sprite_size_x]

            mov eax,[edx.sprite_pos_x]
            sub eax,[ebp.sprite_pos_x]
            cmp eax,0
            jns @@ok1
            neg eax
@@ok1:
            cmp eax,ebx
            jb @@ok2
            mov eax,ebx
@@ok2:
            mov [edx.sprite_decal_x],eax
            ret


;----------------------------------------------------------------------------
inc_angle_x:
;----------------------------------------------------------------------------

            cmp [edx.sprite_angle],angle_max
            je @@max

            mov eax,speed_max_x
            add eax,[edx.sprite_angle]
            cmp [edx.sprite_sens_x],eax
            jge @@max
            neg eax
            cmp [edx.sprite_sens_x],eax
            jle @@max

            inc [edx.sprite_angle]
            inc [edx.sprite_sens_y]
            mov eax,[edx.sprite_sens_x]
            add eax,incrementation
            mov [edx.sprite_sens_x],eax
@@max:
            ret


;----------------------------------------------------------------------------
dec_angle_x:
;----------------------------------------------------------------------------

            cmp [edx.sprite_angle],off
            je @@min
            dec [edx.sprite_angle]
            dec [edx.sprite_sens_y]
            mov eax,[edx.sprite_sens_x]
            sub eax,incrementation
            mov [edx.sprite_sens_x],eax
@@min:
            ret


;----------------------------------------------------------------------------
detect_sens_x:
;----------------------------------------------------------------------------

            mov eax,[edx.sprite_sens_x]
            or eax,eax
            js @@sens_negatif

            mov incrementation,1
            mov eax,1
            clc
            ret

@@sens_negatif:
            mov incrementation,-1
            mov eax,-1
            stc
            ret


;----------------------------------------------------------------------------
detect_sens_y:
;----------------------------------------------------------------------------

            mov eax,[edx.sprite_sens_y]
            or eax,eax
            js @@sens_negatif

            mov incrementation,1
            mov eax,1
            clc
            ret

@@sens_negatif:
            mov incrementation,-1
            mov eax,-1
            stc
            ret

            .data
incrementation dd ?
            .code


;----------------------------------------------------------------------------
detect_destruction:
;----------------------------------------------------------------------------

           mov eax,[edx.sprite_sens_y]
           or eax,eax
           js @@end

           mov eax,limite_y
           mov ebx,cursor_1.sprite_size_y
           shr ebx,1
           add eax,ebx
           mov ebx,[edx.sprite_pos_y]
           mov ecx,[edx.sprite_size_y]
           shr ecx,1
           add ebx,ecx
           cmp eax,ebx
           ja @@end
           cmp [edx.sprite_status],Kill
           je @@cont2
           mov [edx.sprite_status],Kill

           ;mov [edx.sprite_adrs],ball_blue_o
           ;mov [edx.sprite_current_adrs],ball_blue_o
           ;
           ;                                                             cmp [edx.sprite_ghost],On
           ;                                                             jne @@no_ghost
           ;                                                             mov [edx.sprite_adrs],ghost_ball_blue_o
           ;                                                             mov [edx.sprite_current_adrs],ghost_ball_blue_o
           ;                                                 @@no_ghost:


                       cmp dual_flag,On
                       jne @@cont
                       cmp [edx.sprite_player],O player_1
                       je @@cont
                       add [edx.sprite_adrs],9
                       add [edx.sprite_current_adrs],9
@@cont:
           ;mov [edx.sprite_nbs_shape],9
           ;mov [edx.sprite_current_shape],0
           ;mov [edx.sprite_shape_speed],3
           ;mov [edx.sprite_current_speed],3
           ;mov [edx.sprite_next_shape],2

@@cont2:
           ret
@@end:
           mov eax,screen_y;limite_y
           mov ebx,[edx.sprite_pos_y]
           add ebx,[edx.sprite_size_y]
           cmp eax,ebx
           jb @@end2

           cmp [edx.sprite_status],kill
           jne @@end1
           play_sound iff_lost_ball
           mov [edx.sprite_status],Off
           mov [edx.sprite_delete],2
@@end1:

;           cmp [edx.sprite_rebond],Off
;           je @@end2
;           mov [edx.sprite_current_adrs],ball_orange_o
;           mov [edx.sprite_adrs],ball_orange_o
@@end2:
           ret


;----------------------------------------------------------------------------
detect_game_over_player_1:
;----------------------------------------------------------------------------

            cmp game_mode,PLAYING
            jne @@end
            mov nbs_ball_in_play,Off
            lea edx,Ball_1
            lea ebp,player_1
@@loop:
            cmp [edx.sprite_mode],Ball
            jne @@test_game_over

            cmp dual_flag,On
            jne @@ok
            cmp [edx.sprite_player],ebp
            jne @@next
@@ok:
            cmp [edx.sprite_status],On
            je @@count_ball
            cmp [edx.sprite_status],Kill
            je @@count_ball
@@next:
            add edx,size struc_sprites
            jmp @@loop
@@count_ball:
            inc nbs_ball_in_play
            add edx,size struc_sprites
            jmp @@loop
@@test_game_over:
            cmp nbs_ball_in_play,0
            je test_game_over
            cmp nbs_ball_in_play,2
            jae @@end
            cmp coop_flag,On
            je test_game_over
@@end:
            clc
            ret

nbs_ball_in_play dd 0


;----------------------------------------------------------------------------
detect_game_over_player_2:
;----------------------------------------------------------------------------

            cmp dual_flag,On
            jne @@end

            cmp game_mode,PLAYING
            jne @@end
            lea edx,Ball_1
            lea ebp,player_2
@@loop:
            cmp [edx.sprite_mode],Ball
            jne test_game_over
            cmp [edx.sprite_player],ebp
            jne @@next
            cmp [edx.sprite_status],On
            je @@end
            cmp [edx.sprite_status],Kill
            je @@end
@@next:
            add edx,size struc_sprites
            jmp @@loop
@@end:
            clc
            ret


;----------------------------------------------------------------------------
test_game_over:
;----------------------------------------------------------------------------

            mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            mov current_option_count,Off

            dec [ebp.player_nbs_ball]
            cmp [ebp.player_nbs_ball],-1
            jne @@cont

            mov game_mode,GAME_OVER

            push ebp
            lea esi,option_text_over
            call print
            pop ebp

            call destroy_vaisseau

            call display_score

            mov game_mode,NEW_PLAY

            clc
            ret

@@cont:
            mov game_mode,READY_TO_PLAY_AGAIN

            push ebp
            lea esi,option_text_again
            call print
            pop ebp

            call destroy_vaisseau

            lea esi,option_text_ready
            call print

            play_sound iff_restart

            call display_nbs_ball_player_1
            call display_nbs_ball_player_2
            stc
            ret


;----------------------------------------------------------------------------
telepod_ship_on:
;----------------------------------------------------------------------------

            cmp game_mode,EDIT
            je @@exit

            push ball_1.sprite_status
            push ball_2.sprite_status
            mov ball_1.sprite_status,Off
            mov ball_2.sprite_status,Off

            mov init_cursor_flag,On

            mov ebp,O cursor_1
            call init_cursor_telepod

            cmp nbs_player,2
            jne @@wait
            mov ebp,O cursor_2
            call init_cursor_telepod
@@wait:

            push ebp
            mov ecx,1
            call refresh_all
            pop ebp
            cmp [ebp.sprite_current_shape],2
            jne @@wait
@@end:
            pop ball_2.sprite_status
            pop ball_1.sprite_status

            call init_cursor
@@exit:
            ret

init_cursor_flag        dd Off


;----------------------------------------------------------------------------
telepod_ship_off:
;----------------------------------------------------------------------------

            mov init_cursor_flag,Off

            mov ebp,O cursor_1
            call init_cursor_telepod

            cmp nbs_player,2
            jne @@wait
            mov ebp,O cursor_2
            call init_cursor_telepod
@@wait:

            call reset_ball

            push ebp
            mov ecx,1
            call refresh_all
            pop ebp
            cmp [ebp.sprite_current_shape],2
            jne @@wait

            mov cursor_1.sprite_delete,2

                        cmp nbs_player,2
                        jne @@end
                        mov cursor_2.sprite_delete,2
@@end:
            mov ecx,4
            call refresh_all

            ret


;----------------------------------------------------------------------------
destroy_vaisseau:
;----------------------------------------------------------------------------

            play_sound iff_explosion
            play_sound iff_game_over

            mov ebp,[ebp.player_cursor]
            call init_cursor_game_over

            cmp coop_flag,Off
            je @@wait
            mov ebp,O cursor_2
            call init_cursor_game_over
@@wait:

            call reset_ball

            push ebp
            mov ecx,1
            call refresh_all
            pop ebp
            cmp [ebp.sprite_current_shape],2
            jne @@wait

            mov cursor_1.sprite_delete,2

                        cmp nbs_player,2
                        jne @@end
                        mov cursor_2.sprite_delete,2
@@end:
            mov ecx,75
            call refresh_all

            ret


;----------------------------------------------------------------------------
reset_ball:
;----------------------------------------------------------------------------

           lea edx,ball_1
@@loop:
           cmp [edx.sprite_mode],ball
           jne @@end
           mov [edx.sprite_delete],2
           mov [edx.sprite_status],off
           add edx,size struc_sprites
           jmp @@loop
@@end:
           ret


;----------------------------------------------------------------------------
end_game:
;----------------------------------------------------------------------------

            mov current_level,1

;----------------------------------------------------------------------------
create_wall:
;----------------------------------------------------------------------------

            call wait_keyboard_release

            cmp game_mode,READY_TO_PLAY_AGAIN
            jne @@ok

            mov esi,background_buffer
            mov edi,video_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            call draw_buffer
            ret

@@ok:
            mov edi,bord_y
            mov ebx,bord_x
            mov ecx,screen_y
            mov edx,limite_x-bord_x
            call _erase_shape

            call display_level

            mov eax,current_level
            dec eax
            imul eax,nbs_brique_x*nbs_brique_y
            mov esi,eax
            add esi,level_adrs

            lea ebp,level_tbl

            mov ebx,bord_x
            mov edi,bord_y
@@line:
            lodsb
            cmp B [ebp],-1
            je @@end
            cmp al,-1
            je Error_File
            call draw_brique
            mov [ebp],al
            inc ebp
            add ebx,brique_size_x
            cmp ebx,bord_x+(nbs_brique_x*brique_size_x)
            jb @@line
            mov ebx,bord_x
            add edi,brique_size_y
            jmp @@line
@@end:
            mov edi,bord_y
            mov ebx,bord_x
            mov ecx,screen_y
            mov edx,limite_x-bord_x
            call flip_screen

            mov eax,current_level
            dec eax
            imul eax,17
            mov edx,speed_delai
            mov speed_level,edx
            sub speed_level,eax

            Send speed_level,10+9,3

            ret

            .data
speed_level dd ?
            .code


;----------------------------------------------------------------------------
draw_brique:
;----------------------------------------------------------------------------

            push esi
            push ecx
            push edx

            cmp al,0
            je @@end

            mov esi,0

            push ebx
            mov ebx,eax

            mov eax,ebx
            and eax,type_de_brique
            cmp eax,normale
            jne @@a
            add esi,brique_classic_o
            @@a:

            mov eax,ebx
            and eax,type_de_brique
            cmp eax,incassable
            jne @@b
            add esi,brique_beton_o
            @@b:

            mov eax,ebx
            and eax,type_de_brique
            cmp eax,teleporteuse
            jne @@b2
            add esi,brique_teleport_o
            @@b2:

            mov eax,ebx
            and eax,type_de_brique
            cmp eax,transparente
            jne @@c
            and ebx,not type_de_brique
            or  ebx,normale
            add esi,brique_transp_o
            @@c:

            mov eax,ebx
            and eax,resistance_de_brique
            cmp eax,1
            jbe @@d
            and ebx,nombre_de_coups
            or  ebx,100b
            cmp game_mode,EDIT
            jne @@d
            cmp esi,brique_classic_o
            jne @@d
            mov esi,brique_multi_o
            @@d:

            mov eax,ebx
            and eax,couleur_de_brique
            shr eax,6
            imul eax,next_color
            add esi,eax

            mov eax,ebx
            and eax,resistance_de_brique

            pop ebx

            cmp esi,0
            je Error_File

            push ebp
            sub ebp, O level_Tbl
            lea ecx,brique_tbl
            mov D [ecx+ebp*4],esi
            pop ebp

            mov ecx,brique_size_y
            mov edx,brique_size_x
            call _draw_shape

@@end:
            pop edx
            pop ecx
            pop esi
            ret

            .data
level_tbl   db nbs_brique_y*nbs_brique_x dup (-2)
            db -1

level_flag  db nbs_brique_y*nbs_brique_x dup (0)

level_flip  db nbs_brique_y*nbs_brique_x dup (0)

brique_tbl  dd nbs_brique_y*nbs_brique_x dup (-2)
            dd -1
            .code


;----------------------------------------------------------------------------
search_level_number:
;----------------------------------------------------------------------------

            mov esi,level_adrs
            mov ecx,level_size
            mov level_number,0
@@again:
            cmp B [esi],-1
            je @@end
            inc level_number
            add esi,nbs_brique_x*nbs_brique_y
            sub ecx,nbs_brique_x*nbs_brique_y
            cmp ecx,0
            ja @@again
            jmp Error_File
@@end:
            ret

            .data
level_number dd ?
            .code


;----------------------------------------------------------------------------
init_random:
;----------------------------------------------------------------------------

            mov al,0
            out 70h,al
            in al,71h
            inc al
            movzx ecx,al
@@init_random:
            call calc_random
            push ecx
            mov al,0
            out 70h,al
            in al,71h
            inc al
            movzx ecx,al
@@init_random2:
            call calc_random
            loop @@init_random2
            pop ecx
            loop @@init_random
            ret


;----------------------------------------------------------------------------
calc_random:
;----------------------------------------------------------------------------

            mov ax,alea1
            add ax,71
            adc ax,alea3
            mov alea3,ax
            mov ax,alea2
            adc ax,32111
            adc ax,alea4
            xor ax,alea1
            mov alea2,ax
            rcl alea3,1
            adc ax,alea4
            rcr ax,1
            mov alea4,ax

            ret

            .data
alea1       dw 0
alea2       dw 0
alea3       dw 0
alea4       dw 0
            .code


;----------------------------------------------------------------------------
;           mov eax,lim haut
get_random:
;----------------------------------------------------------------------------

            push ebx
            push ecx

            mov ebx,eax

            mov ecx,0
@@again:
            or eax,eax
            jz @@cont
            shr eax,1
            stc
            rcl ecx,1
            jmp @@again
@@cont:
            call calc_random
            and eax,ecx
            cmp eax,ebx
            ja @@cont

            pop ecx
            pop ebx
            ret


;----------------------------------------------------------------------------
demo_move_x_player_1:
;----------------------------------------------------------------------------

            cmp computer_flag,On
            je @@ok
            cmp demo_flag,On
            jne @@ok
            mov eax,ball_1.sprite_pos_x
            mov ebx,cursor_1.sprite_size_x
            shr ebx,1
            sub eax,ebx
            mov cursor_1.sprite_pos_x,eax
@@ok:
            ret


;----------------------------------------------------------------------------
demo_move_x_player_2:
;----------------------------------------------------------------------------

            cmp demo_flag,On
            jne @@ok
            cmp nbs_player,2
            jne @@ok
            cmp game_mode,PLAYING
            jne @@end
            mov eax,ball_2.sprite_pos_x
            mov ebx,cursor_2.sprite_size_x
            shr ebx,1
            sub eax,ebx

            mov cursor_2.sprite_pos_x,eax

@@end:
            stc
            ret
@@ok:
            clc
            ret


;----------------------------------------------------------------------------
init_start_game:
;----------------------------------------------------------------------------

            mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off

            ; positionnement de la balle en y
            mov eax,cursor_1.sprite_pos_y
            mov ebx,ball_1.sprite_size_y
            sub eax,ebx
            mov ball_1.sprite_pos_y,eax

            ; positionnement de la balle
            mov eax,cursor_1.sprite_pos_x
            mov ebx,cursor_1.sprite_size_x
            shr ebx,1
            add eax,ebx
            mov ebx,ball_1.sprite_size_x
            shr ebx,1
            sub eax,ebx
            mov ball_1.sprite_pos_x,eax

                        cmp nbs_player,2
                        jne @@cont2
                        ; positionnement de la balle en y
                        mov eax,cursor_2.sprite_pos_y
                        mov ebx,ball_2.sprite_size_y
                        sub eax,ebx
                        mov ball_2.sprite_pos_y,eax

                        ; positionnement de la balle
                        mov eax,cursor_2.sprite_pos_x
                        mov ebx,cursor_2.sprite_size_x
                        shr ebx,1
                        add eax,ebx
                        mov ebx,ball_2.sprite_size_x
                        shr ebx,1
                        sub eax,ebx
                        mov ball_2.sprite_pos_x,eax
            @@cont2:

            mov start_flag,Off

            or magnetic_flag,PLAYER_ONE
            or start_flag,PLAYER_ONE
            lea edx,Ball_1
            lea ebp,cursor_1
            call detect_magnetic

            cmp nbs_player,2
            jne @@cont
            or magnetic_flag,PLAYER_TWO
            or start_flag,PLAYER_TWO
            lea edx,Ball_2
            lea ebp,cursor_2
            call detect_magnetic
@@cont:
            ret


;----------------------------------------------------------------------------
detect_start_game:
;----------------------------------------------------------------------------

            pushad

            cmp game_mode,READY_TO_PLAY_AGAIN
            je @@ok
            cmp game_mode,READY_TO_PLAY
            jne @@end
            @@ok:

            ; positionnement de la balle en y
            mov eax,cursor_1.sprite_pos_y
            mov ebx,ball_1.sprite_size_y
            sub eax,ebx
            mov ball_1.sprite_pos_y,eax

            ; positionnement de la balle
            mov eax,cursor_1.sprite_pos_x
            mov ebx,cursor_1.sprite_size_x
            shr ebx,1
            add eax,ebx
            mov ebx,ball_1.sprite_size_x
            shr ebx,1
            sub eax,ebx
            mov ball_1.sprite_pos_x,eax

                        cmp nbs_player,2
                        jne @@cont
                        ; positionnement de la balle en y
                        mov eax,cursor_2.sprite_pos_y
                        mov ebx,ball_2.sprite_size_y
                        sub eax,ebx
                        mov ball_2.sprite_pos_y,eax

                        ; positionnement de la balle
                        mov eax,cursor_2.sprite_pos_x
                        mov ebx,cursor_2.sprite_size_x
                        shr ebx,1
                        add eax,ebx
                        mov ebx,ball_2.sprite_size_x
                        shr ebx,1
                        sub eax,ebx
                        mov ball_2.sprite_pos_x,eax
            @@cont:

            cmp computer_flag,On
            je @@pass
            cmp demo_flag,On
            je @@click
@@pass:
            call read_click
            jz @@end
@@click:

            mov game_mode,PLAYING
            ; lancement de la balle

            call print_off

            mov eax,speed_start_easy
            mov ecx,change_speed_level_easy

            cmp difficulte,MEDIUM
            jne @@ok1
            mov eax,speed_start_medium
            mov ecx,change_speed_level_medium

@@ok1:
            cmp difficulte,HARD
            jne @@ok2
            mov eax,speed_start_hard
            mov ecx,change_speed_level_hard
@@ok2:
                        cmp nbs_player,2
                        jne @@cont2

                        pushad
                        neg eax
                        mov ball_2.sprite_sens_x,eax
                        dec eax
                        mov ball_2.sprite_sens_y,eax

                        mov eax,level_number
                        cdq
                        idiv ecx
                        mov ecx,eax
                        mov eax,current_level
                        cdq
                        idiv ecx
                        sub ball_2.sprite_sens_x,eax
                        sub ball_2.sprite_sens_y,eax
                        popad
            @@cont2:

            mov ball_1.sprite_sens_x,eax
            inc eax
            neg eax
            mov ball_1.sprite_sens_y,eax

            mov eax,level_number
            cdq
            idiv ecx
            mov ecx,eax
            mov eax,current_level
            cdq
            idiv ecx
            add ball_1.sprite_sens_x,eax
            sub ball_1.sprite_sens_y,eax

            mov eax,ball_2.sprite_sens_x
            neg eax
            shl eax,1
            mov speed_counter,eax
@@end:
            popad
            ret


;----------------------------------------------------------------------------
detect_blocage:
;----------------------------------------------------------------------------

            cmp game_mode,PLAYING
            jne @@end

            cmp [edx.sprite_mode],Monster
            je @@end

            cmp [edx.sprite_counter_1],0
            je @@init
            cmp [edx.sprite_counter_1],BLOCAGE_COUNTER
            jne @@cont
@@init:
            mov [edx.sprite_counter_1],0
            mov [edx.sprite_counter_2],0
            push [edx.sprite_pos_x]
            push [edx.sprite_pos_y]
            pop  [edx.sprite_bak_y]
            pop  [edx.sprite_bak_x]
@@cont:
            inc [edx.sprite_counter_1]

            mov eax,[edx.sprite_pos_x]
            cmp eax,[edx.sprite_bak_x]
            jne @@end
            mov eax,[edx.sprite_pos_y]
            cmp eax,[edx.sprite_bak_y]
            jne @@end
            inc [edx.sprite_counter_2]
            cmp [edx.sprite_counter_2],BLOCAGE_COUNTER_2
            jne @@end
            mov [edx.sprite_counter_2],0
            call detect_sens_x
            cmp [edx.sprite_angle],0
            je inc_angle_x
            jne dec_angle_x
@@end:
            mov eax,BLOCAGE_COUNTER
            sub eax,[edx.sprite_counter_1]
            Send eax,10,4
            Send [edx.sprite_counter_2],10+9,4
            ret


;----------------------------------------------------------------------------
Init_Options:
;----------------------------------------------------------------------------

            mov current_option_count,Off

            lea edx,Option_1
@@loop:
            cmp [edx.sprite_mode],Option
            jne @@end

            ;mov eax,option_buffer
            ;mov [edx.sprite_buffer_adrs],eax

            mov [edx.sprite_size_x],option_size_x
            mov [edx.sprite_size_y],option_size_y
            mov [edx.sprite_adrs],option_1_o
            push [edx.sprite_size_x]
            pop  [edx.sprite_old_size_x]
            push [edx.sprite_size_y]
            pop  [edx.sprite_old_size_y]
            push [edx.sprite_adrs]
            pop  [edx.sprite_current_adrs]
            mov [edx.sprite_min_x],bord_x
            mov eax,limite_x
            sub eax,[edx.sprite_size_x]
            mov [edx.sprite_max_x],eax
            mov [edx.sprite_min_y],bord_y
            mov eax,screen_y
            sub eax,[edx.sprite_size_y]
            mov [edx.sprite_max_y],eax
            mov [edx.sprite_status],Off

            mov [edx.sprite_nbs_shape],option_nbs_anim
            mov [edx.sprite_current_shape],option_nbs_anim
            mov [edx.sprite_shape_speed],option_speed
            mov [edx.sprite_current_speed],option_speed
            mov [edx.sprite_next_shape],000+(screen_x*25)-option_size_x

@@next:
            add edx,size struc_sprites
            jmp @@loop
@@end:
            mov option_collision.option_status,Off
            cmp nbs_player,2
            jne @@end2
            mov option_collision.option_status,On
@@end2:
            ret


;----------------------------------------------------------------------------
random_options:
;----------------------------------------------------------------------------

            mov eax,delai_between_option_easy

            cmp difficulte,MEDIUM
            jne @@d2
            mov eax,delai_between_option_medium
@@d2:
            cmp difficulte,HARD
            jne @@d3
            mov eax,delai_between_option_hard
@@d3:

            cmp delai_random_option,eax
            jb @@end
            mov delai_random_option,Off

                       mov eax,[edx.sprite_player]
                       mov current_ball_player,eax
@@again:
           mov eax,options_number-1
           call get_random
           cmp eax,last_random
           je @@again
           mov last_random,eax

           imul eax,size struc_options
           add eax,O Option_3_ball

           cmp [eax.option_status],Off
           je @@end

           mov ebp,[eax.option_adrs]

           cmp option_forced,Off
           je @@rand
           mov ebp,option_forced
           jmp @@forced
@@rand:

           cmp difficulte,MEDIUM
           jne @@ok0
           mov eax,[eax.option_medium]
@@ok0:
           cmp difficulte,HARD
           jne @@ok1
           mov eax,[eax.option_hard]
@@ok1:
           cmp difficulte,EASY
           jne @@ok2
           mov eax,[eax.option_easy]
@@ok2:

           cmp eax,1
           je @@forced
           cmp eax,Off
           je @@again
           dec eax
           call get_random
           or eax,eax
           jnz @@end
@@forced:
           lea edx,Option_1
@@loop:
           cmp [edx.sprite_mode],Option
           jne @@end
           cmp [edx.sprite_status],On
           je @@next

           mov [edx.sprite_adrs],ebp
           mov [edx.sprite_current_adrs],ebp

                       cmp dual_flag,On
                       jne @@ok3
                       mov eax,current_ball_player
                       mov [edx.sprite_player],eax
                       cmp eax,O player_1
                       je @@ok3
                       mov eax,option_2_decal
                       add [edx.sprite_adrs],eax
                       add [edx.sprite_current_adrs],eax
            @@ok3:

           mov [edx.sprite_status],On
           mov [edx.sprite_pos_x],ebx
           mov [edx.sprite_pos_y],edi
           mov [edx.sprite_sens_y],+2

           mov [edx.sprite_nbs_shape],option_nbs_anim
           mov [edx.sprite_current_shape],option_nbs_anim
           mov [edx.sprite_shape_speed],option_speed
           mov [edx.sprite_current_speed],option_speed
           mov [edx.sprite_next_shape],000+(screen_x*25)-option_size_x

           jmp @@end
@@next:
           add edx,size struc_sprites
           jmp @@loop
@@end:
           ret

            .data
last_random dd ?
current_ball_player dd ?
            .code


;----------------------------------------------------------------------------
Refresh_Options:
;----------------------------------------------------------------------------

           lea edx,Option_1
@@loop:
           cmp [edx.sprite_mode],Option
           jne @@end
           cmp [edx.sprite_status],On
           jne @@next

           mov eax,[edx.sprite_pos_x]
           add eax,[edx.sprite_sens_x]
           mov [edx.sprite_pos_x],eax

           mov eax,[edx.sprite_pos_y]
           add eax,[edx.sprite_sens_y]
           mov [edx.sprite_pos_y],eax

           mov ebx,limite_y
           mov eax,[edx.sprite_pos_y]
           cmp eax,ebx
           jb @@next
           add ebx,[edx.sprite_size_y]
           cmp eax,ebx
           ja @@cont2
           call detect_prise_option
@@cont2:
           add eax,[edx.sprite_size_y]
           add eax,[edx.sprite_sens_y]
           cmp eax,screen_y
           jb @@next
           play_sound iff_lost_option
           mov [edx.sprite_status],Lost
           mov [edx.sprite_adrs],Option_off
           mov [edx.sprite_current_adrs],Option_off
           mov [edx.sprite_nbs_shape],1
           mov [edx.sprite_current_shape],1
@@next:
           add edx,size struc_sprites
           jmp @@loop
@@end:
           ret


;----------------------------------------------------------------------------
detect_prise_option:
;----------------------------------------------------------------------------

           cmp game_mode,PLAYING
           je @@ok
           ret
@@ok:
           push eax
           cmp [edx.sprite_status],Lost
           je @@end

           mov eax,[edx.sprite_pos_x]
           cmp eax,cursor_1.sprite_pos_x
           jb @@player2
           add eax,[edx.sprite_size_x]
           mov ebx,cursor_1.sprite_pos_x
           add ebx,cursor_1.sprite_size_x
           cmp eax,ebx
           ja @@player2

                       lea eax,player_1

                       cmp dual_flag,On
                       jne @@detected
                       cmp [edx.sprite_player],eax
                       jne @@player2
                       jmp @@detected
@@player2:
                       cmp nbs_player,2
                       jne @@end

                       mov eax,[edx.sprite_pos_x]
                       cmp eax,cursor_2.sprite_pos_x
                       jb @@end
                       add eax,[edx.sprite_size_x]
                       mov ebx,cursor_2.sprite_pos_x
                       add ebx,cursor_2.sprite_size_x
                       cmp eax,ebx
                       ja @@end

                       lea eax,player_2

                       cmp dual_flag,On
                       jne @@detected
                       cmp [edx.sprite_player],eax
                       jne @@end
@@detected:

          mov current_player,eax

                       pushad
                       cmp dual_flag,On
                       jne @@cont2
                       cmp eax,O player_1
                       jne @@cont1
                       call read_click_player_1
                       jz @@cont2
                       mov current_player,O player_2
                       jmp @@cont2
@@cont1:
                       cmp eax,O player_2
                       jne @@cont2
                       call read_click_player_2
                       jz @@cont2
                       mov current_player,O player_1
                       jmp @@cont2
@@cont2:
                       popad

           push current_option
           pop old_option

           mov eax,[edx.sprite_adrs]

                       cmp dual_flag,On
                       jne @@ok3
                       cmp [edx.sprite_player],O player_2
                       jne @@ok3
                       sub eax,option_2_decal
@@ok3:

           mov current_option,eax
           mov ebx,current_player
           mov [ebx.player_current_option],eax

           mov current_option_count,DELAI_OPTION
           sub eax,option_1_o
           add eax,option_fade_o
           mov panel_option.sprite_adrs,eax
           mov panel_option.sprite_current_adrs,eax

           mov [edx.sprite_status],Lost
           mov [edx.sprite_adrs],Option_off
           mov [edx.sprite_current_adrs],Option_off
           mov [edx.sprite_nbs_shape],1
           mov [edx.sprite_current_shape],1

           mov fade_option_flag,On
           mov fade_option_count,1
           mov fade_option_pal,option_pal
           mov fade_option_pal_size,option_pal_size

           Play_Sound iff_option

           push ecx
           push ebp
           mov ecx,2
           mov ebp,current_player
           call inc_score
           pop ebp
           pop ecx
@@end:
           pop eax
           ret

            .data
current_option    dd Off
old_option        dd Off
fade_option_count dd 1
            .code


;----------------------------------------------------------------------------
fade_options:
;----------------------------------------------------------------------------

            cmp fade_option_flag,Off
            je @@end
            inc counter_fade
            mov eax,fade_option_count
            cmp counter_fade,eax
            jae @@ok
@@end:
            ret
@@ok:
            mov counter_fade,0
            cmp fade_sens,On
            je fade_option_Off
            jne fade_option_On

            .data
current_fade_pointer dd 0
counter_fade         dd 0
counter_fade_2       dd 0
fade_sens            dd On
fade_option_flag     dd Off
fade_option_pal      dd 0
fade_option_pal_size dd 0
            .code


;----------------------------------------------------------------------------
fade_option_Off:
;----------------------------------------------------------------------------

            mov edi,current_fade_pointer
            mov eax,fade_option_pal
            mov esi,offset palette
            add esi,eax
            add esi,eax
            add esi,eax
            add esi,edi
            mov ecx,fade_option_pal_size
          ÿÿcall set_palette

            add current_fade_pointer,256*3
            cmp current_fade_pointer,256*3*12
            jne @@ok
            xor fade_sens,On
@@ok:
           ÿret


;----------------------------------------------------------------------------
fade_option_On:
;----------------------------------------------------------------------------

            mov edi,current_fade_pointer
            mov eax,fade_option_pal
          ÿÿmov esi,offset palette
            add esi,eax
            add esi,eax
            add esi,eax
            add esi,edi
            mov ecx,fade_option_pal_size
          ÿÿcall set_palette

            sub current_fade_pointer,256*3
            cmp current_fade_pointer,0
            jne @@ok
            xor fade_sens,On
            inc counter_fade_2
            cmp counter_fade_2,10
            jae @@reset
@@ok:
           ÿret
@@reset:
            mov counter_fade_2,Off
            mov fade_option_flag,Off
            ret


;----------------------------------------------------------------------------
play_sound_track_0_or_1:
;----------------------------------------------------------------------------

            pushad
            mov ah,Play_Sample
            mov cx,15fh-50h
            xor dx,dx
            cmp bx,019h
            jae @@ok
            inc dx
@@ok:       Int_EOS
            popad
            ret


;----------------------------------------------------------------------------
create_border:
;----------------------------------------------------------------------------

            pushad

            mov esi,border_left_o
            mov edi,0
            mov ecx,border_size_y
            mov edx,border_size_x
            mov ebx,bord_x
            sub ebx,edx
            mov ebp,5
@@again:
            call _draw_shape
            add edi,ecx
            dec ebp
            jnz @@again

            mov esi,border_right_o
            mov edi,0
            mov ecx,border_size_y
            mov edx,border_size_x
            mov ebx,limite_x
            mov ebp,5
@@again2:
            call _draw_shape
            add edi,ecx
            dec ebp
            jnz @@again2

            popad
            ret


;----------------------------------------------------------------------------
init_panel:
;----------------------------------------------------------------------------

            lea edx,Panel_Info
            mov [edx.sprite_status],On
            mov [edx.sprite_sens_x],Off
            mov [edx.sprite_sens_y],Off
            mov [edx.sprite_angle],Off
            mov [edx.sprite_new_xy],Off
            mov [edx.sprite_old_xy],Off
            mov [edx.sprite_new_xy_dx],Off
            mov [edx.sprite_old_xy_dx],Off
            mov [edx.sprite_min_x],0
            mov [edx.sprite_min_y],0
            mov [edx.sprite_max_x],screen_x
            mov [edx.sprite_max_y],screen_y
            mov [edx.sprite_adrs],panel_info_o
            mov [edx.sprite_size_x],panel_info_size_x
            mov [edx.sprite_size_y],panel_info_size_y
            mov [edx.sprite_pos_x],panel_info_pos_x
            mov [edx.sprite_pos_y],panel_info_pos_y
            push [edx.sprite_size_x]
            pop  [edx.sprite_old_size_x]
            push [edx.sprite_size_y]
            pop  [edx.sprite_old_size_y]
            push [edx.sprite_adrs]
            pop  [edx.sprite_current_adrs]

            lea edx,Panel_Score
            mov [edx.sprite_status],On
            mov [edx.sprite_sens_x],Off
            mov [edx.sprite_sens_y],Off
            mov [edx.sprite_angle],Off
            mov [edx.sprite_new_xy],Off
            mov [edx.sprite_old_xy],Off
            mov [edx.sprite_new_xy_dx],Off
            mov [edx.sprite_old_xy_dx],Off
            mov [edx.sprite_min_x],0
            mov [edx.sprite_min_y],0
            mov [edx.sprite_max_x],screen_x
            mov [edx.sprite_max_y],screen_y
            mov [edx.sprite_adrs],panel_score_1_o
            mov [edx.sprite_size_x],panel_score_size_x
            mov [edx.sprite_size_y],panel_score_size_y
            mov [edx.sprite_pos_x],panel_score_pos_x
            mov [edx.sprite_pos_y],panel_score_pos_y
            push [edx.sprite_size_x]
            pop  [edx.sprite_old_size_x]
            push [edx.sprite_size_y]
            pop  [edx.sprite_old_size_y]
            push [edx.sprite_adrs]
            pop  [edx.sprite_current_adrs]

            lea edx,Panel_Option

            ;mov eax,option_buffer
            ;mov [edx.sprite_buffer_adrs],eax

            mov [edx.sprite_status],On
            mov [edx.sprite_sens_x],Off
            mov [edx.sprite_sens_y],Off
            mov [edx.sprite_angle],Off
            mov [edx.sprite_new_xy],Off
            mov [edx.sprite_old_xy],Off
            mov [edx.sprite_new_xy_dx],Off
            mov [edx.sprite_old_xy_dx],Off
            mov [edx.sprite_min_x],0
            mov [edx.sprite_min_y],0
            mov [edx.sprite_max_x],screen_x
            mov [edx.sprite_max_y],screen_y
            mov [edx.sprite_adrs],option_off
            mov [edx.sprite_size_x],panel_option_size_x
            mov [edx.sprite_size_y],panel_option_size_y
            mov [edx.sprite_pos_x],panel_option_pos_x
            mov [edx.sprite_pos_y],panel_option_pos_y
            push [edx.sprite_size_x]
            pop  [edx.sprite_old_size_x]
            push [edx.sprite_size_y]
            pop  [edx.sprite_old_size_y]
            push [edx.sprite_adrs]
            pop  [edx.sprite_current_adrs]

            lea edx,Panel_Level
            mov [edx.sprite_status],On
            mov [edx.sprite_sens_x],Off
            mov [edx.sprite_sens_y],Off
            mov [edx.sprite_angle],Off
            mov [edx.sprite_new_xy],Off
            mov [edx.sprite_old_xy],Off
            mov [edx.sprite_new_xy_dx],Off
            mov [edx.sprite_old_xy_dx],Off
            mov [edx.sprite_min_x],0
            mov [edx.sprite_min_y],0
            mov [edx.sprite_max_x],screen_x
            mov [edx.sprite_max_y],screen_y
            mov [edx.sprite_adrs],panel_level_o
            mov [edx.sprite_size_x],panel_level_size_x
            mov [edx.sprite_size_y],panel_level_size_y
            mov [edx.sprite_pos_x],panel_level_pos_x
            mov [edx.sprite_pos_y],panel_level_pos_y
            push [edx.sprite_size_x]
            pop  [edx.sprite_old_size_x]
            push [edx.sprite_size_y]
            pop  [edx.sprite_old_size_y]
            push [edx.sprite_adrs]
            pop  [edx.sprite_current_adrs]

            lea edx,Panel_Nbs_Ball_1
            mov [edx.sprite_status],On
            mov [edx.sprite_sens_x],Off
            mov [edx.sprite_sens_y],Off
            mov [edx.sprite_angle],Off
            mov [edx.sprite_new_xy],Off
            mov [edx.sprite_old_xy],Off
            mov [edx.sprite_new_xy_dx],Off
            mov [edx.sprite_old_xy_dx],Off
            mov [edx.sprite_min_x],0
            mov [edx.sprite_min_y],0
            mov [edx.sprite_max_x],screen_x
            mov [edx.sprite_max_y],screen_y
            mov [edx.sprite_adrs],panel_nbs_ball_1_o
            mov [edx.sprite_size_x],panel_nbs_ball_size_x
            mov [edx.sprite_size_y],panel_nbs_ball_size_y
            mov [edx.sprite_pos_x],panel_nbs_ball_pos_x
            mov [edx.sprite_pos_y],panel_nbs_ball_pos_y_1
            push [edx.sprite_size_x]
            pop  [edx.sprite_old_size_x]
            push [edx.sprite_size_y]
            pop  [edx.sprite_old_size_y]
            push [edx.sprite_adrs]
            pop  [edx.sprite_current_adrs]

                        lea edx,Panel_Score_2
                        mov [edx.sprite_status],Off
                        cmp dual_flag,On
                        jne @@cont
                        mov [edx.sprite_status],On
                        mov [edx.sprite_sens_x],Off
                        mov [edx.sprite_sens_y],Off
                        mov [edx.sprite_angle],Off
                        mov [edx.sprite_new_xy],Off
                        mov [edx.sprite_old_xy],Off
                        mov [edx.sprite_new_xy_dx],Off
                        mov [edx.sprite_old_xy_dx],Off
                        mov [edx.sprite_min_x],0
                        mov [edx.sprite_min_y],0
                        mov [edx.sprite_max_x],screen_x
                        mov [edx.sprite_max_y],screen_y
                        mov [edx.sprite_adrs],panel_score_2_o
                        mov [edx.sprite_size_x],panel_score_size_x
                        mov [edx.sprite_size_y],panel_score_size_y
                        mov [edx.sprite_pos_x],panel_level_pos_x
                        mov [edx.sprite_pos_y],panel_score_pos_y
                        push [edx.sprite_size_x]
                        pop  [edx.sprite_old_size_x]
                        push [edx.sprite_size_y]
                        pop  [edx.sprite_old_size_y]
                        push [edx.sprite_adrs]
                        pop  [edx.sprite_current_adrs]

                        lea edx,Panel_Level
                        add [edx.sprite_pos_x],150+32

                        lea edx,Panel_Nbs_Ball_2
                        mov [edx.sprite_status],On
                        mov [edx.sprite_sens_x],Off
                        mov [edx.sprite_sens_y],Off
                        mov [edx.sprite_angle],Off
                        mov [edx.sprite_new_xy],Off
                        mov [edx.sprite_old_xy],Off
                        mov [edx.sprite_new_xy_dx],Off
                        mov [edx.sprite_old_xy_dx],Off
                        mov [edx.sprite_min_x],0
                        mov [edx.sprite_min_y],0
                        mov [edx.sprite_max_x],screen_x
                        mov [edx.sprite_max_y],screen_y
                        mov [edx.sprite_adrs],panel_nbs_ball_2_o
                        mov [edx.sprite_size_x],panel_nbs_ball_size_x
                        mov [edx.sprite_size_y],panel_nbs_ball_size_y
                        mov [edx.sprite_pos_x],panel_nbs_ball_pos_x
                        mov [edx.sprite_pos_y],panel_nbs_ball_pos_y_2
                        push [edx.sprite_size_x]
                        pop  [edx.sprite_old_size_x]
                        push [edx.sprite_size_y]
                        pop  [edx.sprite_old_size_y]
                        push [edx.sprite_adrs]
                        pop  [edx.sprite_current_adrs]

@@cont:

            call display_nbs_ball_player_1
            call display_nbs_ball_player_2
            ret


;----------------------------------------------------------------------------
display_nbs_ball_player_1:
;----------------------------------------------------------------------------

            lea edx,Panel_Nbs_Ball_1
            mov [edx.sprite_current_adrs],panel_nbs_ball_1_o
            mov [edx.sprite_adrs],panel_nbs_ball_1_o
            mov [edx.sprite_size_x],panel_nbs_ball_size_x
            mov [edx.sprite_pos_x],panel_nbs_ball_pos_x
            mov ecx,player_1.player_nbs_ball
            jecxz @@end
@@again:
            add [edx.sprite_size_x],12
            add [edx.sprite_current_adrs],-12
            add [edx.sprite_pos_x],-12
            loop @@again
@@end:
            ret


;----------------------------------------------------------------------------
display_nbs_ball_player_2:
;----------------------------------------------------------------------------

            cmp dual_flag,On
            jne @@end

            lea edx,Panel_Nbs_Ball_2
            mov [edx.sprite_current_adrs],panel_nbs_ball_2_o
            mov [edx.sprite_adrs],panel_nbs_ball_2_o
            mov [edx.sprite_size_x],panel_nbs_ball_size_x
            mov [edx.sprite_pos_x],panel_nbs_ball_pos_x
            mov ecx,player_2.player_nbs_ball
            jecxz @@end
@@again:
            add [edx.sprite_size_x],12
            add [edx.sprite_current_adrs],-12
            add [edx.sprite_pos_x],-12
            loop @@again
@@end:
            ret


;----------------------------------------------------------------------------
flip_telepod:
;----------------------------------------------------------------------------

            cmp game_mode,EDIT
            je @@end

            lea esi,level_tbl
            mov ecx,nbs_brique_x*nbs_brique_y
            mov ebx,bord_x
            mov edi,bord_y
@@again:
            push ecx
            lodsb
            push esi
            dec esi
            sub esi,O level_tbl
            and al,type_de_brique
            cmp al,teleporteuse
            jne @@cont

            mov ecx,brique_size_y
            mov edx,brique_size_x
            call flip_screen
            jmp @@exit
@@cont:
            cmp al,incassable
            jne @@exit

            lea eax,level_flip
            cmp B [esi+eax],Off
            je @@exit
            mov B [esi+eax],Off

            mov ecx,brique_size_y
            mov edx,brique_size_x
            call flip_screen
@@exit:
            pop esi
            add ebx,brique_size_x
            cmp ebx,bord_x+(brique_size_x*nbs_brique_x)
            jb @@cont2
            mov ebx,bord_x
            add edi,brique_size_y
@@cont2:    pop ecx
            loop @@again
@@end:
            ret


;----------------------------------------------------------------------------
draw_telepod:
;----------------------------------------------------------------------------

            cmp game_mode,EDIT
            je @@end
            inc telepod_delai
            cmp telepod_delai,DELAI_TELEPOD
            jb @@end
            mov telepod_delai,Off

            lea esi,level_tbl
            mov ecx,nbs_brique_x*nbs_brique_y
            mov ebx,bord_x
            mov edi,bord_y
@@again:
            push ecx
            lodsb
            push esi
            dec esi
            sub esi,O level_tbl
            and al,type_de_brique
            cmp al,teleporteuse
            jne @@cont

            mov ecx,brique_size_y
            mov edx,brique_size_x
            call _erase_shape

            lea eax,brique_tbl
            mov esi,[eax+esi*4]
            add esi,current_telepod
            call _draw_shape
@@cont:
            pop esi
            add ebx,brique_size_x
            cmp ebx,bord_x+(brique_size_x*nbs_brique_x)
            jb @@cont2
            mov ebx,bord_x
            add edi,brique_size_y
@@cont2:    pop ecx
            loop @@again

            add current_telepod,next_brique
            cmp current_telepod,next_brique*6
            jb @@end
            mov current_telepod,0
@@end:
            ret

            .data
current_telepod     dd next_brique
telepod_delai       dd Off
            .code


;----------------------------------------------------------------------------
draw_brique_incassable:
;----------------------------------------------------------------------------

            cmp game_mode,EDIT
            je @@end

            lea esi,level_tbl
            mov ecx,nbs_brique_x*nbs_brique_y
            mov ebx,bord_x
            mov edi,bord_y
@@again:
            push ecx
            lodsb
            push esi
            dec esi
            sub esi,O level_tbl
            and al,type_de_brique
            cmp al,incassable
            jne @@cont

            mov ecx,brique_size_y
            mov edx,brique_size_x

            lea eax,brique_tbl
            cmp D [eax+esi*4],brique_reflet_o
            jb @@cont
            push ebx
            lea ebx,level_flip
            mov B [esi+ebx],On
            mov ebx,[eax+esi*4]
            sub ebx,next_reflet
            mov [eax+esi*4],ebx
            mov esi,ebx
            pop ebx
            call _draw_shape
@@cont:
            pop esi
            add ebx,brique_size_x
            cmp ebx,bord_x+(brique_size_x*nbs_brique_x)
            jb @@cont2
            mov ebx,bord_x
            add edi,brique_size_y
@@cont2:    pop ecx
            loop @@again
@@end:
            ret


;----------------------------------------------------------------------------
detect_new_option:
;----------------------------------------------------------------------------

            cmp game_mode,PLAYING
            je @@ok
            ret
@@ok:
            mov eax,current_option
            cmp eax,Off
            je @@end

            lea edx,Option_3_ball
@@loop:
            cmp [edx.option_status],last
            je @@end
            cmp [edx.option_adrs],eax
            jne @@next
            mov ebp,[edx.option_call]
            pushad
            pushad
            lea esi,[edx.option_text]
            cmp esi,last_print
            je @@cont
            mov last_print,esi
            call print
@@cont:
            popad
            call ebp
            popad
@@next:
            add edx,size struc_options
            jmp @@loop
@@end:
            ret

            .data
last_print  dd ?
            .code


;----------------------------------------------------------------------------
detect_current_option_end:
;----------------------------------------------------------------------------

            cmp game_mode,PLAYING
            je @@ok
            ret
@@ok:
            cmp current_option_count,Off
            je @@end
            dec current_option_count
            cmp current_option_count,DELAI_INFO
            je @@display_info_off
            ;cmp current_option_count,DELAI_INFO_SOUND
            ;je @@current_option_off_sound
            cmp current_option_count,Off
            je @@current_option_off
@@end:
            Send current_option_count,10,5
            ret

@@display_info_off:
            call print_off
            cmp current_option,off
            je @@_current_option_off
            ret

@@current_option_off:
            play_sound iff_option_off
            call reset_magnetic
            mov current_option,off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            call init_palette
@@_current_option_off:
            mov last_print,-1
            mov panel_option.sprite_adrs,option_off
            mov panel_option.sprite_current_adrs,option_off
            ret

@@current_option_off_sound:
            play_sound iff_option_off
            ret

            .data
current_option_count dd Off
            .code


;----------------------------------------------------------------------------
option_3_ball_p:
;----------------------------------------------------------------------------

            mov ecx,1
            call add_ball
            ;push old_option
            ;pop  current_option
            ;mov  last_print,-1
            mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            ret


;----------------------------------------------------------------------------
option_6_ball_p:
;----------------------------------------------------------------------------

            mov ecx,3
            call add_ball
            ;push old_option
            ;pop  current_option
            ;mov  last_print,-1
            mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            ret


;----------------------------------------------------------------------------
option_9_ball_p:
;----------------------------------------------------------------------------

            mov ecx,6
            call add_ball
            ;push old_option
            ;pop  current_option
            ;mov  last_print,-1
            mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            ret


;----------------------------------------------------------------------------
option_20_ball_p:
;----------------------------------------------------------------------------

            mov ecx,20
            call add_ball
            ;push old_option
            ;pop  current_option
            ;mov  last_print,-1
            mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            ret


;----------------------------------------------------------------------------
option_death_p:
;----------------------------------------------------------------------------

            play_sound iff_death

            mov ebp,current_player
            cmp dual_flag,On
            je @@ok2
            lea ebp,player_1
@@ok2:
            cmp [ebp.player_nbs_ball],0
            je @@end
            dec [ebp.player_nbs_ball]
@@end:      mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            call display_nbs_ball_player_1
            call display_nbs_ball_player_2
            ret


;----------------------------------------------------------------------------
option_new_life_p:
;----------------------------------------------------------------------------

            play_sound iff_new_life

            mov ebp,current_player
            cmp dual_flag,On
            je @@ok2
            lea ebp,player_1
@@ok2:
            inc [ebp.player_nbs_ball]
            cmp [ebp.player_nbs_ball],NBS_BALL_MAX
            jb @@ok
            mov [ebp.player_nbs_ball],NBS_BALL_MAX
@@ok:
            mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off

            call display_nbs_ball_player_1
            call display_nbs_ball_player_2
            ret


;----------------------------------------------------------------------------
detect_new_life_player_1:
;----------------------------------------------------------------------------

            cmp game_mode,PLAYING
            jne @@end

            mov eax,player_1.player_counter_score
            cmp eax,player_1.player_bonus_life
            jb @@end
            mov eax,bonus_extra_life
            add player_1.player_bonus_life,eax

            mov ecx,8
            mov ebp,O player_1
            call inc_score

            lea esi,option_new_life.option_text
            mov last_print,esi
            call print

            mov current_player,O player_1
            call option_new_life_p
@@end:
            ret


;----------------------------------------------------------------------------
detect_new_life_player_2:
;----------------------------------------------------------------------------

            cmp nbs_player,2
            jne @@end
            cmp game_mode,PLAYING
            jne @@end
            cmp dual_flag,On
            jne @@end

            mov eax,player_2.player_counter_score
            cmp eax,player_2.player_bonus_life
            jb @@end
            mov eax,bonus_extra_life
            add player_2.player_bonus_life,eax

            mov ecx,8
            mov ebp,O player_2
            call inc_score

            lea esi,option_new_life.option_text
            mov last_print,esi
            call print

            mov current_player,O player_2
            call option_new_life_p
@@end:
            ret


;----------------------------------------------------------------------------
option_shoot_p:
;----------------------------------------------------------------------------

            cmp current_player,O Player_1
            jne @@ok1
                        cmp init_big_shoot_flag_1,On
                        je @@ok1
                        mov init_big_shoot_flag_1,On

                        mov cursor_1_tir_big.sprite_shape_speed,vaisseau_tir_big_speed
                        mov cursor_1_tir_big.sprite_current_speed,vaisseau_tir_big_speed
                        mov cursor_1_tir_big.sprite_adrs,vaisseau_1_tir_big_o
                        push cursor_1_tir_big.sprite_adrs
                        pop cursor_1_tir_big.sprite_current_adrs
                        mov cursor_1_tir_big.sprite_nbs_shape,vaisseau_tir_big_nbs_anim
                        mov cursor_1_tir_big.sprite_current_shape,1
                        mov count_tir_big_1,10

@@ok1:
            cmp current_player,O Player_2
            jne @@ok2
                        cmp init_big_shoot_flag_2,On
                        je @@ok2
                        mov init_big_shoot_flag_2,On

                        mov cursor_2_tir_big.sprite_shape_speed,vaisseau_tir_big_speed
                        mov cursor_2_tir_big.sprite_current_speed,vaisseau_tir_big_speed
                        mov cursor_2_tir_big.sprite_adrs,vaisseau_2_tir_big_o
                        push cursor_2_tir_big.sprite_adrs
                        pop cursor_2_tir_big.sprite_current_adrs
                        mov cursor_2_tir_big.sprite_nbs_shape,vaisseau_tir_big_nbs_anim
                        mov cursor_2_tir_big.sprite_current_shape,1
                        mov count_tir_big_2,10
@@ok2:
@@end:
            ret

init_big_shoot_flag_1 dd Off
init_big_shoot_flag_2 dd Off


            ret


;----------------------------------------------------------------------------
option_mini_shoot_p:
;----------------------------------------------------------------------------

            cmp current_player,O Player_1
            jne @@ok1
                        cmp init_mini_shoot_flag_1,On
                        je @@ok1
                        mov init_mini_shoot_flag_1,On

                        mov cursor_1_tir_left.sprite_shape_speed,vaisseau_tir_speed
                        mov cursor_1_tir_left.sprite_current_speed,vaisseau_tir_speed
                        mov cursor_1_tir_left.sprite_adrs,vaisseau_1_tir_left_o
                        push cursor_1_tir_left.sprite_adrs
                        pop cursor_1_tir_left.sprite_current_adrs
                        mov cursor_1_tir_left.sprite_nbs_shape,vaisseau_tir_nbs_anim
                        mov cursor_1_tir_left.sprite_current_shape,6
                        mov count_tir_left_1,12

                        mov cursor_1_tir_right.sprite_shape_speed,vaisseau_tir_speed
                        mov cursor_1_tir_right.sprite_current_speed,vaisseau_tir_speed
                        mov cursor_1_tir_right.sprite_adrs,vaisseau_1_tir_right_o
                        push cursor_1_tir_right.sprite_adrs
                        pop cursor_1_tir_right.sprite_current_adrs
                        mov cursor_1_tir_right.sprite_nbs_shape,vaisseau_tir_nbs_anim
                        mov cursor_1_tir_right.sprite_current_shape,6
                        mov count_tir_right_1,12
@@ok1:
            cmp current_player,O Player_2
            jne @@ok2
                        cmp init_mini_shoot_flag_2,On
                        je @@ok2
                        mov init_mini_shoot_flag_2,On

                        mov cursor_2_tir_left.sprite_shape_speed,vaisseau_tir_speed
                        mov cursor_2_tir_left.sprite_current_speed,vaisseau_tir_speed
                        mov cursor_2_tir_left.sprite_adrs,vaisseau_2_tir_left_o
                        push cursor_2_tir_left.sprite_adrs
                        pop cursor_2_tir_left.sprite_current_adrs
                        mov cursor_2_tir_left.sprite_nbs_shape,vaisseau_tir_nbs_anim
                        mov cursor_2_tir_left.sprite_current_shape,6
                        mov count_tir_left_2,12

                        mov cursor_2_tir_right.sprite_shape_speed,vaisseau_tir_speed
                        mov cursor_2_tir_right.sprite_current_speed,vaisseau_tir_speed
                        mov cursor_2_tir_right.sprite_adrs,vaisseau_2_tir_right_o
                        push cursor_2_tir_right.sprite_adrs
                        pop cursor_2_tir_right.sprite_current_adrs
                        mov cursor_2_tir_right.sprite_nbs_shape,vaisseau_tir_nbs_anim
                        mov cursor_2_tir_right.sprite_current_shape,6
                        mov count_tir_right_2,12
@@ok2:
@@end:
            ret

init_mini_shoot_flag_1 dd Off
init_mini_shoot_flag_2 dd Off


;----------------------------------------------------------------------------
option_slow_ball_p:
;----------------------------------------------------------------------------

            ret


;----------------------------------------------------------------------------
option_fast_ball_p:
;----------------------------------------------------------------------------

            ret


;----------------------------------------------------------------------------
option_iron_ball_p:
;----------------------------------------------------------------------------

            ret


;----------------------------------------------------------------------------
option_telepod_p:
;----------------------------------------------------------------------------

            ret


;----------------------------------------------------------------------------
option_night_p:
;----------------------------------------------------------------------------

            cmp option_night_flag,On
            je @@end
            mov option_night_flag,On

            play_sound iff_night

            mov edi,256*3*16
            mov eax,0
            mov esi,offset palette
            add esi,eax
            add esi,eax
            add esi,eax
            add esi,edi
            mov ecx,256*3
          ÿÿcall set_palette
            mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
@@end:
            ret


;----------------------------------------------------------------------------
detect_init_palette:
;----------------------------------------------------------------------------

            cmp option_night_flag,Off
            je @@end
            cmp current_option,Off
            je @@end
            mov option_night_flag,Off
            call init_palette
@@end:
            ret


;----------------------------------------------------------------------------
init_palette:
;----------------------------------------------------------------------------

            mov option_night_flag,Off

            mov edi,256*3*0
            mov eax,0
            mov esi,offset palette
            add esi,eax
            add esi,eax
            add esi,eax
            add esi,edi
            mov ecx,256*3
          ÿÿcall set_palette
            ret

            .data
option_night_flag dd Off
            .code


;----------------------------------------------------------------------------
option_small_ship_p:
;----------------------------------------------------------------------------

            ret


;----------------------------------------------------------------------------
option_large_ship_p:
;----------------------------------------------------------------------------

            ret


;----------------------------------------------------------------------------
option_reverse_p:
;----------------------------------------------------------------------------

            ret


;----------------------------------------------------------------------------
option_next_level_p:
;----------------------------------------------------------------------------

            ret


;----------------------------------------------------------------------------
option_del_monster_p:
;----------------------------------------------------------------------------

            call destruction_monster
            mov current_option,off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            ret


;----------------------------------------------------------------------------
option_magnetic_p:
;----------------------------------------------------------------------------

            push old_option
            push old_option
            push old_option
            pop  current_option
            pop player_1.player_current_option
            pop player_2.player_current_option
            mov  last_print,-1

            cmp current_player,O Player_1
            jne @@ok1
            or magnetic_flag,PLAYER_ONE
@@ok1:
            cmp current_player,O Player_2
            jne @@ok2
            or magnetic_flag,PLAYER_TWO
@@ok2:
            ret


;----------------------------------------------------------------------------
option_add_monster_p:
;----------------------------------------------------------------------------

            call add_monster
            mov current_option,off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            ret


;----------------------------------------------------------------------------
option_ghost_p:
;----------------------------------------------------------------------------

            mov ecx,20

            cmp nbs_player,2
            jne @@cont
            mov ecx,10
@@cont:
            call add_ball
            mov current_option,Off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            call set_ghost
            ret


;----------------------------------------------------------------------------
option_bonus_p:
;----------------------------------------------------------------------------

            push ecx
            push ebp
            mov ecx,8
            mov ebp,current_player
            call inc_score
            pop ebp
            pop ecx

            mov current_option,off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            ret


;----------------------------------------------------------------------------
option_malus_p:
;----------------------------------------------------------------------------

            push ebp
            push ecx
            mov ecx,12
            mov ebp,current_player
            call dec_score
            pop ebp
            pop ecx

            mov current_option,off
            mov player_1.player_current_option,Off
            mov player_2.player_current_option,Off
            ret


;----------------------------------------------------------------------------
option_collision_p:
;----------------------------------------------------------------------------

            mov eax,cursor_2.sprite_pos_x
            sub eax,cursor_1.sprite_pos_x
            mov collision_flag,eax
            ret


;----------------------------------------------------------------------------
; Variables
;----------------------------------------------------------------------------

            .data

            if debug_mode
About       db 0,15
            db 'B-L-U-S-T-E-R  Version 0.35  March 1999',13,10
            db 'Copyright (c) Eclipse 1999',13,10
            db 0,7
            db "    þ E-Mail : "
            db 0,11
            db "Eclipse@aic.fr",13,10
            db 0,7
Exit_Txt    db 0,0
            endif

;----------------------------------------------------------------------------
; Message d'Erreur
;----------------------------------------------------------------------------

           if dos_mode
Ecran_Mono db 'Speed X : 00000000',13,10
           db 'Speed Y : 00000000',13,10
           db 'Angle   : 00000000',13,10
           db 'Speed   : 00000000 00000000',13,10
           db 'Bounce  : 00000000 00000000',13,10
           db 'Option  : 00000000         ',13,10
           db 'Mode    : 00000000         ',13,10
           db '                  ',13,10
           db 'Use KeyPad 0 for Vbl',13,10
           db 36
           endif

;----------------------------------------------------------------------------
; Message d'Erreur
;----------------------------------------------------------------------------

               if debug_mode
Sound_Ok_Txt   db  '    þ Manual Sound Setup detected',13,10,36
Sound_Bad_Txt  db  '    þ The program cannot use the current sound card',13,10
               db  '      You should run the SETSOUND.EXE program to configure your sound card',13,10
               db  '    þ Press a key to continue without any sound',13,10,36
Mouse_Bad_Txt  db  '    þ Mouse not found',13,10,36
Mouse_Ok_Txt   db  '    þ Mouse driver detected',13,10,36
Windows_Txt    db  "    þ Sorry, but this program can run under Microsoft Windows 3.1 (tm)",13,10,36
Mem_Txt        db  '    þ Out of memory !',13,10,36
File_Txt       db  '    þ File Error !',13,10,36
Vesa_Txt       db  '    þ Mode SVGA not supported or VESA not found !',13,10
               db  '      To install a vesa driver, refer to your video card documentation.',13,10,36
               endif

;----------------------------------------------------------------------------
; Menus
;----------------------------------------------------------------------------

struc_menus             struc
  menu_number           dd ?
  menu_pos_x            dd ?
  menu_pos_y            dd ?
  menu_size_x           dd ?
  menu_size_y           dd ?
  menu_pal              dd 0
  menu_pal_size         dd 0
  menu_text             db "                "
  menu_text_end         db 0
  menu_text_2           db "                "
  menu_text_2_end       db 0
  menu_action           dd 0
struc_menus             ends

menu_text_number = 30

menu_begin   struc_menus <First,000,000,000,000,menu_1_pal,menu_1_pal_size,"                ",0,"                ",0,m_play       >
menu_text_1a struc_menus <1    ,192,142,317,268,menu_1_pal,menu_1_pal_size,"                ",0,"                ",0,m_play       >
menu_text_1b struc_menus <1    ,322,142,447,268,menu_2_pal,menu_2_pal_size,"                ",0,"                ",0,m_demo       >
menu_text_1c struc_menus <1    ,192,273,317,399,menu_3_pal,menu_3_pal_size,"                ",0,"                ",0,m_misc       >
menu_text_1d struc_menus <1    ,322,273,447,399,menu_4_pal,menu_4_pal_size,"                ",0,"                ",0,m_quit       >
menu_text_2a struc_menus <2    ,192,142,317,268,menu_1_pal,menu_1_pal_size,"                ",0,"                ",0,m_solo       >
menu_text_2b struc_menus <2    ,322,142,447,268,menu_2_pal,menu_2_pal_size,"                ",0,"                ",0,m_coop       >
menu_text_2c struc_menus <2    ,192,273,317,399,menu_3_pal,menu_3_pal_size,"                ",0,"                ",0,m_dual       >
menu_text_2d struc_menus <2    ,322,273,447,399,menu_4_pal,menu_4_pal_size,"                ",0,"                ",0,m_cancel     >
menu_text_3a struc_menus <3    ,192,142,317,268,menu_1_pal,menu_1_pal_size,"                ",0,"                ",0,m_computer   >
menu_text_3b struc_menus <3    ,322,142,447,268,menu_2_pal,menu_2_pal_size,"                ",0,"                ",0,m_keyboard   >
menu_text_3c struc_menus <3    ,192,273,317,399,menu_3_pal,menu_3_pal_size,"                ",0,"                ",0,m_joystick   >
menu_text_3d struc_menus <3    ,322,273,447,399,menu_4_pal,menu_4_pal_size,"                ",0,"                ",0,m_cancel     >
menu_text_4a struc_menus <4    ,192,142,317,268,menu_1_pal,menu_1_pal_size,"                ",0,"                ",0,m_space      >
menu_text_4b struc_menus <4    ,322,142,447,268,menu_2_pal,menu_2_pal_size,"                ",0,"                ",0,m_eclipse    >
menu_text_4c struc_menus <4    ,192,273,317,399,menu_3_pal,menu_3_pal_size,"                ",0,"                ",0,m_nothing    >
menu_text_4d struc_menus <4    ,322,273,447,399,menu_4_pal,menu_4_pal_size,"                ",0,"                ",0,m_cancel     >
menu_text_5a struc_menus <5    ,192,142,317,268,menu_1_pal,menu_1_pal_size,"                ",0,"                ",0,m_easy       >
menu_text_5b struc_menus <5    ,322,142,447,268,menu_2_pal,menu_2_pal_size,"                ",0,"                ",0,m_normal     >
menu_text_5c struc_menus <5    ,192,273,317,399,menu_3_pal,menu_3_pal_size,"                ",0,"                ",0,m_hard       >
menu_text_5d struc_menus <5    ,322,273,447,399,menu_4_pal,menu_4_pal_size,"                ",0,"                ",0,m_cancel     >
menu_text_6a struc_menus <6    ,192,142,317,268,menu_1_pal,menu_1_pal_size,"                ",0,"                ",0,m_score_1    >
menu_text_6b struc_menus <6    ,322,142,447,268,menu_2_pal,menu_2_pal_size,"                ",0,"                ",0,m_score_2    >
menu_text_6c struc_menus <6    ,192,273,317,399,menu_3_pal,menu_3_pal_size,"                ",0,"                ",0,m_credit     >
menu_text_6d struc_menus <6    ,322,273,447,399,menu_4_pal,menu_4_pal_size,"                ",0,"                ",0,m_cancel_2   >
menu_text_7a struc_menus <7    ,192,142,317,268,menu_1_pal,menu_1_pal_size,"                ",0,"                ",0,m_joy_ana    >
menu_text_7b struc_menus <7    ,322,142,447,268,menu_2_pal,menu_2_pal_size,"                ",0,"                ",0,m_paddle     >
menu_text_7c struc_menus <7    ,192,273,317,399,menu_3_pal,menu_3_pal_size,"                ",0,"                ",0,m_nothing    >
menu_text_7d struc_menus <7    ,322,273,447,399,menu_4_pal,menu_4_pal_size,"                ",0,"                ",0,m_cancel_3   >
menu_last    struc_menus <Last ,000,000,000,000,menu_1_pal,menu_1_pal_size,"                ",0,"                ",0,m_play       >

;----------------------------------------------------------------------------
; Options
;----------------------------------------------------------------------------

struc_options           struc
  option_status         dd ?
  option_easy           dd ?
  option_medium         dd ?
  option_hard           dd ?
  option_adrs           dd ?
  option_call           dd ?
  option_text           db "            "
  option_text_end       db 0
struc_options           ends

options_number       = 24

option_forced        dd off;option_mini_shoot_o

Option_3_ball      struc_options <On ,3,3,4,option_3_ball_o     ,option_3_ball_p     ,"   1 ball   ">
Option_6_ball      struc_options <On ,3,3,5,option_6_ball_o     ,option_6_ball_p     ,"  3 balls   ">
Option_9_ball      struc_options <On ,3,3,6,option_9_ball_o     ,option_9_ball_p     ,"  6 balls   ">
Option_20_ball     struc_options <On ,3,9,9,option_20_ball_o    ,option_20_ball_p    ,"  20 balls  ">
Option_death       struc_options <On ,3,3,4,option_death_o      ,option_death_p      ," lost life  ">
Option_new_life    struc_options <On ,3,9,9,option_new_life_o   ,option_new_life_p   ,"  new life  ">
Option_shoot       struc_options <On ,1,3,4,option_shoot_o      ,option_shoot_p      ," big shoot  ">
Option_slow_ball   struc_options <On ,3,3,4,option_slow_ball_o  ,option_slow_ball_p  ,"    slow    ">
Option_fast_ball   struc_options <On ,3,3,3,option_fast_ball_o  ,option_fast_ball_p  ,"    fast    ">
Option_iron_ball   struc_options <On ,3,3,4,option_iron_ball_o  ,option_iron_ball_p  ," iron ball  ">
Option_telepod     struc_options <On ,3,3,4,option_telepod_o    ,option_telepod_p    ,"  telepod   ">
Option_night       struc_options <On ,3,3,4,option_night_o      ,option_night_p      ,"  point x2  ">
Option_small_ship  struc_options <On ,3,3,3,option_small_ship_o ,option_small_ship_p ," small ship ">
Option_large_ship  struc_options <On ,3,3,4,option_large_ship_o ,option_large_ship_p ," large ship ">
Option_reverse     struc_options <On ,3,3,3,option_reverse_o    ,option_reverse_p    ,"  reverse   ">
Option_next_level  struc_options <On ,3,9,9,option_next_level_o ,option_next_level_p ," next level ">
Option_del_monster struc_options <On ,1,3,4,option_del_monster_o,option_del_monster_p,"wrath of god">
Option_magnetic    struc_options <On ,1,3,4,option_magnetic_o   ,option_magnetic_p   ,"  magnetic  ">
Option_add_monster struc_options <On ,1,3,3,option_add_monster_o,option_add_monster_p,"summon beast">
Option_ghost       struc_options <On ,1,3,4,option_ghost_o      ,option_ghost_p      ,"   ghost    ">
Option_bonus       struc_options <On ,3,3,4,option_bonus_o      ,option_bonus_p      ,"  +100 pts  ">
Option_malus       struc_options <On ,3,3,3,option_malus_o      ,option_malus_p      ,"  -100 pts  ">
Option_mini_shoot  struc_options <On ,1,3,4,option_mini_shoot_o ,option_mini_shoot_p ,"   shoot    ">
Option_collision   struc_options <Off,0,0,0,option_collision_o  ,option_collision_p  ," collision  ">
Option_Last        struc_options <Last                                                             >

option_text_number = 8

option_text_off     db "            ",0
option_text_ready   db "  ready ?   ",0
option_text_over    db " game over  ",0
option_text_again   db " play again ",0
option_text_editor  db "level editor",0
option_text_paused  db "game paused ",0
option_text_demo    db "    demo    ",0
option_text_test    db "    test    ",0

;----------------------------------------------------------------------------
; Sprites
;----------------------------------------------------------------------------

struc_sprites           struc
  sprite_mode           db ?
  sprite_status         dd ?
  sprite_size_x         dd ?
  sprite_size_y         dd ?
  sprite_adrs           dd ?

  sprite_sens_x         dd ?
  sprite_sens_y         dd ?
  sprite_angle          dd ?
  sprite_old_size_x     dd ?
  sprite_old_size_y     dd ?
  sprite_new_xy         dd ?
  sprite_old_xy         dd ?
  sprite_new_xy_dx      dd ?
  sprite_old_xy_dx      dd ?
  sprite_buffer_adrs    dd ?
  sprite_screen_x       dd ?
  sprite_current_adrs   dd ?
  sprite_pos_x          dd ?
  sprite_pos_y          dd ?
  sprite_min_x          dd ?
  sprite_min_y          dd ?
  sprite_max_x          dd ?
  sprite_max_y          dd ?
  sprite_rebond         dd ?
  sprite_speed_counter  dd ?

  sprite_nbs_shape      dd ?
  sprite_current_shape  dd ?
  sprite_shape_speed    dd ?
  sprite_current_speed  dd ?
  sprite_next_shape     dd ?

  sprite_counter_1      dd ?
  sprite_counter_2      dd ?
  sprite_counter_3      dd ?
  sprite_bak_x          dd ?
  sprite_bak_y          dd ?

  sprite_delete         dd ?
  sprite_to_delete      dd ?

  sprite_magnetic       dd ?
  sprite_decal_x        dd ?

  sprite_ghost          dd ?

  sprite_player         dd ?
struc_sprites           ends

Begin_Sprites       struc_sprites <First   >

Option_1            struc_sprites <Option  >
Option_2            struc_sprites <Option  >
Option_3            struc_sprites <Option  >
Option_4            struc_sprites <Option  >
Option_5            struc_sprites <Option  >
Option_6            struc_sprites <Option  >
Option_7            struc_sprites <Option  >
Option_8            struc_sprites <Option  >

Ball_1              struc_sprites <Ball    >
Ball_2              struc_sprites <Ball    >
Ball_3              struc_sprites <Ball    >
Ball_4              struc_sprites <Ball    >
Ball_5              struc_sprites <Ball    >
Ball_6              struc_sprites <Ball    >
Ball_7              struc_sprites <Ball    >
Ball_8              struc_sprites <Ball    >
Ball_9              struc_sprites <Ball    >
Ball_10             struc_sprites <Ball    >
Ball_11             struc_sprites <Ball    >
Ball_12             struc_sprites <Ball    >
Ball_13             struc_sprites <Ball    >
Ball_14             struc_sprites <Ball    >
Ball_15             struc_sprites <Ball    >
Ball_16             struc_sprites <Ball    >
Ball_17             struc_sprites <Ball    >
Ball_18             struc_sprites <Ball    >
Ball_19             struc_sprites <Ball    >
Ball_20             struc_sprites <Ball    >

Cursor_1            struc_sprites <Vaisseau>
Cursor_1_tir_left   struc_sprites <Vaisseau>
Cursor_1_tir_right  struc_sprites <Vaisseau>
Cursor_1_tir_big    struc_sprites <Vaisseau>
Cursor_2            struc_sprites <Vaisseau>
Cursor_2_tir_left   struc_sprites <Vaisseau>
Cursor_2_tir_right  struc_sprites <Vaisseau>
Cursor_2_tir_big    struc_sprites <Vaisseau>

Monster_1           struc_sprites <Monster >
Monster_2           struc_sprites <Monster >
Monster_3           struc_sprites <Monster >
Monster_4           struc_sprites <Monster >
Monster_5           struc_sprites <Monster >

Shoot_1             struc_sprites <Shoot   >
Shoot_2             struc_sprites <Shoot   >
Shoot_3             struc_sprites <Shoot   >
Shoot_4             struc_sprites <Shoot   >
Shoot_5             struc_sprites <Shoot   >
Shoot_6             struc_sprites <Shoot   >
Shoot_7             struc_sprites <Shoot   >
Shoot_8             struc_sprites <Shoot   >
Shoot_9             struc_sprites <Shoot   >
Shoot_10            struc_sprites <Shoot   >
Shoot_11            struc_sprites <Shoot   >
Shoot_12            struc_sprites <Shoot   >
Shoot_13            struc_sprites <Shoot   >
Shoot_14            struc_sprites <Shoot   >
Shoot_15            struc_sprites <Shoot   >
Shoot_16            struc_sprites <Shoot   >
Shoot_17            struc_sprites <Shoot   >
Shoot_18            struc_sprites <Shoot   >
Shoot_19            struc_sprites <Shoot   >
Shoot_20            struc_sprites <Shoot   >

Panel_Nbs_Ball_1    struc_sprites <Panel   >
Panel_Nbs_Ball_2    struc_sprites <Panel   >
Panel_Option        struc_sprites <Panel   >
Panel_Level         struc_sprites <Panel   >
Panel_Score         struc_sprites <Panel   >
Panel_Score_2       struc_sprites <Panel   >
Panel_Info          struc_sprites <Panel   >

Test_1              struc_sprites <Profil  >

End_Sprites         struc_sprites <Last    >

;----------------------------------------------------------------------------
; Players
;----------------------------------------------------------------------------

struc_players           struc
  player_cursor         dd ?
  player_panel          dd ?
  player_current_option dd ?
  player_left_or_right  dd On
  player_click_flag     dd Off
  player_counter_score  dd 0
  player_score_txt      db 1,'000000',0
  player_nbs_ball       dd ?
  player_bonus_life     dd ?
struc_players           ends

player_1    struc_players <O cursor_1,panel_score_1_o>
player_2    struc_players <O cursor_2,panel_score_2_o>

current_player      dd ?

;----------------------------------------------------------------------------
; Divers
;----------------------------------------------------------------------------

_key_map     dd ?


;----------------------------------------------------------------------------
; Joystick
;----------------------------------------------------------------------------

ifdef WIN32
Joy_Addr    dd 0
endif

            .code