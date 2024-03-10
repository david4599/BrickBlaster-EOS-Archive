SDATA
Buffer_Keyboard     dw 32 dup (0)
                    dw 0

List_Fonction_16h label dword
            dd 0000h,Wait_Key
            dd 0100h,Get_Status
            dd 1000h,Wait_Key
            dd 1100h,Get_Status
            dd 0fffh,0

SCODE
Simulate_Int16h:
            push ebx
            mov ebx,O List_Fonction_16h
            and eax,0ff00h
@@Ok1:
            cmp W [ebx],0fffh
            je @@Error
            cmp W [ebx],ax
            lea ebx,[ebx+8]
            jne @@Ok1
            mov ebx,D [ebx+4-8]
            xchg ebx,[esp]
            ret
@@Error:
            pop ebx
            ret 4


Wait_Key:
            CCALL   CheckWinMsg
            cmp [Buffer_Keyboard],0
            je Wait_Key
            mov ax,[Buffer_Keyboard]
            pushad
            mov edi,O Buffer_Keyboard
            lea esi,[edi+2]
            mov ecx,32
            rep movsw
            popad
            ret 4

Get_Status:
            cmp [Buffer_Keyboard],0
            jne @@Key_in
            xor eax,eax
            ret 4
@@Key_in:
            xor eax,eax
            inc eax
            ret 4