; Exemple d'utilisation de la bibliothŠque giflib.obj : en deux lignes, on
; d‚compresse un gif.

Locals
.386
CODE32 SEGMENT PUBLIC PARA 'CODE' USE32
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32
INCLUDE ..\RESOURCE\EOS.INC
INCLUDE ..\EX_GIF\GIF.INC	;IMPORTANT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Gifname		db 'eclipse.gif',0
textbidon	db '    þ NaNaRd GiF LoAdeR fOr E.O.S 3.',10,13,'$'
start32:
	mov ah,9
	mov edx,O textbidon	;‡a fait plaisir!!!!!!!
	int 21h
	      mov edx,O Gifname		;tout est dans ces 2 lignes mec!
	      call gif_load
	mov ax,13h	;mode MCGA 320x200x8bits
	dosint 10h
	call sendpal
	mov esi,[gif_address]
	mov edi,[_0a0000h]
	mov ecx,64000/4
	rep movsd

	mov ah,deallocate_memory_handle		;maintenant, on peut mˆme
	mov edi,gif_handle			;liberer la m‚moire.....
	int_eos

	xor eax,eax
	dosint 16h	;wait a key
        mov ax,4c00h	;exit progz.....
        int 21h

code32 ends
end
