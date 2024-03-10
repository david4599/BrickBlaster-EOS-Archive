.486p
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

include mxmplay.inc

copyright db "mxmplay asm example  (c) '95/96 Niklas Beisert / pascal",10,13
          db 'EOS conversion by Eclipse',13,10,10,'$'
playing db 'playing "at0mic playboys" by Screamager... press any key to stop.$'
byebye db 13,10,'thanks for listening',13,10,'$'

module:
include atomic.inc

mxmdata db 4000h dup (?)


Start32:
            mov ah,9
            mov edx,offset copyright
            int 21h


            mov edi,1
            mov ds,cs:[Environment_Sel]
            push ds
            pop es
            call xmpGetGUSPort_
            mov ds,cs:[Data32_Sel]
            push ds
            pop es
            lea ebx,mxmdata
            mov ecx,65536
            mov esi,O module
            mov dl,MXMINTMODEDOS
            call xmpInit_
            xor eax,eax
            call xmpPlay_

            mov ah,9
            mov edx,offset playing
            int 21h

            xor ah,ah
            Int 16h

            mov ah,9
            mov edx,offset byebye
            int 21h

            call xmpStop_

            mov ax,4c00h
            int 21h

            CODE32 ENDS

            END