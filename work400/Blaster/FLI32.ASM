
;----------------------------------------------------------------------------
;º                                                                          º
;º Chargement en m‚moire et track disque                                    º
;º                                                                          º
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
fli_error_check:
;----------------------------------------------------------------------------

            pop es
            xor eax,eax
            stc             ; Fli_Err = 4 (Bad FLC header)
            ret             ;           5 (Size max for FLC : 640x480)


;----------------------------------------------------------------------------
fli_error_file:
;----------------------------------------------------------------------------

            pop es
            xor eax,eax
            mov Fli_Err,2   ; Fli_Err = 2 (File error)
            stc
            ret


;----------------------------------------------------------------------------
fli_error_mem:
;----------------------------------------------------------------------------

            pop es
            xor eax,eax
            mov Fli_Err,3   ; Fli_Err = 3 (Out of memory)
            stc
            ret


;----------------------------------------------------------------------------
;           mov edx,offset File_Name
Load_Internal_Fli:
;----------------------------------------------------------------------------

            push es

            mov Fli_Err,Off
            mov Fli_Swap,Off
            mov Fli_DeAllocate,Off
            mov Fli_Close,Off
            mov Fli_Last_Frame,Off

            mov ah,Load_Internal_File
            Int_EOS

            mov Fli_Buffer,esi

            mov Fli_Size,ecx

            mov Fli_DeAllocate,On

            mov esi,Fli_Buffer
        ÿ   call Check_Fli
        ÿ   jc fli_error_check

            pop es
            mov eax,Fli_Buffer
            clc
            ret


;----------------------------------------------------------------------------
;           mov edx,offset File_Name
Load_Fli:
;----------------------------------------------------------------------------

            push es

            mov Fli_Err,Off
            mov Fli_Swap,Off
            mov Fli_DeAllocate,Off
            mov Fli_Close,Off
            mov Fli_Last_Frame,Off

            mov ax,3D00h
            _int 21h                 ; Open the file
           ÿjc fli_error_file
           ÿmov Fli_Handle,ax

            mov bx,ax

            mov Fli_Close,On

            mov ax,4202h            ; Get length
            xor cx,cx
            xor dx,dx
            _Int 21h
            jc fli_error_file

            shl edx,16
            mov dx,ax
            mov Fli_Size,edx

            mov ax,4200h
            xor dx,dx
            _Int 21h

            mov edx,Fli_Size
            mov ecx,edx

            cmp Fli_TrackDisk,On
            je Fli_Swap_On

            mov ah,Allocate_Memory_Handle
            Int_EOS
            jc Fli_Swap_On

                            mov Fli_Handle_Mem,edi
                            mov Fli_Buffer,eax
                            mov edx,eax

            mov Fli_DeAllocate,On

           ÿmov ah,3Fh
            _int 21h                 ; Read File
           ÿjc fli_error_file

            mov esi,Fli_Buffer
        ÿ ÿ call Check_Fli
        ÿ ÿ jc fli_error_check

            pop es
            mov eax,Fli_Buffer
            clc
            ret


;----------------------------------------------------------------------------
Fli_Swap_On:
;----------------------------------------------------------------------------

            mov Fli_Swap,On

            mov edx,128+4           ; Taille … Allouer
            mov ecx,128+4           ; Taille … lire

            mov ah,Allocate_Memory_Handle
            Int_EOS
            jc fli_error_mem

                            mov Fli_Handle_Mem,edi
                            mov Fli_Buffer,eax
                            mov edx,eax

            mov Fli_DeAllocate,On

           ÿmov ah,3Fh
            _int 21h                 ; Read File
           ÿjc fli_error_file

            mov esi,Fli_Buffer
        ÿ   call Check_Fli
        ÿ   jc fli_error_check

            pop es
            mov eax,Fli_Buffer
            clc
            ret


;----------------------------------------------------------------------------
Read_Frame:
;----------------------------------------------------------------------------

            push es
            push dword ptr [esi]

            mov edi,Fli_Handle_Mem
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
            mov Fli_DeAllocate,Off

            pop edx
            mov ecx,edx

            mov ah,Allocate_Memory_Handle
            Int_EOS
            jc fli_error_mem

                            mov Fli_Handle_Mem,edi
                            mov Fli_Buffer,eax
                            mov edx,eax

            mov Fli_DeAllocate,On

            mov bx,Fli_Handle
            mov ah,3Fh
            _int 21h                 ; Read File
            jc fli_error_file

            mov esi,Fli_Buffer
            sub esi,4

            add eax,esi

            pop es
            clc
            ret


;----------------------------------------------------------------------------
Init_Frame:
;----------------------------------------------------------------------------

            push es

            mov edi,Fli_Handle_Mem
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
            mov Fli_DeAllocate,Off

            mov bx,Fli_Handle
            mov ax,4200h
            xor dx,dx
            xor cx,cx
            DosInt 21h

            mov edx,128+4           ; Taille … Allouer
            mov ecx,128+4           ; Taille … lire

            mov ah,Allocate_Memory
            Int_EOS
            jc fli_error_mem

                            mov fli_handle_Mem,edi
                            mov Fli_Buffer,eax
                            mov edx,eax

            mov Fli_DeAllocate,On

           ÿmov ah,3Fh
            _int 21h                 ; Read File
           ÿjc fli_error_file

            pop es
            clc
            ret


;----------------------------------------------------------------------------
Dispose_Fli:
;----------------------------------------------------------------------------

            cmp Fli_Close,On
            jne @@cont

            mov bx,Fli_Handle
            mov ah,3Eh
            _int 21h                 ; Close the file
            mov Fli_Close,Off

@@cont:
            cmp Fli_DeAllocate,On
            jne @@end

            mov edi,Fli_Handle_Mem
            mov ah,DeAllocate_Memory_Handle
            Int_EOS

@@end:
            mov eax,On
            clc
            ret


;----------------------------------------------------------------------------
;º                                                                          º
;º Décompression FLI et FLC                                                 º
;º                                                                          º
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
Chunk_Error:
;----------------------------------------------------------------------------

           ÿpop eax
            pop ecx
           ÿpop eax
            pop ecx

           ÿmov Fli_Err,1   ; Fli_Err = 1 (Chunk not found)
            pop es
            xor eax,eax
            stc
           ÿret


;----------------------------------------------------------------------------
Load_Error:
;----------------------------------------------------------------------------

         ÿ ÿpop ecx         ; Fli_Err = 2 (Out of memory)
            pop es          ;           3 (File error)
            xor eax,eax
            stc
            ret


;----------------------------------------------------------------------------
First_Frame_Fli:
;----------------------------------------------------------------------------

            push es
            mov es,[screen]

            mov esi,Fli_Buffer
            add esi,6

            movzx ecx,word ptr [esi]    ; Nombre de frame
            add esi,122

Frames:
            push ecx

           ÿcmp Fli_Swap,Off
           ÿjz @@cont
            call Read_Frame
           ÿjc Load_Error
           ÿjmp @@cont2
@@cont:

           ÿmov eax,[esi]
           ÿadd eax,esi
@@cont2:
            push eax
            add esi,6

            cmp word ptr [esi-2],0f1fah
            jne Bad_Chunk

            mov eax,direct_x_pitch
            mov edi,Fli_Decal_Y
            imul edi,eax
            add edi,Fli_Decal_X

            SBANK

            movzx ecx,word ptr [esi]
            or cx,cx
            jz Bad_Chunk

            add esi,10
Chunk:
            push ecx

            mov eax,[esi]
            add eax,esi
            push eax

            add esi,4

            mov ax,[esi]

            cmp ax,0ch
            je Unpack_Line
            cmp ax,0fh
            je First_Packed_Frame
            cmp ax,10h
            je Uncompressed
            cmp ax,07h
            je Unpack_Line_FLC
            cmp ax,04h
            je Color_Map_FLC
            cmp ax,0bh
            je Color_Map
            cmp ax,12h
            je Mini_Frame_FLC
            cmp ax,0dh
            je Clear_Screen

            jne Chunk_Error

Next:
            pop esi

            pop ecx
            loop Chunk

            jmp Wait_External_Synchro

Return_From_External:

Bad_Chunk:

            pop esi

            pop ecx
            cmp Fli_ReStart,1
            je @@cont4
            loop Frames
@@cont4:
            pop es
            xor cx,cx
            mov Fli_ReStart,Off

            cmp Fli_Swap,Off
            jz @@cont3
            call Init_Frame
@@cont3:
            cmp Fli_Loop,On
            je First_Frame_Fli

            mov Fli_Last_Frame,On
            mov eax,On
            clc
            ret


;----------------------------------------------------------------------------
Wait_External_Synchro:
;----------------------------------------------------------------------------

            pop Current_esi
            pop Fli_Current_Frame
            pop es
            mov eax,On
            clc
            ret


;----------------------------------------------------------------------------
Next_Frame_Fli:
;----------------------------------------------------------------------------

            push es
            mov es,[screen]
            push Fli_Current_Frame
            push Current_esi
            jmp Return_From_External


;----------------------------------------------------------------------------
Color_Map:
;----------------------------------------------------------------------------

            add esi,2

            mov bx,[esi]
            add esi,2

            xor ax,ax
@@again:
            add al,byte ptr [esi]
            inc esi

            xor edx,edx
            mov dl,byte ptr [esi]
            inc esi

            mov bp,ax
            add bp,dx

            mov ecx,edx
            add cx,dx
            add cx,dx
            jnz @@cont
            mov ecx,256*3
@@cont:

            lea edi,palette
            add edi,eax
            ;mov dx,03C8h
            ;out dx,al
            ;inc dx

            ;cli
@@aga:
            ;outsb
            stosb
            loop @@aga
            ;sti

            mov ax,bp

            dec bx
            jnz @@again

            jmp Next


;----------------------------------------------------------------------------
Color_Map_FLC:
;----------------------------------------------------------------------------

            add esi,2
            mov bx,[esi]
            add esi,2

            push edi
            xor eax,eax
@@again:
            add al,byte ptr [esi]
            inc esi

            xor edx,edx
            mov dl,byte ptr [esi]
            inc esi

            mov bp,ax
            add bp,dx

            mov ecx,edx
            add cx,dx
            add cx,dx
            jnz @@cont
            mov ecx,256*3
@@cont:

            lea edi,palette
            add edi,eax
            ;mov dx,03C8h
            ;out dx,al
            ;inc dx

            ;cli
@@loop:
            mov al,byte ptr [esi]
            shr al,2
            inc esi
            stosb
            ;out dx,al
            loop @@loop

            ;sti

            mov ax,bp

            dec bx
            jnz @@again
            pop edi
            jmp Next


;----------------------------------------------------------------------------
First_Packed_Frame:
;----------------------------------------------------------------------------

            add esi,2

            xor ecx,ecx

            mov bx,Y
@@next_line:
            xor ebp,ebp

            mov dl,byte ptr [esi]
            inc esi
@@again:
            mov cl,byte ptr [esi]
            inc esi

            or cl,cl
                            jz @@nextline
            jns @@unpack

            neg cl

            add ebp,ecx
            rep movsb

            jmp @@next
@@unpack:

            mov al,byte ptr [esi]
            inc esi
            add ebp,ecx
            rep stosb

                            jmp @@next
                 @@nextline:add edi,Fli_Scr_X
                            sub edi,ebp
                            xor ebp,ebp
                            dec bx
                            jnz @@again

                            jmp Next
@@next:
                            cmp bp,X
                            je @@cont

            dec dl
            jnz @@again
                            @@cont:
            cmp bp,X
            jne @@again

            add edi,Fli_Scr_X
            sub edi,ebp

            dec bx
            jnz @@next_line

            jmp Next


;----------------------------------------------------------------------------
Unpack_Line:
;----------------------------------------------------------------------------

            add esi,2

            movzx ebx,word ptr [esi]

            int 3
            mov eax,direct_x_pitch
            imul ebx,eax

            add edi,ebx

            ;SBANK

            add esi,2

           ÿxor ecx,ecx

           ÿmov bx,[esi]
           ÿadd esi,2
@@next_line:

            xor ebp,ebp

            mov dl,byte ptr [esi]
          ÿÿinc esi
           ÿor dl,dl
            je @@next
@@again:

          ÿÿmov cl,byte ptr [esi]
          ÿÿinc esi

           ÿadd edi,ecx
            add ebp,ecx

           ÿmov cl,byte ptr [esi]
           ÿinc esi

            or cl,cl
            jns @@unpack
            neg cl

            mov al,byte ptr [esi]
            inc esi

            add ebp,ecx
            rep stosb

            jmp @@cont
@@unpack:

            add ebp,ecx
            rep movsb

@@cont:
            dec dl
            jnz @@again
@@next:
            add edi,Fli_Scr_X
            sub edi,ebp

           ÿdec bx
            jnz @@next_line

            jmp Next


;----------------------------------------------------------------------------
Unpack_Line_FLC:
;----------------------------------------------------------------------------

            add esi,2

            xor ecx,ecx
            xor edx,edx

           ÿmov bx,[esi]
           ÿadd esi,2
@@Next_Line:
            xor ebp,ebp

           ÿmov dx,[esi]
           ÿadd esi,2
          ÿÿor dx,dx
            jns @@again

            neg dx

            mov eax,direct_x_pitch
            imul edx,eax

            add edi,edx

            ;SBANK

            jmp @@Next_Line

@@again:
            mov cl,byte ptr [esi]
            inc esi

            add edi,ecx
            add ebp,ecx

            mov cl,byte ptr [esi]
            inc esi

            or cl,cl
            jns @@unpack

            neg cl

            mov ax,[esi]
            add esi,2
            add ebp,ecx
            add ebp,ecx
            rep stosw

            jmp @@cont
@@unpack:

            add ebp,ecx
            add ebp,ecx
            rep movsw

@@cont:
            dec dx
            jnz @@again
@@next:
          ÿÿadd edi,Fli_Scr_X
            sub edi,ebp

  ÿÿÿÿÿÿÿ ÿÿdec bx
           ÿjnz @@Next_Line

            jmp Next


;----------------------------------------------------------------------------
Uncompressed:
;----------------------------------------------------------------------------

            add esi,2

            mov bx,Y
            movzx edx,X
@@loop:
            mov ecx,edx
            rep movsb
            add edi,Fli_Scr_X
            sub edi,edx
            dec bx
            jnz @@loop

            jmp Next


;----------------------------------------------------------------------------
Clear_Screen:
;----------------------------------------------------------------------------

            add esi,2

            mov eax,Fli_Scr_Y
            shr eax,2

            int 3
            mov ecx,direct_x_pitch
            imul ecx,eax

            xor eax,eax
            rep stosd

            jmp Next


;----------------------------------------------------------------------------
Mini_Frame_FLC:
;----------------------------------------------------------------------------

            add esi,2

            jmp Next


;----------------------------------------------------------------------------
Check_Fli:
;----------------------------------------------------------------------------

            mov eax,Fli_Size
            cmp dword ptr [esi+0],eax
            jne @@error

           ÿcmp word ptr  [esi+6],0
           ÿje @@error
           ÿcmp word ptr  [esi+8],4
           ÿjb @@error
           ÿcmp word ptr  [esi+10],4
           ÿjb @@error
          ÿÿcmp word ptr  [esi+4],0af11h    ; FLI
          ÿÿje @@fli
          ÿÿcmp word ptr  [esi+4],0af12h    ; FLC
          ÿÿjne @@error
@@fli:
          ÿÿcmp word ptr  [esi+8],640
          ÿÿja @@error_size
          ÿ cmp word ptr  [esi+10],480
           ÿja @@error_size

            mov Fli_Delay,1
            movzx eax,word ptr [esi+16]
            and eax,0ffh
            jz @@nodelay
            mov Fli_Delay,eax
@@nodelay:

            cmp word ptr  [esi+8],320
            ja @@Fli_Svga
	cmp word ptr  [esi+10],200
            ja @@Fli_Svga

            mov Fli_Svga,Off
            mov Fli_Scr_X,320
            mov Fli_Scr_Y,200

            jmp @@cont
@@Fli_Svga:
            mov Fli_Svga,On
            mov Fli_Scr_X,640
            mov Fli_Scr_Y,480
@@cont:
            xor edx,edx

            mov dx,word ptr [esi+8]
      ÿÿÿ ÿÿmov X,dx

      ÿÿÿÿ ÿmov ecx,Fli_Scr_X
      ÿÿÿÿ ÿsub ecx,edx
      ÿÿÿÿ ÿshr ecx,1
      ÿÿÿÿ ÿmov Fli_Decal_X,ecx

       ÿÿ ÿÿmov dx,word ptr [esi+10]
       ÿÿ ÿÿmov Y,dx

       ÿÿ ÿÿmov ecx,Fli_Scr_Y
       ÿÿ ÿÿsub ecx,edx
       ÿÿ ÿÿshr ecx,1
       ÿ ÿÿÿmov Fli_Decal_Y,ecx

            mov edx,direct_x_pitch
            mov Fli_Scr_X,edx

            mov eax,On
            clc
            ret
@@error:
           ÿmov Fli_Err,4
            xor eax,eax
            stc
            ret

@@error_size:
           ÿmov Fli_Err,5
            xor eax,eax
            stc
            ret


            .data

;----------------------------------------------------------------------------
; Tables
;----------------------------------------------------------------------------

                    align

Fli_Handle_Mem      dd ?
Fli_Handle          dw ?
Fli_Buffer          dd ?
Fli_Delay           dd ?
Fli_Size            dd ?

Y                   dw ?
X                   dw ?
Fli_Decal_Y         dd ?
Fli_Decal_X         dd ?
Fli_Scr_X           dd ?
Fli_Scr_Y           dd ?

Current_esi         dd ?
Fli_Current_Frame   dd ?

Fli_Loop            db On
Fli_ReStart         db Off
Fli_Svga            db Off
Fli_Swap            db Off
Fli_DeAllocate      db Off
Fli_Close           db Off
Fli_TrackDisk       db Off
Fli_Last_Frame      db Off

Fli_Err             db 0

            .code