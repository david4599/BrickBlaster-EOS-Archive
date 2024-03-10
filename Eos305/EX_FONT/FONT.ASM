
.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\resource\eos.inc
INCLUDE font.inc

Start32:
	mov ax,13h
	DosInt 10h

	textcolor 15
	writeLn 'WARLOCK''S FONT SYSTEM V1.0 FOR EOS :)'
	textcolor 14
	write 'AND NOW DA NEXT LINE IN YELLOW - WOW !!!'
	writeLn ' - AND DEMONSTRATING: CROSS X MAXIMUM VALUE....'
	textcolor 10
	write 'SEE IN CODE: "abc" = always "ABC" only letters-in-low'
            writeln ' '
	textcolor 11
	write 'i can do GOTOXY, too...see: 10,10'
	gotoxy 10,10
 	textcolor 15
	write 'AND WRITE HEX AL=12H VALUE: '
	textcolor 12
	mov al,12h ;write 12h to screen
	write8h
	gotoxy 0,15
	writeln 'my coordinates :) 0,15'
	textcolor 15
	write 'write hex ax value (for exp.4321h): '
	mov ax,4321h
	write16h
            writeln ' '
	write 'and yellow eax'' value coz my hex phone: '
	textcolor 14
	mov eax,0422011h
	write32h
	gotoxy 10,23
	write 'press ESC'


 EscKey:
	in al,60h
	cmp al,1
	jne EscKey

	mov ax,04c00h
	int 21h

CODE32 ENDS

END