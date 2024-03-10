;----------------------------------------------------------------------------
; Fichiers
;----------------------------------------------------------------------------

            .data

File_Fond      db 'resource\00_01.gif',0
File_Sprite_   db 'resource\sprite.gif',0
File_Palette   db 'sprite0.pal',0

Music_Intro    db 'resource\blaster.mod',0
Music_Game0    db 'resource\thelast.mod',0
Music_Game1    db 'resource\lode.mod',0
;Music_Game2    db 'resource\no.mod',0
Music_Credit   db 'resource\credit.mod',0
Music_Score    db 'resource\rain.mod',0

File_Menu      db 'resource\menu.gif',0
File_Monster   db 'resource\monster.gif',0
File_Fonte     db 'resource\fonte.gif',0
File_Bluster   db 'resource\blaster.gif',0
File_Credit_m  db 'resource\credit_m.gif',0
File_Credit_g  db 'resource\credit_g.gif',0
File_Credit_c  db 'resource\credit_c.gif',0
File_Credit_w  db 'resource\credit_w.gif',0
File_Credit_b  db 'resource\credit_b.gif',0
File_Credit_e  db 'resource\credit_e.gif',0
File_Intro     db 'resource\intro.flc',0

File_Final     db 'Blaster.flc',0
File_Editor    db 'Media.gif',0

true_background_Buffer      dd ?
Background_Buffer           dd ?
Video_Buffer                dd ?
;Option_Buffer               dd ?
Monster_Buffer              dd ?
Sprite_Buffer               dd ?
Fonte_Buffer                dd ?
Palette_Buffer              dd ?

true_background_Handle      dd ?
Background_Handle           dd ?
Video_Handle                dd ?
;Option_Handle               dd ?
Monster_Handle              dd ?
Sprite_Handle               dd ?
Fonte_Handle                dd ?
Palette_Handle              dd ?
            .code


;----------------------------------------------------------------------------
load_intro_anim:
;----------------------------------------------------------------------------

            lea edx,File_Intro        ; Load a FLI or FLC into the memory
            call Load_internal_Fli           ; Initialize if needed the track-disk mode
            jc @@Fli_Error            ; and check the header

            mov Fli_Svga,On
            mov eax,direct_x_pitch
            mov Fli_Scr_X,eax
            mov Fli_Scr_Y,480
            mov Fli_Loop,Off

            mov shade_volume,Off
            mov shade_org,0
            mov shade_len,256
            call Shade_Off

            mov edi,video_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            xor eax,eax
            rep stosd

            mov esi,video_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            call flip_buffer

@@wait2:
            call wait_synchro
            call read_click
            jnz @@wait2
            call wait_keyboard_release

            call First_Frame_Fli    ; Uncompress the first frame
            jc @@Fli_Error

            mov shade_volume,Off
            mov shade_org,0
            mov shade_len,256
            call Shade_On

            ;mov ecx,33;17
@@again:
            ;push ecx
            mov ecx,5
@@wait:
            call wait_synchro
            loop @@wait

            call Next_Frame_Fli     ; Uncompress next frame
            jc @@Fli_Error

            ;pop ecx
            ;loop @@again

            cmp fli_last_frame,Off
            je @@again

@@Fli_Error:
            call Dispose_Fli        ; Freeing memory and close file
            ret


;----------------------------------------------------------------------------
load_final_anim:
;----------------------------------------------------------------------------

            lea edx,Music_score
            call Load_Music

            mov Fli_TrackDisk,On

            lea edx,File_Final      ; Load a FLI or FLC into the memory
            call Load_Fli           ; Initialize if needed the track-disk mode
            jc @@Fli_Error            ; and check the header

            mov Fli_Svga,On
            mov eax,direct_x_pitch
            mov Fli_Scr_X,eax
            mov Fli_Scr_Y,480
            mov Fli_Loop,Off

            mov shade_volume,Off
            mov shade_org,0
            mov shade_len,256
            call Shade_Off

            mov edi,video_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            xor eax,eax
            rep stosd

            mov esi,video_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            call flip_buffer

@@wait2:
            call wait_synchro
            call read_click
            jnz @@wait2
            call wait_keyboard_release

            call First_Frame_Fli    ; Uncompress the first frame
            jc @@Fli_Error

            mov shade_volume,Off
            mov shade_org,0
            mov shade_len,256
            call Shade_On

            mov ecx,417-33
@@again:
            push ecx
            mov ecx,5
@@wait:
            call wait_synchro
            loop @@wait

            call Next_Frame_Fli     ; Uncompress next frame
            pop ecx
            jc @@Fli_Error

            loop @@again
            ;cmp fli_last_frame,Off
            ;je @@again

@@Fli_Error:
            call Dispose_Fli        ; Freeing memory and close file

            ret


;----------------------------------------------------------------------------
Load_Picture_Menu:
;----------------------------------------------------------------------------

            call free_memory

            lea edx,File_Fonte
            call Load_Internal_Gif_Handle
            jc Error_file
            mov fonte_buffer,eax
            mov fonte_handle,edi

            lea edx,File_Menu
            call Load_Internal_Gif_Handle
            jc Error_file
            mov sprite_buffer,eax
            mov sprite_handle,edi

            lea edx,File_Bluster
            call Load_Internal_Gif_Handle
            jc Error_file
            mov video_buffer,eax
            mov video_handle,edi

            mov eax,On
            call allocate_background

            mov esi,gif_palette

            mov byte ptr [esi+0],0
            mov byte ptr [esi+1],0
            mov byte ptr [esi+2],0

            mov ecx,256*3
            mov eax,0*3
            call Create_Palette

            ret


;----------------------------------------------------------------------------
Load_Picture_Game:
;----------------------------------------------------------------------------

            call free_memory

            lea edx,File_Fonte
            call Load_Internal_Gif_Handle
            jc Error_file
            mov fonte_buffer,eax
            mov fonte_handle,edi

            lea edx,File_Monster
            call Load_Internal_Gif_Handle
            jc Error_file
            mov monster_buffer,eax
            mov monster_handle,edi

            lea edx,File_Sprite_
            call Load_Internal_Gif_Handle
            jc Error_file
            mov sprite_buffer,eax
            mov sprite_handle,edi

            call read_palette

            mov esi,gif_palette
            mov ecx,256*3
            mov eax,0*3
            call Create_Palette

            lea edx,File_Fond
            call Load_Internal_Gif_Handle
            jc Error_file
            mov video_buffer,eax
            mov video_handle,edi

            mov eax,Off
            call allocate_background

            ret


;----------------------------------------------------------------------------
next_fond:
;----------------------------------------------------------------------------

            ;cmp game_mode,EDIT
            ;jne @@ok1

            mov edi,offset palette
            mov al,0
            mov ecx,16*3
            rep stosb

            call wait_synchro
            mov edi,0
            mov eax,0
            mov esi,offset palette
            add esi,eax
            add esi,eax
            add esi,eax
            add esi,edi
            mov ecx,16*3
          ÿÿcall set_palette
@@ok1:

            mov eax,current_level
            dec eax
            call load_file_fond

            push video_buffer
            push sprite_buffer

            push video_buffer
            pop sprite_buffer

            push true_background_buffer
            pop video_buffer

            mov esi,bord_x
            mov edi,bord_y
            mov ebx,bord_x
            mov ecx,screen_y
            mov edx,limite_x-bord_x
            call draw_shape

            cmp game_mode,EDIT
            jne @@ok2

            call wait_synchro
            mov edi,0
            mov eax,0
            mov esi,offset palette
            add esi,eax
            add esi,eax
            add esi,eax
            add esi,edi
            mov ecx,16*3
          ÿÿcall set_palette

@@ok2:
            pop sprite_buffer
            pop video_buffer

            cmp game_mode,EDIT
            jne @@ok3

            mov esi,panel_editor_o
            mov edi,panel_editor_pos_y
            mov ebx,panel_editor_pos_x
            mov ecx,panel_editor_size_y
            mov edx,panel_editor_size_x
            call draw_shape

            mov edi,old_box_1
            call draw_box_1

            mov edi,old_box_2
            call draw_box_2
@@ok3:

            ret


;----------------------------------------------------------------------------
load_file_fond:
;----------------------------------------------------------------------------

            and eax,0111b
            add eax,'1'
            push eax

            mov edi,video_handle
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
            mov video_handle,Off

            pop eax

            lea edx,File_Fond
            mov B [edx+13],al

            call Load_Internal_Gif_Handle
            jc Error_file
            mov video_buffer,eax
            mov video_handle,edi

            mov esi,gif_palette

            mov byte ptr [esi+0+(00*3)],0
            mov byte ptr [esi+1+(00*3)],0
            mov byte ptr [esi+2+(00*3)],0

            mov byte ptr [esi+0+(15*3)],0
            mov byte ptr [esi+1+(15*3)],0
            mov byte ptr [esi+2+(15*3)],0

            mov ecx,16*3
            mov eax,0*3
            call Create_Palette

            call create_border

            mov esi,video_buffer
            mov edi,background_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            rep movsd

            mov esi,video_buffer
            mov edi,true_background_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            rep movsd

            ret


;----------------------------------------------------------------------------
Load_Picture_HiScore:
;----------------------------------------------------------------------------

            call free_memory

            lea edx,File_Fonte
            call Load_Internal_Gif_Handle
            jc Error_file
            mov fonte_buffer,eax
            mov fonte_handle,edi

            lea edx,File_Sprite_
            call Load_Internal_Gif_Handle
            jc Error_file
            mov sprite_buffer,eax
            mov sprite_handle,edi

            call read_palette

            mov esi,gif_palette
            mov ecx,256*3
            mov eax,0*3
            call Create_Palette

            lea edx,File_Fond
            call Load_Internal_Gif_Handle
            jc Error_file
            mov video_buffer,eax
            mov video_handle,edi

            mov eax,Off
            call allocate_background

            mov eax,3
            call get_random
            call load_file_fond

            ret


;----------------------------------------------------------------------------
allocate_background:
;----------------------------------------------------------------------------

            pushad

            mov edi,true_background_handle
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
            mov true_background_handle,Off

            mov edi,background_handle
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
            mov background_handle,Off

            mov ah,Allocate_Memory_Handle
            mov edx,screen_x*screen_y
            Int_EOS
            jc Error_file
            mov background_buffer,eax
            mov background_handle,edi

            mov ah,Allocate_Memory_Handle
            mov edx,screen_x*screen_y
            Int_EOS
            jc Error_file
            mov true_background_buffer,eax
            mov true_background_handle,edi

            popad

            ;cmp eax,On
            ;je @@end

            call create_border

@@end:
            mov esi,video_buffer
            mov edi,background_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            rep movsd

            mov esi,video_buffer
            mov edi,true_background_buffer
            mov ecx,(Screen_X/4)*Screen_Y
            rep movsd

            ret


;----------------------------------------------------------------------------
free_memory:
;----------------------------------------------------------------------------

            mov edi,fonte_handle
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
            mov fonte_handle,Off

            mov edi,sprite_handle
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
            mov sprite_handle,Off

            mov edi,monster_handle
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
            mov monster_handle,Off

            mov edi,true_background_handle
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
            mov true_background_handle,Off

            mov edi,background_handle
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
            mov background_handle,Off

            mov edi,video_handle
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
            mov video_handle,Off

            mov edi,palette_handle
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
            mov palette_handle,Off

            ret


;----------------------------------------------------------------------------
Load_External_Gif:
;----------------------------------------------------------------------------

            call Load_External_Gif_Handle
            jmp _Load_Gif

;----------------------------------------------------------------------------
Load_Gif:
;----------------------------------------------------------------------------

            call Load_Internal_Gif_Handle
_Load_Gif:
            jc Error_file
            push eax

            mov shade_org,0
            mov shade_len,256
            call Shade_Off

            mov esi,gif_palette

            mov byte ptr [esi+0],0
            mov byte ptr [esi+1],0
            mov byte ptr [esi+2],0

            mov ecx,256*3
            mov eax,0*3
            call Create_Palette

            pop esi
            mov ecx,(Screen_X/4)*Screen_Y
            xor edi,edi
            call Flip_Buffer

            mov edi,gif_handle
            mov ah,DeAllocate_Memory_Handle
            Int_EOS

            ret


;----------------------------------------------------------------------------
Read_Config_Sound:
;----------------------------------------------------------------------------

            mov ax,3d00h
            mov edx,O Name_CFG_Sound
            _int 21h
            jc @@Ok10
            mov ebx,eax
            mov ah,3fh
            mov edx,O Value_Sound_Card
            mov ecx,5
            _int 21h
            jc @@Ok9
            mov ah,3eh
            _int 21h

            if debug_mode
            mov ah,9
            mov edx,O Sound_Ok_Txt
            _int 21h
            endif

            mov ah,Manual_Setup
            mov al,B [Value_Sound_Card]
            mov bx,W [Value_Port]
            mov cl,B [Value_IRQ]
            mov dl,B [Value_DMA]
            mov ch,cl
            mov dh,dl
            Int_EOS
            jnc @@Ok8

            if debug_mode
            mov ah,9
            mov edx,O Sound_Bad_Txt
            _int 21h
            endif

@@Ok7:
            mov ebp,_key_map
            mov B [ebp+all],off
@@wait:
            cmp B [ebp+all],Off
            je @@wait
            ret
@@Ok8:
            mov al,B [Value_Sound_Card]
            mov SoundCard,al
            ret
@@Ok9:
            mov ah,3eh
            _int 21h
@@Ok10:
            mov ah,Detect_Sound_Card
            xor ebx,ebx
            mov ecx,1
            Int_EOS
            mov SoundCard,al
            ret


;----------------------------------------------------------------------------
load_music_intro:
;----------------------------------------------------------------------------

            call _load_music
            ret


;----------------------------------------------------------------------------
load_music:
;----------------------------------------------------------------------------

            call _load_music
            mov ah,Play_Module
            Int_EOS
            ret


;----------------------------------------------------------------------------
_load_music:
;----------------------------------------------------------------------------

            cmp SoundCard,No_Card
            je @@DoNotLoadModule

            call wait_synchro

            cmp current_module,edx
            je @@DoNotFreeModule
            call fade_music
            mov ah,Stop_Module
            Int_EOS
            mov ah,Clear_Module
            Int_EOS
@@DoNotFreeModule:
            mov current_module,edx

            mov ah,Load_Module
            mov al,4+1
            mov ebx,sb_freq
            mov ecx,2
            Int_EOS

            call wait_synchro

            loadsample option
            loadsample telepod
            loadsample new_life
            loadsample small
            loadsample large
            loadsample next_level
            loadsample death
            loadsample shoot
            loadsample option_off
            loadsample night
            loadsample restart
            loadsample speed_up
            loadsample del_monster
            loadsample incassable
            loadsample normale
            loadsample lost_ball
            loadsample explosion

            call wait_synchro

            mov al,user_volume
            mov [master_volume],al
            mov al,user_volume_sfx
            mov [master_volume_sfx],al

@@DoNotLoadModule:
            ret

            .data
SoundCard           db ?

Name_CFG_Sound      db 'SOUND.CFG',0

Value_Sound_Card    db 0
Value_Port          dw 0
Value_IRQ           db 0
Value_DMA           db 0

current_module      dd ?

;track 0

iff_option          dd 0h
iff_telepod         dd 0h
iff_new_life        dd 0h
iff_small           dd 0h
iff_large           dd 0h
iff_next_level      dd 0h
iff_death           label dword
iff_game_over       dd 0h
iff_shoot           dd 0h
iff_option_off      dd 0h
iff_night           dd 0h
iff_restart         dd 0h
iff_speed_up        dd 0h
iff_del_monster     dd 0h

;track 1
iff_incassable      label dword
iff_cursor          label dword
iff_multi           dd 0h
iff_normale         dd 0h
iff_lost_ball       dd 0h
iff_explosion       dd 0h
iff_lost_option     dd 0h

name_iff_option     db "resource\optionon.iff",0
name_iff_telepod    db "resource\telepod.iff",0
name_iff_new_life   db "resource\newlife.iff",0
name_iff_small      db "resource\small.iff",0
name_iff_large      db "resource\large.iff",0
name_iff_next_level db "resource\next.iff",0
name_iff_death      db "resource\death.iff",0
name_iff_shoot      db "resource\shoot.iff",0
name_iff_option_off db "resource\endopt.iff",0
name_iff_night      db "resource\night.iff",0
name_iff_restart    db "resource\restart.iff",0
name_iff_speed_up   db "resource\speedup.iff",0
name_iff_del_monster db "resource\monstoff.iff",0

;track 1
name_iff_incassable db "resource\wall.iff",0
name_iff_normale    db "resource\bounce.iff",0
name_iff_lost_ball  db "resource\pertebal.iff",0
name_iff_explosion  db "resource\boom.iff",0


            .code

;----------------------------------------------------------------------------
Read_Palette:
;----------------------------------------------------------------------------

            mov edx,O file_palette
            mov ax,3d00h
            _int 21h
            jc @@exit
            mov ebx,eax
            mov ah,3fh
            mov edx,gif_palette
            mov ecx,768
            _int 21h
            mov ah,3eh
            _int 21h
@@exit:
            ret


;----------------------------------------------------------------------------
Read_Config_User:
;----------------------------------------------------------------------------

            mov eax,'.usr'
            call Init_File
            mov ax,3d00h
            _int 21h
            jc @@exit
            mov ebx,eax
            mov ah,3fh
            mov edx,O user_cfg
            mov ecx,user_cfg_len
            _int 21h
            mov ah,3eh
            _int 21h
@@exit:
            ret

            .data
user_cfg            label word
User_Volume         db 32
User_Volume_Sfx     db 64
user_cfg_len        = $-user_cfg

            .code


;----------------------------------------------------------------------------
Write_Config_User:
;----------------------------------------------------------------------------

            mov eax,'.usr'
            call Init_File
            mov ah,Write_External_File
            mov esi,O user_cfg
            mov ecx,user_cfg_len
            Int_EOS
            ret


;----------------------------------------------------------------------------
Read_File_Test:
;----------------------------------------------------------------------------

            mov test_1.sprite_status,Off

            if debug_mode
            mov eax,'.txt'
            call Init_File
            mov ah,Load_External_File_Handle
            Int_EOS
            jnc @@ok
            endif

            ret

            if debug_mode
@@ok:
            mov test_1.sprite_status,On
            mov test_1.sprite_sens_x,Off
            mov test_1.sprite_sens_y,Off
            mov test_1.sprite_angle,Off
            mov test_1.sprite_new_xy,Off
            mov test_1.sprite_old_xy,Off
            mov test_1.sprite_new_xy_dx,Off
            mov test_1.sprite_old_xy_dx,Off
            mov test_1.sprite_min_x,0
            mov test_1.sprite_min_y,0
            mov test_1.sprite_max_x,screen_x
            mov test_1.sprite_max_y,screen_y

            call Get_Expression
            call Get_String
            mov test_1.sprite_pos_x,edx
            call Get_String
            mov test_1.sprite_pos_y,edx

            call Get_Expression
            call Get_String
            push edx
            call Get_String
            mov eax,edx
            imul eax,screen_x
            pop edx
            add edx,eax
            mov test_1.sprite_adrs,edx
            mov test_1.sprite_current_adrs,edx

            call Get_Expression
            call Get_String
            mov test_1.sprite_size_x,edx
            mov test_1.sprite_old_size_x,edx
            call Get_String
            mov test_1.sprite_size_y,edx
            mov test_1.sprite_old_size_y,edx

            call Get_Expression
            call Get_String
            mov test_1.sprite_next_shape,edx

            call Get_Expression
            call Get_String
            mov test_1.sprite_nbs_shape,edx
            mov test_1.sprite_current_shape,Off

            call Get_Expression
            call Get_String
            mov test_1.sprite_shape_speed,edx
            mov test_1.sprite_current_speed,Off

            cmp test_1.sprite_nbs_shape,Off
            jne @@cont
            mov test_1.sprite_status,Off
            mov test_1.sprite_mode,Last
@@cont:
            ret
            endif


;----------------------------------------------------------------------------
Get_Expression:
;----------------------------------------------------------------------------

@@search:
            inc esi
            cmp B [esi-1],'('
            jne @@search
            ret


;----------------------------------------------------------------------------
Read_File_Config:
;----------------------------------------------------------------------------

            mov eax,'.cfg'
            call Init_File
            mov ah,Load_External_File_Handle
            Int_EOS
            jnc @@ok
            ret
@@ok:
            call Get_Expression
            call Get_String
            mov debug_game,edx

            call Get_Expression
            call Get_String
            mov bonus_extra_life,edx

            call Get_Expression
            call Get_String
            mov mouse_speed,edx

            call Get_Expression
            call Get_String
            dec edx
            mov nbs_ball_start,edx

            call Get_Expression
            call Get_String
            mov start_level,edx

            call Get_Expression
            call Get_String
            mov speed_delai,edx

            lea edi,option_3_ball
@@loop:
            cmp [edi.option_status],last
            je @@end
            call Get_Expression
            call Get_String
            mov [edi.option_easy],edx
            call Get_String
            mov [edi.option_medium],edx
            call Get_String
            mov [edi.option_hard],edx
            add edi,size struc_options
            jmp @@loop
@@end:
            call Get_Expression
            call Get_String
            mov delai_between_option_easy,edx
            call Get_String
            mov delai_between_option_medium,edx
            call Get_String
            mov delai_between_option_hard,edx

            call Get_Expression
            call Get_String
            mov monster_delai_easy,edx
            call Get_String
            mov monster_delai_medium,edx
            call Get_String
            mov monster_delai_hard,edx

            call Get_Expression
            call Get_String
            mov speed_start_easy,edx
            call Get_String
            mov speed_start_medium,edx
            call Get_String
            mov speed_start_hard,edx

            call Get_Expression
            call Get_String
            mov change_speed_level_easy,edx
            call Get_String
            mov change_speed_level_medium,edx
            call Get_String
            mov change_speed_level_hard,edx

            call read_text_play
            call read_text_options
            call read_text_menu
            call read_text_final
            call read_text_dual

            ret


;----------------------------------------------------------------------------
read_text_play:
;----------------------------------------------------------------------------

            lea edi,option_text_off
            mov ecx,option_text_number
@@loop:
            push ecx

            call Get_Expression
            inc esi

            mov ecx,12
            rep movsb

            inc edi

            pop ecx
            loop @@loop
            ret


;----------------------------------------------------------------------------
read_text_options:
;----------------------------------------------------------------------------

            lea edi,option_3_ball.option_text
            mov ecx,options_number
@@loop:
            push ecx
            call Get_Expression
            inc esi

            push edi
            mov ecx,12
            rep movsb
            pop edi

            add edi,size struc_options
            pop ecx
            loop @@loop
            ret


;----------------------------------------------------------------------------
read_text_menu:
;----------------------------------------------------------------------------

            lea edi,menu_begin.menu_text
            mov ecx,menu_text_number
@@loop:
            push ecx
            push edi

            call Get_Expression
            inc esi
            mov ecx,16
            rep movsb
            inc edi

            add esi,3

            mov ecx,16
            rep movsb

            pop edi
            add edi,size struc_menus
            pop ecx
            loop @@loop
            ret


;----------------------------------------------------------------------------
read_text_final:
;----------------------------------------------------------------------------

            lea edi,final_text_2
            mov ecx,final_text_number
@@loop:
            push ecx
            add edi,4
            call Get_Expression
            inc esi
            mov ecx,final_len
            rep movsb
            inc edi
            pop ecx
            loop @@loop
            ret


;----------------------------------------------------------------------------
read_text_dual:
;----------------------------------------------------------------------------

            lea edi,final_dual_2
            mov ecx,final_text_number
@@loop:
            push ecx
            add edi,4
            call Get_Expression
            inc esi
            mov ecx,final_len
            rep movsb
            inc edi
            pop ecx
            loop @@loop
            ret


            .data
speed_start_easy            dd 2
speed_start_medium          dd 3
speed_start_hard            dd 4
monster_delai_easy          dd 600
monster_delai_medium        dd 500
monster_delai_hard          dd 300
speed_delai                 dd 1500
change_speed_level_easy     dd 3
change_speed_level_medium   dd 4
change_speed_level_hard     dd 4
nbs_ball_start              dd 2
start_level                 dd 1
delai_between_option_easy   dd 60
delai_between_option_medium dd 60
delai_between_option_hard   dd 60
mouse_speed                 dd 0
bonus_extra_life            dd 10000
debug_game                  dd 0

final_text_number = 13

final_text   db     "                           ",13
final_len   = $-final_text-1
final_text_2 db "    +++++++++++++++++++++++++++",13
             db "    +                         +",13
             db "    +                         +",13
             db "    +     congratulation !    +",13
             db "    +                         +",13
             db "    +                         +",13
             db "    +     bla bla bla...      +",13
             db "    +                         +",13
             db "    +                         +",13
             db "    +                         +",13
             db "    +                         +",13
             db "    +                         +",13
             db "    +++++++++++++++++++++++++++",00

final_dual   db     "                           ",13
final_dual_2 db "    +++++++++++++++++++++++++++",13
             db "    +                         +",13
             db "    +                         +",13
             db "    +       winner is...      +",13
             db "    +                         +",13
             db "    +                         +",13
             db "    +        player "
winner       db"one       +",13
             db "    +                         +",13
             db "    +                         +",13
             db "    +                         +",13
             db "    +                         +",13
             db "    +                         +",13
             db "    +++++++++++++++++++++++++++",00

            .code


;----------------------------------------------------------------------------
Read_Level:
;----------------------------------------------------------------------------

            call wait_keyboard_release

            cmp level_handle,Off
            je @@cont
            mov edi,level_handle
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
@@cont:
            mov eax,'.lv?'
            mov al,world
            call Init_File
            mov ah,Load_External_File_Handle
            Int_EOS
            jc Error_File
            mov [level_adrs],esi
            mov [level_size],ecx
            mov [level_handle],edi

            cmp ecx,31200
            jne Error_File
            ret

            .data
level_adrs   dd 0
level_size   dd 0
level_handle dd 0
            .code


;----------------------------------------------------------------------------
Write_Level:
;----------------------------------------------------------------------------

            call wait_keyboard_release

            mov eax,'.lv?'
            mov al,world
            call Init_File
            mov esi,level_adrs
            mov ecx,level_size
            mov ah,Write_External_File
            Int_EOS
            ret


;----------------------------------------------------------------------------
Init_File:
;----------------------------------------------------------------------------

            xor esi,esi
            rept 4
            rol esi,8
            push eax
            and eax,11111111b
            or esi,eax
            pop eax
            ror eax,8
            endm
            push esi

            push ds
ifndef WIN32
            xor esi,esi
            mov ds,[Environment_Sel]
else
            mov esi,[Environment_Addr]
endif

            mov ecx,0800h
@@loop:
            cmp word ptr [esi],0
            jz @@foundname
            inc esi
            loop @@loop
            pop ds
            jmp Error_File

@@foundname:
            add esi,4

            lea edi,File_Tmp
            mov ecx,256
@@copy:
            lodsb
            or al,al
            jz @@end
            stosb
            loop @@copy
            pop ds
            jmp Error_File
@@end:
            pop ds
            pop D [edi-4]

            lea edx,File_Tmp
            ret

            .data
File_Tmp    db 256 dup (0)
            .code