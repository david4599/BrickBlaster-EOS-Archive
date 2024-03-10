;----------------------------------------------------------------------------
detect_mouse:
;----------------------------------------------------------------------------

            mov ax,21h
            _int 33h
            cmp ax,21h
            ;xor ax,ax
            ;Int 33h
            ;or ax,ax
            jne @@Driver_detected
            if debug_mode
            lea edx,Mouse_Bad_Txt
            endif
            stc
            ret
@@Driver_detected:
            if debug_mode
            Affiche Mouse_Ok_Txt
            endif
            clc
            ret


;----------------------------------------------------------------------------
Refresh_Keyboard:
;----------------------------------------------------------------------------

            call demo_move_x_player_2
            jc @@limite

            mov ebp,_key_map
            cmp player_2.player_current_option,option_reverse_o
            je @@inverse
            cmp B [ebp+left],On
            je @@keyboard_left
            cmp B [ebp+right],On
            je @@keyboard_right
            ;mov speed_counter,1
            ret
@@inverse:
            cmp B [ebp+right],On
            je @@keyboard_left
            cmp B [ebp+left],On
            je @@keyboard_right
            ;mov speed_counter,1
            ret

@@keyboard_left:
            mov eax,speed_counter
            sub cursor_2.sprite_pos_x,eax
@@limite:
            ;inc speed_counter

            mov eax,cursor_2.sprite_pos_x
            cmp eax,cursor_2.sprite_min_x
            jl @@inf
            cmp eax,cursor_2.sprite_max_x
            jg @@sup
            ret
@@inf:
            mov eax,cursor_2.sprite_min_x
            mov cursor_2.sprite_pos_x,eax
            ret
@@sup:
            mov eax,cursor_2.sprite_max_x
            mov cursor_2.sprite_pos_x,eax
            ret

@@keyboard_right:
            mov eax,speed_counter
            add cursor_2.sprite_pos_x,eax
            jmp @@limite

            .data
paddle_flag   dd Off
speed_counter dd 6
            .code


;----------------------------------------------------------------------------
Refresh_Joystick:
;----------------------------------------------------------------------------

ifdef WIN32
            call demo_move_x_player_2
            jc @@limite

            cmp [Joy_Addr],0
            je @@Exit
            call Update_Joystick
            mov ebx,[Joy_Addr]
            mov eax,[ebx.DIJOYSTATE.jlX]

                                    cmp paddle_flag,On
                                    jne @@no_pad
                                    cmp eax,800
                                    jg @@paddle
                                    cmp eax,-800
                                    jl @@paddle_inverse
                                    cmp eax,0
                                    jmp @@limite
                                    @@no_pad:

                    push eax
                    add eax,1000
                    imul eax,limite_x-bord_x
                    cdq
                    mov ecx,2000
                    idiv ecx
                    add eax,bord_x
                    mov ecx,cursor_2.sprite_size_x
                    shr ecx,1
                    sub eax,ecx
                    mov cursor_2.sprite_pos_x,eax
                    pop eax

            cmp player_2.player_current_option,option_reverse_o
            jne @@limite
@@inverse:
                    mov eax,limite_x
                    sub eax,cursor_2.sprite_pos_x
                    mov cursor_2.sprite_pos_x,eax
                    jmp @@limite

@@joystick_left:
                                    mov eax,speed_counter
                                    sub cursor_2.sprite_pos_x,eax
@@limite:
            ;inc speed_counter

            mov eax,cursor_2.sprite_pos_x
            cmp eax,cursor_2.sprite_min_x
            jl @@inf
            cmp eax,cursor_2.sprite_max_x
            jg @@sup
            ret
@@inf:
            mov eax,cursor_2.sprite_min_x
            mov cursor_2.sprite_pos_x,eax
            ret
@@sup:
            mov eax,cursor_2.sprite_max_x
            mov cursor_2.sprite_pos_x,eax
            ret

@@joystick_right:
                                    mov eax,speed_counter
                                    add cursor_2.sprite_pos_x,eax
                                    jmp @@limite
@@Exit:
endif
            ret
@@paddle:
                                    cmp player_2.player_current_option,option_reverse_o
                                    jne @@joystick_right
                                    je @@joystick_left

@@paddle_inverse:
                                    cmp player_2.player_current_option,option_reverse_o
                                    je @@joystick_right
                                    jne @@joystick_left


;----------------------------------------------------------------------------
Refresh_Mouse:
;----------------------------------------------------------------------------

                        cmp nbs_player,2
                        jne @@cont
                        cmp game_mode,EDIT
                        je @@cont
                        cmp game_mode,MENU
                        je @@cont
                        cmp control_2,COMPUTER
                        je @@ok
                        cmp control_2,KEYBOARD
                        jne @@cont1
            @@ok:
                        call refresh_keyboard

                        mov eax,cursor_2.sprite_pos_x
                        add eax,vaisseau_decal_x_l
                        mov cursor_2_tir_left.sprite_pos_x,eax
                        mov eax,cursor_2.sprite_pos_y
                        add eax,vaisseau_decal_y_l
                        mov cursor_2_tir_left.sprite_pos_y,eax

                        mov eax,cursor_2.sprite_pos_x
                        add eax,vaisseau_decal_x_r
                        mov cursor_2_tir_right.sprite_pos_x,eax
                        mov eax,cursor_2.sprite_pos_y
                        add eax,vaisseau_decal_y_r
                        mov cursor_2_tir_right.sprite_pos_y,eax

                        mov eax,cursor_2.sprite_pos_x
                        add eax,vaisseau_decal_x_b
                        mov cursor_2_tir_big.sprite_pos_x,eax
                        mov eax,cursor_2.sprite_pos_y
                        add eax,vaisseau_decal_y_b
                        mov cursor_2_tir_big.sprite_pos_y,eax
            @@cont1:
                        cmp control_2,JOYSTICK
                        jne @@cont
                        call refresh_joystick

                        mov eax,cursor_2.sprite_pos_x
                        add eax,vaisseau_decal_x_l
                        mov cursor_2_tir_left.sprite_pos_x,eax
                        mov eax,cursor_2.sprite_pos_y
                        add eax,vaisseau_decal_y_l
                        mov cursor_2_tir_left.sprite_pos_y,eax

                        mov eax,cursor_2.sprite_pos_x
                        add eax,vaisseau_decal_x_r
                        mov cursor_2_tir_right.sprite_pos_x,eax
                        mov eax,cursor_2.sprite_pos_y
                        add eax,vaisseau_decal_y_r
                        mov cursor_2_tir_right.sprite_pos_y,eax

                        mov eax,cursor_2.sprite_pos_x
                        add eax,vaisseau_decal_x_b
                        mov cursor_2_tir_big.sprite_pos_x,eax
                        mov eax,cursor_2.sprite_pos_y
                        add eax,vaisseau_decal_y_b
                        mov cursor_2_tir_big.sprite_pos_y,eax

@@cont:
            mov ax,0bh
            _int 33h

            call control_mouse_speed

            cmp player_1.player_current_option,option_reverse_o
            jne @@ok2
            neg ecx
@@ok2:
            call move_x
            call move_y

            mov eax,cursor_1.sprite_pos_x
            add eax,vaisseau_decal_x_l
            mov cursor_1_tir_left.sprite_pos_x,eax
            mov eax,cursor_1.sprite_pos_y
            add eax,vaisseau_decal_y_l
            mov cursor_1_tir_left.sprite_pos_y,eax

            mov eax,cursor_1.sprite_pos_x
            add eax,vaisseau_decal_x_r
            mov cursor_1_tir_right.sprite_pos_x,eax
            mov eax,cursor_1.sprite_pos_y
            add eax,vaisseau_decal_y_r
            mov cursor_1_tir_right.sprite_pos_y,eax

            mov eax,cursor_1.sprite_pos_x
            add eax,vaisseau_decal_x_b
            mov cursor_1_tir_big.sprite_pos_x,eax
            mov eax,cursor_1.sprite_pos_y
            add eax,vaisseau_decal_y_b
            mov cursor_1_tir_big.sprite_pos_y,eax

            ret

move_x:
            or cx,cx
            jnz @@cont
            cmp cx,_cx
            je @@cont
            mov cx,_cx
            mov _cx,0
            jmp @@cont2
@@cont:
            mov _cx,cx
@@cont2:
ifndef WIN32
            sar cx,2
else
            sar cx,1
endif

            adc W cursor_1.sprite_pos_x,cx
            js @@inf

            call demo_move_x_player_1

            mov eax,cursor_1.sprite_pos_x
            cmp eax,cursor_1.sprite_min_x
            jl @@inf
            cmp eax,cursor_1.sprite_max_x
            jg @@sup
            ret
@@inf:
            mov eax,cursor_1.sprite_min_x
            mov cursor_1.sprite_pos_x,eax
            ret
@@sup:
            mov eax,cursor_1.sprite_max_x
            mov cursor_1.sprite_pos_x,eax
            ret

move_y:
            or dx,dx
            jne @@cont
            cmp dx,_dx
            je @@cont
            mov dx,_dx
            mov _dx,0
            jmp @@cont2
@@cont:
            mov _dx,dx
@@cont2:
ifndef WIN32
            sar dx,2
else
            sar dx,1
endif
            adc W cursor_1.sprite_pos_y,dx
            js @@inf

            mov eax,cursor_1.sprite_pos_y
            cmp eax,cursor_1.sprite_min_y
            jl @@inf
            cmp eax,cursor_1.sprite_max_y
            jg @@sup
            ret
@@inf:
            mov eax,cursor_1.sprite_min_y
            mov cursor_1.sprite_pos_y,eax
            ret
@@sup:
            mov eax,cursor_1.sprite_max_y
            mov cursor_1.sprite_pos_y,eax
            ret

            .data
_cx         dw 0
_dx         dw 0
            .code


;----------------------------------------------------------------------------
control_mouse_speed:
;----------------------------------------------------------------------------

            mov eax,ecx
            mov ecx,mouse_speed
            neg ecx
            cmp ecx,0
            jl @@moins
            jg @@plus
            mov ecx,eax
            ret
@@plus:
            sar eax,cl
            sar edx,cl
            mov ecx,eax
            ret

@@moins:
            neg ecx
            sal eax,cl
            sal edx,cl
            mov ecx,eax
            ret


;----------------------------------------------------------------------------
wait_click:
;----------------------------------------------------------------------------

@@again:
            push ecx
            call wait_synchro
            call read_click
            pop ecx
            jnz @@end
            mov ebp,_key_map

            cmp B [ebp+all],Off
            jne @@end
            loop @@again
            mov B [ebp+all],Off
            clc
            ret
@@end:
            mov B [ebp+all],Off
            stc
            ret


;----------------------------------------------------------------------------
dec_volume:
;----------------------------------------------------------------------------

            mov bl,[Master_Volume]
            cmp bl,0
            jle @@cont
            dec [Master_Volume]
@@cont:
            mov al,master_volume
            mov user_volume,al
            ret


;----------------------------------------------------------------------------
inc_volume:
;----------------------------------------------------------------------------

            mov bl,[Master_Volume]
            cmp bl,64
            jge @@cont
            inc [Master_Volume]
@@cont:
            mov al,master_volume
            mov user_volume,al
            ret


;----------------------------------------------------------------------------
wait_keyboard_release:
;----------------------------------------------------------------------------

            mov ebp,_key_map
            cmp B [ebp+all],Off
            je @@exit
            movzx eax,B [ebp+all]
            mov B [ebp+all],Off
@@again:
            call wait_synchro
            cmp B [ebp+eax],Off
            jne @@again
@@exit:
            ret


;----------------------------------------------------------------------------
read_click:
;----------------------------------------------------------------------------
ifdef WIN32
            cmp [Joy_Addr],0
            je @@Exit
            mov edi,[Joy_Addr]
            xor ebx,ebx
@@loop:
            cmp [edi+ebx.DIJOYSTATE.jrgbButtons],0
            jne @@on
            inc ebx
            cmp ebx,16
            jne @@Loop
@@Exit:
endif
            mov ebp,_key_map

            cmp B [ebp+ctrl],On
            je @@on

            xor ebx,ebx
            mov ax,3
            _int 33h
            or bl,bl
            ret
@@on:
            mov bl,011b
            or bl,bl
            ret


;----------------------------------------------------------------------------
read_click_player_2:
;----------------------------------------------------------------------------

            cmp control_2,JOYSTICK
            je @@cont

            mov ebp,_key_map
            cmp B [ebp+ctrl],On
            je @@on
            mov bl,000b
            or bl,bl
            ret
@@on:
            mov bl,011b
            or bl,bl
            ret

@@cont:
ifdef WIN32
            cmp [Joy_Addr],0
            je @@Exit
            mov edi,[Joy_Addr]
            xor ebx,ebx
@@loop:
            cmp [edi+ebx.DIJOYSTATE.jrgbButtons],0
            jne @@on
            inc ebx
            cmp ebx,16
            jne @@Loop
            mov bl,000b
            or bl,bl
@@Exit:
endif
            ret


;----------------------------------------------------------------------------
read_click_player_1:
;----------------------------------------------------------------------------

            xor ebx,ebx
            mov ax,3
            _int 33h
            or bl,bl
            ret