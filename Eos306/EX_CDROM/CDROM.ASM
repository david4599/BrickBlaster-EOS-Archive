;浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
;�                                                                          �
;� This example show how to use the CDROM library                           �
;�                                                                          �
;�                                                                          �
;�                                                                          �
;� Tabs : 13 21 29 37                                                       �
;�                                                                          �
;藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕

            Locals
            Jumps
            .486

CODE32 SEGMENT PUBLIC PARA 'CODE' USE32
ASSUME CS:CODE32,DS:CODE32,ES:CODE32,SS:CODE32

INCLUDE ..\resource\EOS.INC

Current_Track       db ?

CD_Command          db 128 dup (0)

Msg_Usage           db "    � Usage CDROM.EXE <play> <stop> <resume> <eject> <info> <1..79>",13,10,36
Msg_Done            db "    陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�",13,10,36
Msg_Playing         db "    � Playing : 00'00  Track 00/00",13,10,36
Msg_Playing_All     db "    � Command play all",13,10,36
Msg_Open            db "    � Command door open",13,10,36
Msg_Close           db "    � Command door close",13,10,36
Msg_Stop            db "    � Command stop",13,10,36
Msg_Resume          db "    � Command resume",13,10,36
Msg_Current         db "    � Current track 00 at 00'00",13,10,36
Msg_Not_Found       db "    � CD-ROM or MSCDEX not found !",13,10,36
Msg_Found           db "    � CD-ROM detected drive A: (MSCDEX Version 0.00)",13,10,36

;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
Start32:
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳

            mov ah,9
            mov edx,O Msg_Done
            int 21h

            Get_Param CD_Command
            jc Error

            call Detect_CDROM
            mov edx,O Msg_Not_Found
            jc Exit

            mov ax,First_CDROM
            add Msg_Found+28,al

            cmp CD_Command,'i'
            je Info
            cmp CD_Command,'e'
            je Eject
            cmp CD_Command,'r'
            je Resume
            cmp CD_Command,'s'
            je Stop

            xor eax,eax
            mov al,'1'
            cmp CD_Command,'p'
            je Play_All
            cmp CD_Command,'1'
            jb Error
            cmp CD_Command,'9'
            ja Error
            mov al,B CD_Command
Play_All:
            sub al,'0'

            cmp CD_Command+1,'0'
            jb @@cont
            cmp CD_Command+1,'9'
            ja @@cont
            mov bl,B CD_Command+1
            sub bl,'0'
            imul eax,10
            add al,bl
@@cont:
            mov ebx,0
            cmp CD_Command,'p'
            jne @@cont_
            mov ebx,1
@@cont_:
            mov Current_Track,al
            call Play_Track
            jc Error

            movzx eax,Current_Track
            call Get_Track_Info
            call Calc_Time

            mov edx,O Msg_Playing
            cmp CD_Command,'p'
            jne @@cont2
            mov edx,O Msg_Playing_All
@@cont2:
            jmp Exit
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
Info:
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
            call Display_Info
            mov edx,O Msg_Done
            jmp Exit2
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
Eject:
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
            call Open_CDROM
            jnc @@end
            call Close_CDROM
            mov edx,O Msg_Close
            jmp Exit
@@end:
            mov edx,O Msg_Open
            jmp Exit
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
Resume:
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
            call Resume_CDROM
            mov edx,O Msg_Resume
            jmp Exit
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
Stop:
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
            call Stop_CDROM
            mov edx,O Msg_Stop
            jmp Exit
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
Error:
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
            mov edx,O Msg_Usage
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
Exit:
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
            mov ah,9
            int 21h
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
Exit2:
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
            mov edx,O Msg_Done
            mov ah,Exit_Error
            Int_EOS


;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
calcagain:
            mov byte ptr [esi+ebx],'0'
            dec ebx
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
calc_inc:
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
            cmp byte ptr [esi+ebx],1
            je calc_max
            inc byte ptr [esi+ebx]
            cmp byte ptr [esi+ebx],'9'
            ja calcagain
calc_max:
            ret


;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
Calc_Time:
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳

            lea edi,Track_Info

            movzx ecx,[edi._Track_Info._min]
            jecxz @@minute2
            mov W Msg_Playing+16,'00'
@@minute:
            lea esi,Msg_Playing
            mov ebx,17
            call calc_inc
            loop @@minute
@@minute2:

            movzx ecx,[edi._Track_Info._sec]
            jecxz @@seconde2
            mov W Msg_Playing+19,'00'
@@seconde:
            lea esi,Msg_Playing
            mov ebx,20
            call calc_inc
            loop @@seconde
@@seconde2:

            movzx ecx,[edi._Track_Info._track]
            mov W Msg_Playing+29,'00'
@@track:
            lea esi,Msg_Playing
            mov ebx,30
            call calc_inc
            loop @@track

            mov ecx,Track_Nbs
            mov W Msg_Playing+32,'00'
@@trackmax:
            lea esi,Msg_Playing
            mov ebx,33
            call calc_inc
            loop @@trackmax

            ret


;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
Display_Info:
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳

            movzx ecx,B Version_MSCDEX+1
            jecxz @@vers12
@@vers1:
            lea esi,Msg_Found
            mov ebx,47
            call calc_inc
            loop @@vers1
@@vers12:

            movzx ecx,B Version_MSCDEX+0
            jecxz @@vers22
@@vers2:
            lea esi,Msg_Found
            mov ebx,50
            call calc_inc
            loop @@vers2
@@vers22:
            mov ah,9
            mov edx,O Msg_Found
            int 21h

            call Get_Current_Track_Info
            call Get_Current_Track_Info
            jc @@end
            cmp [edi._Track_Info._index],0
            jne Display_Info2

            mov ah,9
            mov edx,O Msg_Done
            int 21h

            call Get_Nb_Tracks
            mov eax,1
@@again:
            push ebx
            push eax

            call Get_Track_Info
            call Calc_Time

            mov B Msg_Playing+2,' '
            lea edi,Track_Info

            mov B Msg_Playing+5,36
            mov ah,9
            mov edx,O Msg_Playing
            int 21h

            mov B Msg_Playing+34,36
            mov ah,9
            mov edx,O Msg_Playing+22
            int 21h

            mov B Msg_Playing+21,13
            mov B Msg_Playing+22,10
            mov B Msg_Playing+23,36
            mov ah,9
            mov edx,O Msg_Playing+13
            int 21h

            mov B Msg_Playing+21,' '
            mov B Msg_Playing+22,' '
            mov B Msg_Playing+23,'T'

            pop eax
            inc eax
            pop ebx
            dec ebx
            jnz @@again
@@end:
            ret


;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳
Display_Info2:
;陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳

            lea edi,Track_Info

            movzx ecx,B [edi._Track_Info._track]
@@track:
            lea esi,Msg_Current
            mov ebx,21
            call calc_inc
            loop @@track

            movzx ecx,B [edi._Track_Info._min]
            jecxz @@minute2
@@minute:
            lea esi,Msg_Current
            mov ebx,27
            call calc_inc
            loop @@minute
@@minute2:
            movzx ecx,B [edi._Track_Info._sec]
            jecxz @@seconde2
@@seconde:
            lea esi,Msg_Current
            mov ebx,30
            call calc_inc
            loop @@seconde
@@seconde2:
            mov ah,9
            mov edx,O Msg_Current
            int 21h

            ret

            CODE32 ends
            end