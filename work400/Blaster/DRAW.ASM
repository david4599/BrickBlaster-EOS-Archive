;----------------------------------------------------------------------------
init_video_card:
;----------------------------------------------------------------------------

            if dos_mode
            call Shade_Text_Off
            endif
            call Init_Vesa_Bank
            mov [screen],bx
            mov ax,Mode640x480x256
            call Init_Vesa
            jc Error_Vesa
            cmp [screen],0
            jc Error_Vesa
            ret

            .data
screen                      dw ?
            .code

ifndef WIN32
;----------------------------------------------------------------------------
create_timer:
;----------------------------------------------------------------------------

            mov ah,Get_Irq
            mov bl,0                        ; BL = IRQ number.
            Int_EOS                         ; Call the service.
            mov [old_Adr_Int_08],edx
            mov [old_Sel_Int_08],cx
            cmp edx,offset Interrupt_Timer
            je @@end
            mov ah,Set_Irq
            mov bl,0                        ; BL = IRQ number
            mov edx,Offset Interrupt_Timer  ; EDX = offset of int vector
            mov cx,cs                       ; CX = selector value
            Int_EOS                         ; Call the service.
@@end:
            mov timer_flag,On
            ret


;----------------------------------------------------------------------------
dispose_timer:
;----------------------------------------------------------------------------

            cmp timer_flag,On
            jne @@end
            mov ah,Get_Irq
            mov bl,0                        ; BL = IRQ number.
            Int_EOS                         ; Call the service.
            cmp edx,O Interrupt_Timer
            jne @@end
            mov edx,[old_Adr_Int_08]        ; EDX = offset of int vector
            mov cx,[old_Sel_Int_08]         ; CX = selector value
            mov ah,Set_Irq
            mov bl,0                        ; BL = IRQ number.
            Int_EOS                         ; Call the service.
@@end:
            mov timer_flag,Off
            ret

Align
;----------------------------------------------------------------------------
Interrupt_Timer:
;----------------------------------------------------------------------------

            push eax
            push ds
            mov ds,cs:[Data32_Sel]
            inc timer_counter
            pop ds
            pop eax
                    db 0eah
old_Adr_Int_08      dd 0
old_Sel_Int_08      dw 0            ; Ancienne Adresse De l'interruption 08h

timer_flag          db Off
timer_counter       dd 0

endif


;----------------------------------------------------------------------------
wait_synchro:
;----------------------------------------------------------------------------

            pushad

            if dos_mode
            mov eax,ball_1.sprite_sens_x
            or eax,eax
            jns @@ok
            neg eax
            @@ok:
            Send eax,10,0

            mov eax,ball_1.sprite_sens_y
            or eax,eax
            jns @@ok2
            neg eax
            @@ok2:
            Send eax,10,1

            Send ball_1.sprite_angle,10,2

            color 0,0,0,0
            endif

            call calc_random
ifndef WIN32
            push ds
            push 40h
            pop ds
            mov edx,ds:[63h]
            mov ds,cs:[Data32_Sel]
            add dl,6
@@Ok3:
            cmp cs:timer_counter,10
            ja @@ok5
            in al,dx
            test al,8
            je @@Ok3
@@Ok4:
            cmp cs:timer_counter,10
            ja @@ok5
            in al,dx
            test al,8
            jne @@Ok4
@@ok5:
            pop ds

            ;;mov ebp,_key_map
            ;;cmp B [ebp+Num_0],On
            ;;jne @@noborder
            ;cmp game_mode,PLAYING
            ;jne @@noborder
            ;color 0,63,0,0
            ;endif
@@noborder:
@@ok6:
            cmp cs:timer_counter,8
            jb @@ok6

            mov timer_counter,0
else
            ;vbl=on
            ;color 0,0,0,0
            mov ah,Wait_Vbl
            Int_EOS
            ;color 0,63,63,63
endif

            inc delai_random_option
            inc delai_auto_shoot_player_1
            inc delai_auto_shoot_player_2

            popad
            ret

delai_random_option dd ?
delai_auto_shoot_player_1    dd ?
delai_auto_shoot_player_2    dd ?


;----------------------------------------------------------------------------
;           mov eax,org
;       	mov ecx,len
;         	mov esi,palette
Set_Palette:
;----------------------------------------------------------------------------
ifndef WIN32

            push edx
            push eax
           ÿmov dx,03C8h
           ÿout dx,al
           ÿinc dx
            cli
@@again:
          ÿÿoutsb
          ÿÿloop @@again
            pop eax
            pop edx
            sti
else
            pushad
            push esi
            push ecx
            push eax
            call _Set_Palette
            add esp,4*3
            popad
endif
            ret


;----------------------------------------------------------------------------
;           mov ecx,len*3
;           mov eax,org*3
;           mov esi,picture
Create_Palette:
;----------------------------------------------------------------------------

            add esi,eax
            lea edi,Palette
            add edi,eax
            rep movsb
            ret

            .data
Palette     label word
            db 256*32 dup (0,0,0)
            .code


;----------------------------------------------------------------------------
init_shade:
;----------------------------------------------------------------------------

            pushad

            lea esi,palette
            mov edi,esi
            add edi,256*3
           ÿmov ecx,256*3*31
@@again:
            lodsb
            cmp al,0
            je @@cont
            dec al
            cmp al,0
            je @@cont
            dec al
@@cont:
            stosb
           ÿloop @@again

            mov eax,shade_len
            add shade_len,eax
            add shade_len,eax

            popad
           ÿret


;----------------------------------------------------------------------------
Shade_Text_Off:
;----------------------------------------------------------------------------

            call wait_synchro

            mov dx,03C7h
            mov al,0
            out dx,al
            inc dx
            inc dx

            mov edi,offset Palette

            mov ecx,256
@@loop:
            in al,dx
            stosb
            in al,dx
            stosb
            in al,dx
            stosb
            loop @@loop

            mov shade_org,0
            mov shade_len,256

;----------------------------------------------------------------------------
Shade_Off:
;----------------------------------------------------------------------------

            call init_shade

           ÿmov edi,0

            cmp option_night_flag,On
            jne @@lp2
            mov edi,256*3*16
            mov option_night_flag,Off
@@lp2:
            call wait_synchro

          ÿÿmov ecx,Shade_len
            mov eax,Shade_org
          ÿÿmov esi,offset palette
            add esi,eax
	add esi,eax
	add esi,eax
	add esi,edi
          ÿÿcall set_palette

            cmp Shade_Volume,On
            jne @@cont
            mov bl,[Master_Volume]
            sub bl,Shade_volume_val
            cmp bl,0
            jl @@cont
            push edi
            mov [Master_Volume],bl
            mov [Master_Volume_Sfx],bl
            pop edi
@@cont:
            add edi,256*3

            cmp edi,Shade_Len_32
          ÿÿjne @@lp2

@@end:
           ÿret


;----------------------------------------------------------------------------
fade_music:
;----------------------------------------------------------------------------

            call wait_synchro
            cmp [master_volume],0
            jl @@exit
            dec [master_volume]
            jmp fade_music
@@exit:
            ret


;----------------------------------------------------------------------------
Shade_On:
;----------------------------------------------------------------------------

            call Init_Shade

           ÿmov edi,Shade_Len_32
@@lp3:
           ÿsub edi,256*3

            call wait_synchro

            mov ecx,Shade_len
            mov eax,Shade_org
          ÿÿmov esi,offset palette
            add esi,eax
	add esi,eax
	add esi,eax
	add esi,edi
            call set_palette

            cmp edi,0
          ÿÿjne @@lp3

@@end:
            ret

            .data
Shade_Volume_val    db 2
Shade_Volume        db Off
Shade_Len_32        dd 256*3*32
Shade_org           dd 0
Shade_len           dd 256
            .code


;----------------------------------------------------------------------------
Refresh_Sprites:
;----------------------------------------------------------------------------

           lea edx,Begin_Sprites
@@loop:
           cmp [edx.sprite_mode],last
           je @@end
           cmp [edx.sprite_status],Off
           je @@next
@@cont:
           cmp [edx.sprite_nbs_shape],1
           jbe @@next

           cmp [edx.sprite_delete],Off
           je @@no_del
           dec [edx.sprite_delete]
           cmp [edx.sprite_delete],Off
           je @@no_del
           mov [edx.sprite_status],Off
           jmp @@next
@@no_del:
           dec [edx.sprite_current_speed]
           cmp [edx.sprite_current_speed],0
           jns @@next
           mov eax,[edx.sprite_shape_speed]
           mov [edx.sprite_current_speed],eax

           cmp [edx.sprite_to_delete],Off
           je @@ok
           dec [edx.sprite_to_delete]
           cmp [edx.sprite_to_delete],On
           jne @@ok
           mov [edx.sprite_delete],2
           mov [edx.sprite_status],Off
@@ok:

           cmp [edx.sprite_current_shape],1
           jbe @@reset
@@inc:
           mov eax,[edx.sprite_size_x]
           add eax,[edx.sprite_next_shape]
           add [edx.sprite_current_adrs],eax
           dec [edx.sprite_current_shape]
           jmp @@next
@@reset:
           mov eax,[edx.sprite_adrs]
           mov [edx.sprite_current_adrs],eax
           mov eax,[edx.sprite_nbs_shape]
           mov [edx.sprite_current_shape],eax
           jmp @@next
@@next:
           add edx,size struc_sprites
           jmp @@loop
@@end:
           ret


;----------------------------------------------------------------------------
Draw_sprites:
;----------------------------------------------------------------------------

            lea edx,Begin_Sprites
@@loop:
            cmp [edx.sprite_mode],last
            je @@end
            cmp [edx.sprite_status],Off
            je @@next

                    call test_limite

            push edx
            mov eax,[edx.sprite_pos_x]
            mov ebx,[edx.sprite_pos_y]
            mov ecx,[edx.sprite_size_x]
            mov edx,[edx.sprite_size_y]
                    ;call clipping_box
            mov c1,eax
            mov l1,ebx
            mov c2,ecx
            mov l2,edx
            pop edx

                    ;jc @@end
                    ;cmp clip_error2,On
                    ;je @@end
            mov eax,[edx.sprite_current_adrs]
                    ;sub eax,esi
            mov buffer,eax
                    ;push edx
                    ;mov eax,screen_x
                    ;xor edx,edx
                    ;imul edi
                    ;add buffer,eax
                    ;pop edx

            mov edi,l1
            mov esi,c1

            call trunk_data

            pushad
            mov eax,direct_x_pitch
            imul edi,eax
            add edi,esi                   ; edi=(pos_y*screen_x)+pos_x
            mov [edx.sprite_new_xy_dx],edi
            popad


            lea edi,[edi+edi*4]
            shl edi,7
            add edi,esi                   ; edi=(pos_y*screen_x)+pos_x
            mov [edx.sprite_new_xy],edi

            add edi,Video_Buffer

            mov esi,buffer
            add esi,[edx.sprite_buffer_adrs]

            mov ecx,l2
            mov ebx,c2
@@ligne:
            mov ebp,ebx
@@colonne:
            mov al,[esi]
            inc esi
            or al,al
            jz @@cont
            mov [edi],al
@@cont:
            inc edi
            dec ebp
            jnz @@colonne

            add edi,screen_x
            sub edi,ebx
            add esi,[edx.sprite_screen_x]
            sub esi,ebx

            dec ecx
            jnz @@ligne

@@next:
            add edx,size struc_sprites
            jmp @@loop
@@end:
            ret

            .data
buffer      dd ?
c1          dd ?
l1          dd ?
c2          dd ?
l2          dd ?
            .code


;----------------------------------------------------------------------------
erase_sprites:
;----------------------------------------------------------------------------

            lea edx,Begin_Sprites
@@loop:
            cmp [edx.sprite_mode],last
            je @@end
            cmp [edx.sprite_delete],Off
            jne @@cont
            cmp [edx.sprite_status],Off
            je @@next
@@cont:
            mov edi,[edx.sprite_old_xy]
            call Erase_Ligne
@@next:
            add edx,size struc_sprites
            jmp @@loop

@@end:
            ret


;----------------------------------------------------------------------------
;           mov edi,[edx.pos_xy]
align
Erase_Ligne:
;----------------------------------------------------------------------------

            mov esi,edi

            add edi,Video_Buffer
            add esi,Background_Buffer

            mov ebp,[edx.sprite_old_size_y]
            mov ebx,[edx.sprite_old_size_x]
            mov eax,screen_x
            add ebx,3
            and ebx,11111111111111111111111111111100b
            sub eax,ebx
            shr ebx,2
            align 4
@@ligne:
            mov ecx,ebx
            rep movsd

            add edi,eax
            add esi,eax

            dec ebp
            jnz @@ligne

            ret


;----------------------------------------------------------------------------
test_limite:
;----------------------------------------------------------------------------

            call test_limite_x
            call test_limite_y
            ret


;----------------------------------------------------------------------------
test_limite_x:
;----------------------------------------------------------------------------

            mov eax,[edx.sprite_pos_x]
            cmp eax,[edx.sprite_min_x]
            jl @@inf
            cmp eax,[edx.sprite_max_x]
            jg @@sup
            ret
@@inf:
            mov eax,[edx.sprite_min_x]
            mov [edx.sprite_pos_x],eax
            ret
@@sup:
            mov eax,[edx.sprite_max_x]
            mov [edx.sprite_pos_x],eax
            ret


;----------------------------------------------------------------------------
test_limite_y:
;----------------------------------------------------------------------------

            mov eax,[edx.sprite_pos_y]
            cmp eax,[edx.sprite_min_y]
            jl @@inf
            cmp eax,[edx.sprite_max_y]
            jg @@sup
            ret
@@inf:
            mov eax,[edx.sprite_min_y]
            mov [edx.sprite_pos_y],eax
            ret
@@sup:
            mov eax,[edx.sprite_max_y]
            mov [edx.sprite_pos_y],eax
            ret


;----------------------------------------------------------------------------
Flip_Sprites:
;----------------------------------------------------------------------------

            push es
            mov es,[screen]

            lea edx,Begin_Sprites
@@loop:
            cmp [edx.sprite_mode],last
            je @@end
            cmp [edx.sprite_delete],Off
            je @@ok
            dec [edx.sprite_delete]
            jmp @@cont
@@ok:
            cmp [edx.sprite_status],Off
            je @@next
@@cont:
            mov esi,[edx.sprite_old_xy]
            mov edi,[edx.sprite_old_xy_dx]

            SBANK

            add esi,Video_Buffer

            mov ebp,[edx.sprite_old_size_y]
            mov ebx,[edx.sprite_old_size_x]

            push edx
            mov edx,screen_x
            mov eax,direct_x_pitch
            add ebx,3
            and ebx,11111111111111111111111111111100b
            sub eax,ebx
            sub edx,ebx
            shr ebx,2
            align 4
@@ligne:
            mov ecx,ebx
            rep movsd

            add edi,eax
            add esi,edx

            dec ebp
            jnz @@ligne
            pop edx

            mov esi,[edx.sprite_new_xy]
            mov edi,[edx.sprite_new_xy_dx]

            SBANK

            add esi,Video_Buffer

            mov ebp,[edx.sprite_size_y]
            mov ebx,[edx.sprite_size_x]

            push edx
            mov edx,screen_x
            mov eax,direct_x_pitch
            add ebx,3
            and ebx,11111111111111111111111111111100b
            sub eax,ebx
            sub edx,ebx
            shr ebx,2
            align 4
@@ligne2:
            mov ecx,ebx
            rep movsd

            add edi,eax
            add esi,edx

            dec ebp
            jnz @@ligne2
            pop edx

            mov eax,[edx.sprite_new_xy]
            mov [edx.sprite_old_xy],eax
            mov eax,[edx.sprite_new_xy_dx]
            mov [edx.sprite_old_xy_dx],eax
            mov eax,[edx.sprite_size_x]
            mov [edx.sprite_old_size_x],eax
            mov eax,[edx.sprite_size_y]
            mov [edx.sprite_old_size_y],eax
@@next:
            add edx,size struc_sprites
            jmp @@loop
@@end:
            pop es
            ret


;----------------------------------------------------------------------------
;           mov edi,pos_y
;           mov ebx,pos_x
;           mov ecx,nbs_lgn
;           mov edx,nbs_col
Erase_Shape:
;----------------------------------------------------------------------------

            call _erase_shape
            call flip_screen
            ret

_Erase_Shape:
            pushad
            lea edi,[edi+edi*4]
            shl edi,7
            add edi,ebx             ; edi=(pos_y*screen_x)+pos_x
            mov erase_o,edi
            mov esi,edi
            add esi,true_background_buffer

            pushad
            add edi,video_buffer
            call __Erase_Shape
            popad
            add edi,background_buffer
            call __Erase_Shape

            popad
            ret

__Erase_Shape:
            mov ebp,ecx
            mov ebx,screen_x
            sub ebx,edx
@@ligne:
            mov ecx,edx

            rep movsb

            add edi,ebx
            add esi,ebx

            dec ebp
            jnz @@ligne
            ret

            .data
erase_o     dd ?
            .code


;----------------------------------------------------------------------------
;           mov edi,pos_y
;           mov ebx,pos_x
;           mov ecx,nbs_lgn
;           mov edx,nbs_col
;           mov esi,Shape adrs
Draw_Shape:
;----------------------------------------------------------------------------

            call _draw_shape
            call flip_screen
            ret

_Draw_Shape:
            pushad

            lea edi,[edi+edi*4]
            shl edi,7
            add edi,ebx             ; edi=(pos_y*screen_x)+pos_x
            add esi,sprite_buffer

            pushad
            add edi,video_buffer
            call __Draw_Shape
            popad
            add edi,background_buffer
            call __Draw_Shape

            popad
            ret

__Draw_Shape:
            mov ebp,ecx
            mov ebx,screen_x
            sub ebx,edx
@@ligne:
            mov ecx,edx

            @@loop:
            lodsb
            or al,al
            jz @@cont
            mov B [edi],al
            @@cont:
            inc edi
            loop @@loop

            add edi,ebx
            add esi,ebx

            dec ebp
            jnz @@ligne
            ret


;----------------------------------------------------------------------------
Flip_Buffer:
;----------------------------------------------------------------------------

           pushad
           mov edi,0
           mov ebx,0
           mov ecx,screen_y
           mov edx,screen_x
           call _flip_screen
           popad
           ret


;----------------------------------------------------------------------------
;           mov edi,pos_y
;           mov ebx,pos_x
;           mov ecx,nbs_lgn
;           mov edx,nbs_col
flip_screen:
;----------------------------------------------------------------------------

            pushad
            mov esi,video_buffer
            call _flip_screen
            popad
            ret


;----------------------------------------------------------------------------
_flip_screen:
;----------------------------------------------------------------------------

            push edi
            lea edi,[edi+edi*4]
            shl edi,7
            add esi,edi
            add esi,ebx
            pop edi

            mov eax,direct_x_pitch
            imul edi,eax
            add edi,ebx

            push es
            mov es,[screen]

            SBANK

            mov ebp,ecx
            mov eax,screen_x
            sub eax,edx
            mov ebx,direct_x_pitch
            sub ebx,edx
@@ligne2:
            mov ecx,edx
            rep movsb

            add edi,ebx
            add esi,eax

            dec ebp
            jnz @@ligne2

            pop es
            ret


;----------------------------------------------------------------------------
Draw_Buffer:
;----------------------------------------------------------------------------

            call _Draw_Buffer

            call Flip_Buffer

            ret


;----------------------------------------------------------------------------
_Draw_Buffer:
;----------------------------------------------------------------------------

            push ecx
            push esi
            push edi
            rep movsd
            pop edi
            pop esi
            pop ecx
            ret


;----------------------------------------------------------------------------
Draw_Point:
;----------------------------------------------------------------------------

            pushad

            lea eax,[eax+eax*4]
            shl eax,7
            add eax,ebx
            mov edi,eax

            push edi
            add edi,video_buffer
            mov al,12
            stosb
            pop edi

            push edi
            add edi,background_buffer
            mov al,12
            stosb
            pop edi

            push es
            mov es,[screen]

            SBANK

            mov al,12
            stosb

            pop es

            popad
            ret


;----------------------------------------------------------------------------
clipping_box:
;----------------------------------------------------------------------------

            push ebp

            mov clip_error,Off
            mov clip_error2,Off
            xor esi,esi
            xor edi,edi

            cmp eax,0
            jns @@ok1
            add ecx,eax
            mov esi,eax
            mov eax,0
@@ok1:
            cmp ebx,0
            jns @@ok2
            add edx,ebx
            mov edi,ebx
            neg edi
            mov ebx,0
@@ok2:
            cmp eax,screen_x-1
            jb @@ok3
            ja @@ok33
            mov clip_error2,On
            jmp @@ok3
@@ok33:
            mov eax,screen_x-1
            mov clip_error,On
@@ok3:
            cmp ebx,screen_y-1
            jb @@ok4
            ja @@ok44
            mov clip_error2,On
            jmp @@ok4
@@ok44:
            mov ebx,screen_y-1
            mov clip_error,On
@@ok4:
            mov ebp,screen_x-1
            sub ebp,eax
            inc ebp
            cmp ecx,ebp
            jl @@ok7
            mov ecx,ebp
@@ok7:
            mov ebp,screen_y-1
            sub ebp,ebx
            inc ebp
            cmp edx,ebp
            jl @@ok8
            mov edx,ebp
@@ok8:
            cmp ecx,0
            jle @@end
            cmp edx,0
            jle @@end
            cmp clip_error,On
            je @@end
            pop ebp
            clc
            ret
@@end:
            mov ecx,1
            mov edx,1
            pop ebp
            stc
            ret

            .data
clip_error  dd 0
clip_error2 dd 0
            .code