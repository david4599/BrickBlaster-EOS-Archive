NULL                = 0
DEL                 = 1
NUM                 = 2
VAR                 = 3
CONS                = 4

            .data
Token               dd 0,0
Type_               db 0
Value               dd 0
            .code

next_line           = 13

;----------------------------------------------------------------------------
Get_String:
;----------------------------------------------------------------------------

            cmp B [esi],'+'
            je  Convert_Expression
            cmp B [esi],'-'
            je  Convert_Expression
            cmp B [esi],'0'
            jb  @@exit
            cmp B [esi],'9'
            jbe Convert_Expression
@@exit:
            ret


;----------------------------------------------------------------------------
Convert_Expression:
;----------------------------------------------------------------------------

            push eax
            push ebx
            push ecx
            push edi
            call Parse
            push O Value
            call Level1
            add esp,4
            pop edi
            pop ecx
            pop ebx
            pop eax
            mov edx,[Value]
            inc esi
            ret
Parse:
            mov [Type_],NULL
            mov al,[esi]
            mov edi,O Token
            test al,al
            mov D [edi],0
            je @@End
            cmp al,')'
            je @@End
                                                cmp al,NEXT_LINE
                                                je @@End
            cmp al,','
            je @@End
            cmp al,'+'
            je @@Operator
            cmp al,'-'
            je @@Operator
            cmp al,'*'
            je @@Operator
            cmp al,'/'
            je @@Operator
            cmp al,'{'
            je @@Operator
            cmp al,'}'
            jne @@Not_Operator
@@Operator:
            mov [Type_],DEL
            movsb
            jmp @@End

@@Not_Operator:
            cmp W [esi],'x0'
            je @@Number
            mov al,[esi]
            call IsNumberDec
            jc @@End
@@Number:
            call Get_Value
            mov [edi+4],eax
            mov [Type_],NUM
            jmp @@End

@@End:
            ret


Level1:
            push D [esp+4]
            call Level2
            add esp,4
            ret

Level2:
            sub esp,8                               ; 2 Variable Locals
            mov D [esp+4],0
            mov D [esp],0                           ; Current Token
            push D [esp+12]
            call Level3
            add esp,4
@@Repeat0:
            mov cl,B [Token]
            mov [esp],cl
            cmp cl,'+'
            je @@Repeat
            cmp cl,'-'
            jne @@End
@@Repeat:
            call Parse
            lea eax,[esp+4]                         ; Tmp Variable
            push eax
            call Level3
            add esp,4
            cmp B [esp],'+'
            jne @@Not_Plus
            mov ebx,[esp+12]
            mov eax,[esp+4]
            add [ebx],eax
            jmp @@Repeat0
@@Not_Plus:
            cmp B [esp],'-'
            jne @@Repeat0
            mov ebx,[esp+12]
            mov eax,[esp+4]
            sub [ebx],eax                           ; Destination
            jmp @@Repeat0
@@End:
            add esp,8
            ret

Level3:
            sub esp,8                               ; 2 Variable Locals
            mov D [esp+4],0
            mov D [esp],0                           ; Current Token
            push D [esp+12]
            call Level5
            add esp,4
@@Repeat0:
            mov cl,B [Token]
            mov [esp],cl
            cmp cl,'*'
            je @@Repeat
            cmp cl,'/'
            je @@Repeat
            cmp cl,'%'
            jne @@End
@@Repeat:
            call Parse
            lea eax,[esp+4]                         ; Tmp Variable
            push eax
            call Level5
            add esp,4
            cmp B [esp],'*'                         ; Multiplication
            jne @@Not_Multi
            mov ebx,[esp+12]
            mov eax,[esp+4]
            imul eax,[ebx]                          ; Dest
            mov [ebx],eax
            jmp @@Repeat0
@@Not_Multi:
            cmp B [esp],'/'                         ; Division
            jne @@Not_Div
            mov ebx,[esp+12]                        ; Destination
            mov eax,[ebx]
            cdq
            idiv D [esp+4]
            mov [ebx],eax
            jmp @@Repeat0
@@Not_Div:
            cmp B [esp],'%'                         ; Modulo
            jne @@Repeat0
            mov ebx,[esp+12]                        ; Destination
            mov eax,[ebx]
            cdq
            idiv D [esp+4]
            mov [ebx],edx
            jmp @@Repeat0
@@End:
            add esp,8
            ret

Level5:
            sub esp,8                               ; 2 Variable Locals
            mov D [esp+4],0
            mov D [esp],0                           ; Current Token
            mov cl,B [Token]
            cmp cl,'+'
            je @@Repeat
            cmp cl,'-'
            jne @@End
@@Repeat:
            mov [esp],cl
            call Parse
@@End:
            push D [esp+12]                         ; Not Tmp Variable
            call Level6
            add esp,4
            cmp B [esp],'-'
            jne @@Not_Neg
            mov ebx,[esp+12]
            neg D [ebx]                             ; Dest
@@Not_Neg:
            add esp,8
            ret



Level6:
            cmp B [Token],'{'
            jne @@Not_Parenthesis
            call Parse
            cmp B [Token],'}'
            je @@Error
            push D [esp+4]                          ; Param
            call Level1
            add esp,4
            cmp B [Token],'}'
            jne @@Error
            call Parse
            ret

@@Not_Parenthesis:
            cmp [Type_],NUM
            jne @@Not_Num
            mov ebx,[esp+4]
            mov eax,[Token+4]                       ; Get Param
            mov [ebx],eax
            call Parse
            ret
@@Not_Num:
            cmp [Type_],VAR
            jne @@Error
            mov ebx,[esp+4]
            mov eax,[Token+4]                       ; Get Param
            mov [ebx],eax
            call Parse
            ret
@@Error:
            jmp Error_File
            ret

;----------------------------------------------------------------------------컴
; Test si le caractere peut etre un chiffre dec
;
;----------------------------------------------------------------------------컴
IsNumberDec:
            sub al,'0'
            cmp al,'9'-'0'
            lea eax,[eax+48]
            jbe @@Ok1
            stc
            ret

@@Ok1:
            clc
            ret

;----------------------------------------------------------------------------컴
; Get_Value
;
;----------------------------------------------------------------------------컴
            .data
Hex2Dec     db 0,1,2,3,4,5,6,7,8,9,0,0,0,0,0,0,0,10,11,12,13,14,15
            .code

Get_Value:
            push ebx
            push ecx
            push edx
            push edi
            push ebp
            xor ecx,ecx
            mov ebx,10
            mov ebp,O IsNumberDec
            mov ax,[esi]
            cmp ax,'x0'
            jne @@Not_Hex
            add esi,2
            mov ebx,16
            mov ebp,O IsNumberHex
@@Not_Hex:

@@Ok10:
            mov al,[esi]
            cmp al,' '
            je @@Found_Value
            call HiCase
            call ebp
            jc @@Found_Value
            imul ecx,ebx
            and eax,0ffh
            sub al,'0'
            movzx eax,[Hex2Dec+eax]
            add ecx,eax
            inc esi
            inc edi
            jmp @@Ok10

@@Found_Value:
            mov eax,ecx
            pop ebp
            pop edi
            pop edx
            pop ecx
            pop ebx
            ret

@@Error:
;            Error1 Number
            ret

;----------------------------------------------------------------------------컴
; Test si le caractere peut etre un chiffre hex
;
;----------------------------------------------------------------------------컴
IsNumberHex:
            sub al,'0'
            cmp al,'9'-'0'
            lea eax,[eax+48]
            jbe @@Ok1
            sub al,'a'
            cmp al,'f'-'a'
            lea eax,[eax+97]
            jbe @@Ok1
            sub al,'A'
            cmp al,'F'-'A'
            lea eax,[eax+65]
            jbe @@Ok1
            stc
            ret
@@Ok1:
            clc
            ret




LowCase:
            cmp al,'A'
            jb @@Ok1
            cmp al,'Z'
            ja @@Ok1
            add al,'a'-'A'
@@Ok1:
            ret

HiCase:
            cmp al,'a'
            jb @@Ok1
            cmp al,'z'
            ja @@Ok1
            add al,'A'-'a'
@@Ok1:
            ret

;----------------------------------------------------------------------------컴
; Test si le caractere courant est autoriser dans les variables
;         fonctions constantes ou labels
IsCarac:
;----------------------------------------------------------------------------컴

            cmp al,'_'
            je @@Ok1
            sub al,'0'
            cmp al,'9'-'0'
            lea eax,[eax+48]
            jbe @@Ok1
            sub al,'a'
            cmp al,'z'-'a'
            lea eax,[eax+97]
            jbe @@Ok1
            stc
            ret

@@Ok1:
            clc
            ret