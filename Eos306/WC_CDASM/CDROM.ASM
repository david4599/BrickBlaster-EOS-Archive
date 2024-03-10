;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;º                                                                          º
;º This example show how to use EOS and the CDROM library with the watcom   º
;º and Flat memory model                                                    º
;º                                                                          º
;º Tabs : 13 21 29 37                                                       º
;º                                                                          º
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

            Locals
            Jumps
            .386
            .model flat
            .stack 4096
            .code

INCLUDE ..\RESOURCE\EOS.INC

Text_Mono           db 'Playing Track : '
Current_Track       db '00/'
Nb_Track            db '00     '
Min                 db '00:'
Sec                 db '00  '
Tot_Min             db '00:'
Tot_Sec             db '00',36
Msg_Usage           db "    þ Usage : -> next track   <- previous track   ESC stop",13,10,36

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Start32:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

            mov ebx,es
            call init_eos
            push ds
            pop es

            mov ah,9
            mov edx,O Msg_Usage
            int 21h

            call Detect_CDROM
            jc @@Ok100

            call Get_Nb_Tracks
            mov eax,ebx
            mov edi,O Nb_Track
            call Display_AX

            mov eax,1
            mov ebx,1
            call Play_Track

            xor ecx,ecx
@@Ok1:
            push ecx
            mov eax,[esp]
            inc eax
            xor ebx,ebx
            call Get_Track_Info

            mov esi,O Track_Info
            mov al,[esi._Track_Info._track]
            mov edi,O Current_Track
            call Display_AX
            mov al,[esi._Track_Info._min]
            mov edi,O Min
            call Display_AX
            mov al,[esi._Track_Info._sec]
            mov edi,O Sec
            call Display_AX
            mov al,[esi._Track_Info._amin]
            mov edi,O Tot_Min
            call Display_AX
            mov al,[esi._Track_Info._asec]
            mov edi,O Tot_Sec
            call Display_AX
            mov ah,Set_String_Mono
            mov ecx,[esp]
            add ecx,2
            xor ebx,ebx
            mov edx,O Text_Mono
            Int_EOS

            pop ecx
            inc ecx
            cmp ecx,[Track_Nbs]
            je @@Ok10
            cmp ecx,20
            jne @@Ok1

@@Ok10:
            mov ah,Wait_Vbl
            Int_EOS

            mov ah,Set_String_Mono
            xor ecx,ecx
            xor ebx,ebx
            mov edx,O Text_Mono
            Int_EOS

            call Get_Current_Track_Info
            mov esi,O Track_Info
            mov al,[esi._Track_Info._track]
            mov edi,O Current_Track
            call Display_AX
            mov al,[esi._Track_Info._min]
            mov edi,O Min
            call Display_AX
            mov al,[esi._Track_Info._sec]
            mov edi,O Sec
            call Display_AX
            mov al,[esi._Track_Info._amin]
            mov edi,O Tot_Min
            call Display_AX
            mov al,[esi._Track_Info._asec]
            mov edi,O Tot_Sec
            call Display_AX

            mov ah,1
            int 16h
            je @@Ok10

            xor ah,ah
            int 16h
            call Test_Key
            cmp al,27
            jne @@Ok10

            call Stop_CDROM

@@Ok100:
            mov ax,4c00h
            int 21h


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Display_AX:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

            aam
            xchg al,ah
            add ax,'00'
            mov [edi],ax
            ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Test_Key:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

            cmp ax,4b00h
            jne @@Ok1
            mov al,[esi._Track_Info._track]
            dec al
            je @@Ok1
            and eax,0ffh
            mov ebx,1
            call Play_Track
@@Ok1:
            cmp ax,4d00h
            jne @@Ok2
            mov al,[esi._Track_Info._track]
            inc al
            cmp al,B [Track_Nbs]
            jg @@Ok2
            and eax,0ffh
            mov ebx,1
            call Play_Track
@@Ok2:
            ret

            end start32