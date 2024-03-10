;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Gestion de l'Interruption 33h en 32 bits
SDATA
ifndef WIN32

Set_Function_000ch  db Off
else

_Dims               Label DIMOUSESTATE
Dims                DIMOUSESTATE <>
DeltaX      dd 0
DeltaY      dd 0
PointX      dd 0
PointY      dd 0

List_Fonction_33h label dword
            dd 0000h,HardReset_Mouse
            dd 0001h,Show_Cursor
            dd 0002h,Hide_Cursor
            dd 0003h,Get_Mouse_Status
            dd 0004h,Set_Mouse_Pos
            dd 000bh,Get_Motion_Counter
            dd 0021h,SoftReset_Mouse
            dd 0fffh,0

endif

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Gestion de l'Interruption 33h en 32 bits

SCODE
Init_Mouse:
ifndef WIN32
            push fs
Assume Fs:Kernel_Setup
            mov fs,_CS[Data16_Sel]
            mov D [Addr_000ch_Offset+8],O New_Func_000ch
            mov W [Addr_000ch_Selector+7],cs
            mov [Jump_Addr_000ch],O No_Func_000ch
            mov [Jump_Addr_000ch+4],cs
Assume Fs:CODE32
            pop fs
endif
            ret


ifndef WIN32
Int_33h:
            cmp ax,0ch
            je @@Ok1
            DosInt 33h
            mIRETD
@@Ok1:
            PushDS
            LoadDS
            mov [Jump_Addr_000ch],edx
            mov [Jump_Addr_000ch+4],es
            push edx
            push [Real_ES]
            mov edx,O New_000ch
            mov [Real_ES],Seg Kernel_Setup
            DosInt 33h
            pop [Real_ES]
            pop edx
            PopDS
            mIRETD

New_Func_000ch:
            push fs
Assume Fs:Kernel_Setup
            mov fs,_CS[Data16_Sel]
            movzx eax,W [Tmp_EAX]
            movzx ebx,W [Tmp_EBX]
            movsx ecx,W [Tmp_ECX]
            movsx edx,W [Tmp_EDX]
            movsx esi,W [Tmp_ESI]
            movsx edi,W [Tmp_EDI]
Assume Fs:CODE32
            pop fs
            db 0eah
Jump_Addr_000ch Label Dword
            dd 0
            dw 0
No_Func_000ch:
            retf
            mIRETD
else
Simulate_Int33h:
            call Update_Mouse
            push ebx
            mov ebx,O List_Fonction_33h
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

Update_Mouse:
            pushad
            CCALL   UpdateInputStateMouse,<O Dims>
            mov ecx,Dims.lX
            add [DeltaX],ecx
            add [PointX],ecx
            mov edx,Dims.lY
            add [DeltaY],edx
            add [PointY],edx
            popad
            ret


HardReset_Mouse:
SoftReset_Mouse:
            mov ax,0ffffh
            mov bx,2
            ret 4

Show_Cursor:
            WIN32CALL ShowCursor,TRUE
            ret 4

Hide_Cursor:
            WIN32CALL ShowCursor,TRUE
            ret 4

Set_Mouse_Pos:
            ret 4


Get_Mouse_Status:
            xor ebx,ebx
            mov ecx,[PointX]
            mov dl,Dims.rgbButtons[2]
            add dl,dl
            adc ebx,0
            mov dl,Dims.rgbButtons[1]
            add ebx,ebx
            add dl,dl
            adc ebx,0
            mov dl,Dims.rgbButtons[0]
            add ebx,ebx
            add dl,dl
            adc ebx,0
            mov edx,[PointY]
            ret 4

Get_Motion_Counter:
            xor ecx,ecx
            xor edx,edx
            xchg ecx,[DeltaX]
            xchg edx,[DeltaY]
;            shl ecx,2
;            shl edx,2
;            lea ecx,[ecx+2*ecx]
;            lea edx,[edx+2*edx]
;            sar ecx,1
;            sar edx,1
            ret 4

endif
