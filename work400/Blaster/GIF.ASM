.code
;----------------------------------------------------------------------------컴
Load_Internal_Gif_Handle:
;----------------------------------------------------------------------------컴

            mov ah,Load_Internal_File_Handle
            jmp Load_Gif_Handle


;----------------------------------------------------------------------------컴
Load_External_Gif_Handle:
;----------------------------------------------------------------------------컴

            mov ah,Load_External_File_Handle
            jmp Load_Gif_Handle


;----------------------------------------------------------------------------컴
Load_Gif_Handle:
;----------------------------------------------------------------------------컴

            Int_EOS
            jc Error

                    mov esi,eax

            mov file_handle,edi
            cmp D [esi],"8FIG"
            jnz Error

            mov cl,[esi+10]         ;indicateur de r굎olution
            add esi,13
            and ecx,0111b           ;seulement les 3 derniers bits
            inc ecx
            mov B imgbits,cl
            mov eax,1
            shl eax,cl
            mov W ncolors,ax
            lea ecx,[eax+eax*2]
            call shiftpal
extloop:
            cmp B [esi],21h         ;"!":signature des blocks d'extension
            jne noext
            add esi,2
            xor ecx,ecx
            mov cl,B [esi]
            add esi,ecx
            inc esi
            mov cl,B [esi]
aplic2:
            or cl,cl
            je aplicfin
            add esi,ecx
            inc esi
            mov cl,B [esi]
            jmp aplic2
aplicfin:
            inc esi
            jmp extloop
noext:
            inc esi
            mov eax,D [esi+4]
            mov ecx,D [esi+6]
            mov W gif_x,ax
            mov W gif_y,cx

            mov cl,B [esi+8]
            xor eax,eax
            test cl,64              ;image entrelac괻?
            jz nointerlaced
            not eax
nointerlaced:
            add esi,9
            mov B interlaced,al

            test cl,128             ;palette locale?
            je noloc
            and ecx,0111b
            inc ecx
            mov B imgbits,cl
            mov eax,1
            shl eax,cl
            mov W ncolors,ax
            lea ecx,[eax+eax*2]
            call shiftpal
noloc:
            inc esi                 ;on saute le nbits
            xor ebx,ebx
            mov W lbyte,bx          ;pas de dernier code lu
            mov ax,W ncolors
            mov W clr,ax            ;code clear= ncolors
            inc eax
            mov W eof,ax            ;code eof= ncolors + 1
            inc eax
            mov W free,ax           ;ncolors + 2 = 1둹e entr괻 libre
            mov W freesav,ax
            mov cl,B imgbits
            inc ecx
            mov B nbbit,cl          ;au d굋art, nbbits= imgbits + 1
            mov B nbbitsav,cl
            mov eax,1
            shl eax,cl
            dec eax
            mov W max,ax            ;max = 2^nbbits - 1
            mov W maxsav,ax
            mov D stackp,ebx
            mov D restbits,ebx
            mov D restbyte,ebx
goon:
            movzx eax,gif_x
            movzx ecx,gif_y
            mul ecx
            mov gif_size,eax
            mov edx,eax            ;taille de l'image en octet une fois dd괹mpress괻
            mov ah,Allocate_Memory_Handle
            Int_EOS
            jc Error

                    mov edx,eax

            mov [raw_buff],edx
            mov [gif_handle],edi
            mov edi,edx

;----------------------------------------------------------------------------컴
mainloop:
;----------------------------------------------------------------------------컴

            call getlogbyte
            cmp ax,W eof            ;fin du fichier
            je Exit_Gif
            cmp ax,W clr            ;nouvel alphabet
            je clear
            mov W readbyt,ax
            cmp ax,W free
            jb code_in_ab           ;jmp si code dans ab
            mov ax,W old_code
            mov W act_code,ax
            mov ebx,D stackp
            mov cx,W casspecial
            mov W abstack[ebx],cx
            inc D stackp
code_in_ab:
            cmp ax,W clr
            jb  concret
fillstack_loop:
            movzx ebx,W act_code    ;le code est un pointeur dans l'alphabet
            add ebx,ebx             ;Word Array (!)
            push ebx
            mov eax,D ab_suffx[ebx] ;cherche le suffixe, qui est concret
            mov ebx,D stackp        ;le place sur la pile
            add ebx,ebx             ;consid굍괻 comme Word Array
            mov W abstack[ebx],ax
            inc D stackp
            pop ebx
            mov eax,D ab_prfx[ebx]  ;cherche le pr괽ixe
            mov W act_code,ax       ;le prend comme code courant
            cmp ax,W clr
            ja fillstack_loop

concret:
            mov ebx,D stackp        ;empile le dernier code
            add ebx,ebx             ;comme Word Array
            mov W abstack[ebx],ax
            mov W casspecial,ax     ;en prend note aussi pour le cas sp괹ial
            inc D stackp            ;fait progresser le pointeur
            mov ebx,D stackp        ;pr굋are la lecture de la pile
            mov ecx,ebx
            dec ebx                 ;d괹r굆ente le pointeur
            add ebx,ebx             ;sur Word Array

readstack_loop:
            mov al,B abstack[ebx]   ;prend un caract둹e
            sub ebx,2               ;pointeur de pile sur l'굃굆ent suivant
            stosb
            loop readstack_loop     ;loop=rame sur 486 mais speede sur 6x86

            mov D stackp,ecx        ;r굀nitialise le pointeur de pile (ecx=0)
            movzx ebx,W free        ;met � jour l'alphabet
            add ebx,ebx             ;� la position "free"
            mov ax,W old_code       ;괹rit le dernier code dans pr괽ixe
            mov W ab_prfx[ebx],ax
            mov ax,W act_code       ;et le code courant dans suffixe
            mov W ab_suffx[ebx],ax
            mov ax,W readbyt        ;le code  lu est le plus r괹ent
            mov W old_code,ax
            inc W free

            mov ax,W free
            cmp ax,W max
            jna mainloop
            cmp B nbbit,12          ;nombre de bits d굁� 괾al � 12(max dans 1gif)?
            jnb mainloop
            inc B nbbit             ;sinon on l'augmente
            mov eax,1               ;1 d괹al� de nbbit vers la gauche
            mov cl,B nbbit          ;nouveau maximum d'entr괻s
            shl eax,cl
            dec eax                 ;puis d괹r굆ent�
            mov W max,ax            ;enregistre le maximum
            jmp mainloop

clear:
            mov ax,W freesav
            mov W free,ax
            mov al,B nbbitsav
            mov B nbbit,al
            mov ax,W maxsav
            mov W max,ax
            call getlogbyte
            mov W casspecial,ax
            mov W old_code,ax
            stosb
            jmp mainloop


;----------------------------------------------------------------------------컴
Exit_Gif:
;----------------------------------------------------------------------------컴

            mov ah,DeAllocate_Memory_Handle
            mov edi,file_handle
            Int_EOS

            cmp B [interlaced],0
            jz @@cont
	call uninterlace
@@cont:
            mov eax,raw_buff
            mov edi,gif_handle
            clc
            ret


;----------------------------------------------------------------------------컴
Error2:
;----------------------------------------------------------------------------컴

            pop eax                 ;d굋ile une addresse

;----------------------------------------------------------------------------컴
Error:
;----------------------------------------------------------------------------컴

            mov ah,DeAllocate_Memory_Handle
            mov edi,file_handle
            Int_EOS

            mov eax,0
            stc
            ret


;----------------------------------------------------------------------------컴
shiftpal:
;----------------------------------------------------------------------------컴

            lea edi,pal             ;transfere une palette � ecx/3 couleurs
            shr ecx,2               ;de esi vers palette
@l1:
            lodsd
            shr eax,2
            and eax,00111111001111110011111100111111b
            stosd
            dec ecx
            jnz @l1
            ret


;----------------------------------------------------------------------------컴
getphysbyte:
;----------------------------------------------------------------------------컴

            xor eax,eax
            cmp D restbyte,0
            ja @yadurab
            lodsb               ;longueur du data block
            mov D restbyte,eax
@yadurab:
            dec D restbyte
            lodsb
            ret


;----------------------------------------------------------------------------컴
getlogbyte:
;----------------------------------------------------------------------------컴

            mov dh,B nbbit
            mov dl,B restbits
            mov cl,8
            sub cl,dl
            movzx eax,W lbyte   ;pour garder les restbits interressants
            shr eax,cl          ;d괹ale lbyte de 8-restbits vers la droite
            mov W act_code,ax
            cmp dh,dl
            ja  @glbsuite
            mov cl,dh
            mov ebx,1
            shl ebx,cl
            dec ebx
            and eax,ebx
            sub dl,dh
            mov B restbits,dl
            mov W act_code,ax
            ret

@glbsuite:                  ;si il faut lire au moins un byte physique
            sub dh,dl       ;soustraire les restbits d굁a lus
@nextbyte:
            call getphysbyte
            mov W lbyte,ax
            mov ebx,1
            mov cl,dh
            shl ebx,cl
            dec ebx
            and eax,ebx
            mov cl,dl
            shl eax,cl
            add W act_code,ax   ;important de rester en word!
            sbb dl,B nbbit
            add dl,8
            jns @positif
            add dl,8
@positif:
            sub dh,8
            jle @fini
            add dl,B nbbit
            sub dl,8
            jmp @nextbyte
@fini:
            mov B restbits,dl
            mov ax,W act_code
            ret


;----------------------------------------------------------------------------컴
uninterlace:
;----------------------------------------------------------------------------컴

            mov ah,Allocate_Memory_Handle
            mov edx,gif_size
            Int_EOS         ;edx=addresse
            jc Error2

                    mov edx,eax

            push edi       ;handle
            mov esi,raw_buff
            mov edi,edx
            mov ecx,gif_size
            shr ecx,1
            rep movsw       ;d굋lace l'image interlaced dans le nouvel espace mem
            adc ecx,0
            rep movsb
            mov esi,edx

            mov edi,raw_buff
            movzx ebp,gif_y
	add ebp,7
	shr ebp,3	;div by 8
            movzx eax,gif_x
	mov ebx,eax	;mul by 8
	shl eax,3
	sub eax,ebx	;eax=	xsize*7
un0:        movzx ecx,gif_x
	shr ecx,1
	rep movsw
	adc ecx,0
	rep movsb
	add edi,eax
	dec ebp
	jnz un0

            mov edi,raw_buff
	mov edx,ebx				;edx=xsize
	shl ebx,2		;ebx=4*xsize
	add edi,ebx
	sub ebx,edx		;ebx=3*xsize
            movzx ebp,gif_y
	add ebp,3
	shr ebp,3	;div by 8
un1:        movzx ecx,gif_x
	shr ecx,1
	rep movsw
	adc ecx,0
	rep movsb
	add edi,eax
	dec ebp
	jnz un1

            mov edi,raw_buff
	mov eax,edx
	add eax,edx		;eax=2*xsize
	add edi,eax
            movzx ebp,gif_y
	inc ebp
	shr ebp,2
un2:        movzx ecx,gif_x
	shr ecx,1
	rep movsw
	adc ecx,0
	rep movsb
	add edi,ebx
	dec ebp
	jnz un2

            mov edi,raw_buff
            movzx ebp,gif_y
	inc ebp
	shr ebp,1
un3:        movzx ecx,gif_x
	add edi,ecx
	shr ecx,1
	rep movsw
	adc ecx,0
	rep movsb
	dec ebp
	jnz un3

            pop edi
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
            ret

.data
;----------------------------------------------------------------------------컴
; Variables
;----------------------------------------------------------------------------컴

raw_buff    dd ?        ;addresse du buffer de destination dans Data32_sel

gif_handle  dd ?        ;handle memoire pour raw_buff
gif_x       dw ?        ;x
gif_y       dw ?        ;y
gif_size    dd ?
gif_palette dd pal
pal         db 768 dup (0)

file_handle dd ?        ;handle du fichier
imgbits     db ?        ;nombre de bits de l'image (de 2 � 8)
ncolors     dw ?        ;nombre de couleurs
interlaced  db ?
clr         dw ?        ;code clear
eof         dw ?        ;code 'end of file'
free        dw ?
freesav     dw ?
buffind     dd ?
abstack     dw 1282 dup (?)
ab_prfx     dw 4096 dup (?)
ab_suffx    dw 4096 dup (?)
nbbit       db ?
nbbitsav    db ?
max         dw ?
maxsav      dw ?
stackp      dd ?
restbits    dd ?
restbyte    dd ?
casspecial  dw ?
act_code    dw ?
old_code    dw ?
readbyt     dw ?
lbyte       dw ?