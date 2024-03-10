
; 'warlock/abc

gotoXY MACRO amithesonyouvebeenwaitingfor,aty
	mov xfont,amithesonyouvebeenwaitingfor
	mov yfont,aty
       ENDM

textColor MACRO jajkonatwardo
	mov fontcolor,jajkonatwardo
  	  ENDM

write MACRO tekknosuxx
 local metalrulez,christagony
	jmp metalrulez
	christagony db tekknosuxx,'$'
 metalrulez:
	lea edx,christagony
	call fooont
      ENDM

writeLn MACRO tekknosuxx
 local metalrulez,christagony
	jmp metalrulez
	christagony db tekknosuxx,'$'
 metalrulez:
	lea edx,christagony
	call fooont
	mov xfont,0
	inc yfont
        ENDM

writeXY MACRO samael,burzum,tekknosuxx
 local metalrulez,christagony
	jmp metalrulez
	christagony db tekknosuxx,'$'
 metalrulez:
	mov xfont,samael
	mov yfont,burzum
	lea edx,christagony
	call fooont
        ENDM
 
write8h MACRO 
	call makeH8table
	lea edx,___vhex
	call fooont
	  ENDM

write16h MACRO 
	call makeH16table
	lea edx,___vhex
	call fooont
	  ENDM

write32h MACRO 
	call makeH32table
	lea edx,___vhex
	call fooont
	  ENDM

makeh32table:
	call misiujoginiemaogona
	mov d [___VHex+4],edx
	rol eax,16
	call misiujoginiemaogona
	mov d [___VHex],edx
	ret

makeh16table:
	call misiujoginiemaogona
	mov d [___VHeX],edx
	mov b [___VHex+4],'$'
	ret

___Vhex db '########$'
hexTable db '0123456789ABCDEF' ;nawet ICE'umie to zacodowac ;)

makeh8table:
	call vodkaluksusowa
	mov w [___VHeX],dx
	mov b [___VHex+2],'$'
	ret

misiujoginiemaogona:
	call vodkaluksusowa
	rol edx,16
	xchg ah,al
	call vodkaluksusowa
	ret

vodkaluksusowa:
	movzx ebx,al
	and ebx,1111b
	mov dh,[hexTable+ebx]
	movzx ebx,al
	and ebx,11110000b
	ror ebx,4
	mov dl,[hexTable+ebx]
	ret

xfont dd 0
yfont dd 0
fontcolor db 15
; IN: EDX = OFFSET TO TEXT
fooont:
	mov edi,[_0a0000h]

	mov eax,xfont
	lea eax,[eax*2+eax]
	shl eax,1
	add edi,eax
	mov eax,yfont
	cmp eax,24
	ja endNap ;fatamorgana ;)
	lea eax,[eax*4+eax]
	shl eax,9
	add edi,eax
 font1:
	mov al,[edx]
	inc edx
	cmp al,'$'
	je endNap
	cmp al,97
	jb nieodejmowacboupierdole
	sub al,32
 nieodejmowacboupierdole:
	sub al,32
	movzx eax,al
	shl eax,3
	lea esi,font
	add esi,eax
	mov ebx,8
 lupYfont:
	lodsb
	mov ecx,5
 lupXfont:	
	test al,1
	jz nodrawfont
	mov ah,fontcolor
	mov [edi],ah
 nodrawfont:
	ror al,1
	inc edi
	dec ecx
	jnz lupXfont
	add edi,320-5
	dec ebx
	jnz lupYfont
	inc Xfont
	cmp Xfont,53
	jb okefontxjestdobrykurwa
	mov xfont,0
	inc yfont
	jmp fooont
 okefontxjestdobrykurwa:
	sub edi,320*8-6
	jmp font1
 endNap:
	ret

Font label BYTE
     DB 00,00,00,00,00,00,00,00,12,12,12,12,00,12,00,00,27,27,09,00
     DB 00,00,00,00,10,31,10,31,10,00,00,00,30,05,14,20,15,04,00,00
     DB 19,11,04,26,25,00,00,00,06,11,06,23,11,22,00,00,12,12,06,00
     DB 00,00,00,00,12,06,06,06,12,00,00,00,06,12,12,12,06,00,00,00
     DB 18,12,30,12,18,00,00,00,04,04,31,04,04,00,00,00,12,12,06,00
     DB 00,00,00,00,00,00,30,00,00,00,00,00,00,00,00,12,12,00,00,00
     DB 24,12,06,03,01,00,00,00,14,25,21,19,14,00,00,00,08,12,08,08
     DB 08,00,00,00,15,16,14,01,31,00,00,00,15,16,14,16,15,00,00,00
     DB 12,10,09,31,08,00,00,00,15,01,15,16,15,00,00,00,14,01,15,17
     DB 14,00,00,00,31,16,08,04,04,00,00,00,14,17,14,17,14,00,00,00
     DB 14,17,30,16,14,00,00,00,12,12,00,12,12,00,00,00,12,12,00,12
     DB 08,04,00,00,24,12,06,12,24,00,00,00,00,30,00,30,00,00,00,00
     DB 06,12,24,12,06,00,00,00,14,25,12,12,00,12,00,00,14,17,29,13
     DB 01,30,00,00,14,17,31,17,17,00,00,00,15,17,15,17,15,00,00,00
     DB 30,01,01,01,30,00,00,00,15,17,17,17,15,00,00,00,31,01,15,01
     DB 31,00,00,00,31,01,15,01,01,00,00,00,30,01,25,17,30,00,00,00
     DB 17,17,31,17,17,00,00,00,14,04,04,04,14,00,00,00,16,16,16,17
     DB 14,00,00,00,18,10,06,10,18,00,00,00,02,02,02,02,30,00,00,00
     DB 17,27,21,17,17,00,00,00,17,19,21,25,17,00,00,00,14,17,17,17
     DB 14,00,00,00,15,17,15,01,01,00,00,00,14,17,17,17,14,24,00,00
     DB 15,17,15,05,25,00,00,00,30,01,14,16,15,00,00,00,31,04,04,04
     DB 04,00,00,00,17,17,17,17,30,00,00,00,17,17,17,10,04,00,00,00
     DB 17,17,21,27,17,00,00,00,17,10,04,10,17,00,00,00,17,17,10,04
     DB 04,00,00,00,31,08,04,02,31,00,00,00


