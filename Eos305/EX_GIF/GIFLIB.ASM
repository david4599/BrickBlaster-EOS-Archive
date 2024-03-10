.386
CODE32 SEGMENT PUBLIC PARA 'CODE' USE32
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32
INCLUDE ..\RESOURCE\EOS.INC
public  gif_load
public  sendpal
public  gif_xsize
public  gif_ysize
public  gif_address
public  gif_handle
public  pal_address
public	imgbits,ncolors

gif_load proc
	or ah,ah
	jz extern
	mov ah,load_internal_file_handle
	int_eos
	jmp load_ok
extern:
	mov ah,load_external_file_handle
	int_eos
	jnc load_ok
	stc
	ret
load_ok:			; Sortie de cette fction :
	mov esi,eax		;esi=adresse physique, eax=adresse dans Data32
	mov file_handle,edi	;edi=handle
	cmp d [esi],"8FIG"		;'GIF8'	J'verifie si C bien 1 Gif
	jnz this_is_not_a_gif
;lecture du nombre de bits/pixels
	mov cl,[esi+10]	;indicateur de r‚solution
	add esi,13
        and ecx,0111b	;seulement les 3  derniers bits
        inc ecx
        mov b imgbits,cl
        mov eax,1
        shl eax,cl
        mov w ncolors,ax
	lea ecx,[eax+eax*2]
        call shiftpal
extloop:
	cmp b [esi],21h		;"!":signature des blocks d'extension
        jne noext
	add esi,2
	xor ecx,ecx
	mov cl,b [esi]
	add esi,ecx
	inc esi
	mov cl,b[esi]
aplic2:
	or cl,cl
	je aplicfin
	add esi,ecx
	inc esi
	mov cl,b [esi]
	jmp aplic2
aplicfin:
	inc esi
	jmp extloop
noext:
	inc esi
	mov eax,d [esi+4]
	mov ecx,d [esi+6]
        mov w gif_xsize,ax
        mov w gif_ysize,cx
;lecture du nbre de bits/pix
	mov cl,b [esi+8]
        xor eax,eax
        test cl,64      ;image entrelac‚e?
        jz nointerlaced
        not eax
nointerlaced:
	add esi,9
        mov b interlaced,al
        test cl,128      ;palette locale?
        je noloc
        and ecx,0111b
        inc ecx
        mov b imgbits,cl
        mov eax,1
        shl eax,cl
        mov w ncolors,ax
        mov ecx,eax
	add ecx,eax
	add ecx,eax
        call shiftpal

noloc:		;initialisation des differentes variables.
	inc esi		;on saute le nbits
        xor     ebx,ebx
        mov     w lbyte,bx       ;pas de dernier code lu
	mov	ax,w ncolors
	mov	w clr,ax	;code clear= ncolors
	inc	eax
	mov	w eof,ax	;code eof= ncolors + 1
	inc	eax
	mov	w free,ax	;ncolors + 2 = 1Šre entr‚e libre
	mov	w freesav,ax
        mov     cl,b imgbits
	inc 	ecx
        mov     b nbbit,cl	;au d‚part, nbbits= imgbits + 1
        mov	b nbbitsav,cl
	mov     eax,1
        shl     eax,cl
        dec     eax
        mov     w max,ax	;max = 2^nbbits - 1
        mov	w maxsav,ax
        mov     d stackp,ebx
        mov     d restbits,ebx
        mov     d restbyte,ebx

goon:
	push esi
	movzx eax,gif_xsize
	movzx ecx,gif_ysize
	mul ecx
	mov gif_size,eax
	movzx edx,w ncolors
	lea edx,[edx+edx*2] ;taille de l'image en octets une fois d‚compress‚e
	add edx,eax		;plus la palette
	mov ah,Allocate_Memory_handle
	int_eos
	jc not_enough_ram
	mov [gif_handle],edi
	mov [pal_address],edx
	mov edi,edx

	movzx ecx,w ncolors
	lea ecx,[ecx+ecx*2]
	mov esi,O abstack
	shr ecx,2
	rep movsd
	mov [gif_address],edi
	push edi
	add edi,gif_size
	mov last_offset,edi
	pop edi esi

	;keewwwwl: on peut commencer … d‚compresser þþþþþþþþþþþþþþþþþþþþþþþþþþþ
mainloop: ;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
        call getlogbyte
        cmp ax,w eof	;fin du fichier
        je gif_end
        cmp ax,w clr	;nouvel alphabet
        je clear
        mov w readbyt,ax
        cmp ax,w free
        jb code_in_ab   ;jmp si code dans ab
        mov ax,w old_code
        mov w act_code,ax
        mov ebx,d stackp
        mov cx,w casspecial
        mov w abstack[ebx],cx
        inc d stackp
code_in_ab:
        cmp ax,w clr
        jb  concret
fillstack_loop:
  movzx ebx,w act_code             ;le code est un pointeur dans l'alphabet
  add ebx,ebx                    ;Word Array (!)
  push ebx
  mov eax,d ab_suffx[ebx]         ;cherche le suffixe, qui est concret
  mov ebx,d stackp               ;le place sur la pile
  add ebx,ebx                    ;consid‚r‚e comme Word Array
  mov w abstack[ebx],ax
  inc d stackp
  pop ebx
  mov eax,d ab_prfx[ebx]          ;cherche le pr‚fixe
  mov w act_code,ax             ;le prend comme code courant
  cmp ax,w clr
        ja fillstack_loop
concret:
  mov ebx,d stackp               ;empile le dernier code
  add ebx,ebx                   ;comme Word Array
  mov w abstack[ebx],ax
  mov w casspecial,ax           ;en prend note aussi pour le cas sp‚cial 
  inc d stackp                  ;fait progresser le pointeur
  mov ebx,d stackp               ;pr‚pare la lecture de la pile
mov ecx,ebx
  dec ebx                        ;d‚cr‚mente le pointeur
  add ebx,ebx                  ;sur Word Array 
readstack_loop:
  mov al,b abstack[ebx]          ;prend un caractŠre
   sub ebx,2                     ;pointeur de pile sur l'‚l‚ment suivant
  stosb
loop readstack_loop	;loop=rame sur 486 mais speede sur 6x86
;   cmp last_offset,edi	;si dernier pixel:
;   jb gif_end		;on sort
  mov d stackp,ecx              ;r‚initialise le pointeur de pile (ecx=0)
  movzx ebx,w free              ;met … jour l'alphabet
  add ebx,ebx                   ;… la position "free" 
  mov ax,w old_code             ;‚crit le dernier code dans pr‚fixe
  mov w ab_prfx[ebx],ax
  mov ax,w act_code             ;et le code courant dans suffixe
  mov w ab_suffx[ebx],ax
  mov ax,w readbyt              ;le code  lu est le plus r‚cent
  mov w old_code,ax
  inc w free
  mov ax,w free
  cmp ax,w max
  jna mainloop
  cmp b nbbit,12                ;nombre de bits d‚j… ‚gal … 12(max dans 1gif)?
  jnb mainloop
  inc b nbbit                   ;sinon on l'augmente
  mov eax,1                     ;1 d‚cal‚ de nbbit vers la gauche
  mov cl,b nbbit                ;nouveau maximum d'entr‚es
  shl eax,cl
  dec eax                       ;puis d‚cr‚ment‚
  mov w max,ax                  ;enregistre le maximum 
  jmp mainloop

clear:
	mov ax,w freesav
	mov w free,ax
	mov al,b nbbitsav
	mov b nbbit,al
	mov ax,w maxsav
	mov w max,ax
        call getlogbyte
        mov w casspecial,ax
        mov w old_code,ax
	stosb
;	cmp last_offset,edi	;si dernier pixel...
;	jb gif_end		;out......
        jmp mainloop
;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
gif_end:	;quand tout est fini!!
	mov ah,deallocate_memory_handle
	mov edi,file_handle
	int_eos
	cmp b[interlaced],0
	jz popo
	call uninterlace
popo:
	xor eax,eax
	clc
	ret
not_enough_ram:			;				Micro$Mou $UXX
	mov ah,deallocate_memory_handle
	mov edi,file_handle
	int_eos
	mov eax,2
	stc
	ret
this_is_not_a_gif:		;le fichier n'est pas un gif
	mov ah,deallocate_memory_handle
	mov edi,file_handle
	int_eos
	mov eax,3		;erreur 1
	stc
	ret
endp
;------------------------------ proc‚dures -----------------------------------

shiftpal proc near
        mov edi,O abstack	;transfere une palette … ecx/3 couleurs
        shr ecx,2		;de esi vers palette
@l1:
        lodsd
        shr eax,2
	and eax,3f3f3f3fh	;ze masque tant attendu...
        stosd
        dec ecx
        jnz @l1
        ret
endp

sendpal proc near	;envoie automatiquement la palette dans la VGA.
	movzx ecx,w ncolors	;Ne Fait pas vraiment partie du loader
	lea ecx,[ecx+ecx*2]
	mov dx,3c8h
	xor eax,eax
	out dx,al
	inc edx
	mov esi,pal_address
	rep outsb	;… changer car certaines cartes n'apprecient pas
	ret		;(on le dit mais j'en ai jamais vu!)
endp

getphysbyte proc near   ;destroy ebx
	xor eax,eax
        cmp d restbyte,0
        ja @yadurab
	lodsb		;longueur du data block
	mov d restbyte,eax
@yadurab:
	dec d restbyte
	lodsb
	ret
endp

getlogbyte proc near
	mov dh,b nbbit
	mov dl,b restbits
	mov cl,8
        sub cl,dl
        movzx eax,w lbyte	;pour garder les restbits interressants
        shr eax,cl	;d‚cale lbyte de 8-restbits vers la droite
        mov w act_code,ax
        cmp dh,dl
        ja  @glbsuite
	mov cl,dh
	mov ebx,1
	shl ebx,cl
        dec ebx
        and eax,ebx
        sub dl,dh
        mov b restbits,dl
	mov w act_code,ax
        ret
@glbsuite:		;si il faut lire au moins un byte physique
        sub dh,dl	;soustraire les restbits d‚ja lus
@nextbyte:
        call getphysbyte
        mov w lbyte,ax
        mov ebx,1
        mov cl,dh
        shl ebx,cl
        dec ebx
	and eax,ebx
        mov cl,dl
        shl eax,cl
        add w act_code,ax	;important de rester en word!
        sbb dl,b nbbit
        add dl,8
        jns @positif
        add dl,8
@positif:
        sub dh,8
        jle @fini
        add dl,b nbbit
        sub dl,8
        jmp @nextbyte
@fini:
        mov b restbits,dl
        mov ax,w act_code
        ret
endp
						; *** UNINTERLACE *************
uninterlace proc	;Pour remettre les images entrelac‚e dans le bon ordre
	mov ah,allocate_memory_handle
	mov edx,gif_size
	int_eos		;edx=addresse
	jc not_enough_ram2
	 push edi	;handle
	mov esi,gif_address
	mov edi,edx
	mov ecx,gif_size
	shr ecx,1
	rep movsw	;d‚place l'image interlaced dans le nouvel espace mem
	adc ecx,0
	rep movsb
	mov esi,edx

	mov edi,gif_address
	movzx ebp,gif_ysize
	add ebp,7
	shr ebp,3	;div by 8
	movzx eax,gif_xsize
	mov ebx,eax	;mul by 8
	shl eax,3
	sub eax,ebx	;eax=	xsize*7
un0:	movzx ecx,gif_xsize
	shr ecx,1
	rep movsw
	adc ecx,0
	rep movsb
	add edi,eax
	dec ebp
	jnz un0

	mov edi,gif_address
	mov edx,ebx				;edx=xsize
	shl ebx,2		;ebx=4*xsize
	add edi,ebx
	sub ebx,edx		;ebx=3*xsize
	movzx ebp,gif_ysize
	add ebp,3
	shr ebp,3	;div by 8
un1:	movzx ecx,gif_xsize
	shr ecx,1
	rep movsw
	adc ecx,0
	rep movsb
	add edi,eax
	dec ebp
	jnz un1

	mov edi,gif_address
	mov eax,edx
	add eax,edx		;eax=2*xsize
	add edi,eax
	movzx ebp,gif_ysize
	inc ebp
	shr ebp,2
un2:	movzx ecx,gif_xsize
	shr ecx,1
	rep movsw
	adc ecx,0
	rep movsb
	add edi,ebx
	dec ebp
	jnz un2

	mov edi,gif_address
	movzx ebp,gif_ysize
	inc ebp
	shr ebp,1
un3:	movzx ecx,gif_xsize
	add edi,ecx
	shr ecx,1
	rep movsw
	adc ecx,0
	rep movsb
	dec ebp
	jnz un3

	 pop edi
	mov ah,deallocate_memory_handle
	int_eos
	ret
not_enough_ram2:
	mov ah,deallocate_memory_handle
	mov edi,gif_handle
	int_eos
	pop eax	;d‚pile une addresse
	mov eax,2
	stc
	ret
endp
;---------------------------- datas -------------------------------------------
align 4	;needed? I'm not a king of Pentium optimization...
gif_address	dd ?	;addresse du buffer de destination dans Data32_sel
file_handle	dd ?
gif_handle	dd ?
pal_address	dd ?	;palette d‚ja shift‚e a la fin....
buffind         dd ?
abstack         dw 1282 dup (?)
ab_prfx         dw 4096 dup (?)
ab_suffx        dw 4096 dup (?)
free            dw ?
freesav         dw ?
nbbit           db ?
nbbitsav        db ?
max             dw ?
maxsav          dw ?
stackp          dd ?
restbits        dd ?
restbyte        dd ?
casspecial      dw ?
act_code        dw ?
old_code        dw ?
readbyt         dw ?
lbyte           dw ?
clr             dw ?	;code clear
eof             dw ?	;code 'end of file'
ncolors         dw ?
gif_xsize	dw ?	;devinez
gif_ysize	dw ?	; ! ! !
gif_size	dd ?
last_offset	dd ?	;offset du dernier point
interlaced      db ?
imgbits         db ?	;nombre de bits de l'image (de 2 … 8)
			; Toutefois, dans le buffer de destination,
code32 ends		; Chaque pixel = un octet
end
