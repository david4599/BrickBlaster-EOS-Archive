Locals
.386
.model flat
.data
INCLUDE ..\RESOURCE\EOS.INC
INCLUDE INCLUDE\WINDOWS.INC
INCLUDE INCLUDE\WINEOS.INC

align
List_Simulate_Int   label Byte
                    Set_EmulateInt 10h              ,Simulate_Int10h
                    Set_EmulateInt 16h              ,Simulate_Int16h
                    Set_EmulateInt 21h              ,Simulate_Int21h
                    Set_EmulateInt 33h              ,Simulate_Int33h
                    db 0                            ,0

msg_eos             db 'WinEOS '
                        Ver_EOS,0

align
Code32_Sel          dw 0
Data32_Sel          dw 0
Flat_Data_Sel       dw 0
Flat_Code_Sel       dw 0
Environment_Addr    dd 0
Psp_Addr            dd 0
Environment_Sel     dw 0
PSP_Sel             dw 0
_0b0000h            dd 0b0000h
_0b8000h            dd 0b8000h
__0a0000h           label dword
_0a0000h            dd 0a0000h
_direct_x_pitch     label dword
direct_x_pitch      dd 0
_Timer_Value        label dword
Timer_Value         dd 14

Timer_Handler       dd O Int_08

Code32_Addr         dd 0
Server_Type         db WINDOWS
align
Zero_Addr           dd 0
DxVersion           dd 0
DxPlatform          dd 0
MainhWnd            dd 0            ; Window Handle
AppActive           dd 0            ; 0 if App is not Active
Exiting             dd Off

Nb_Handle_Mem       = 128   ; MUST BE EQUAL
Addr_List_Mem       dd O List_Mem
List_Mem            dd Nb_Handle_Mem dup (0)

szTitle             db 'Win EOS '
                    Ver_EOS,256 dup (0)
szClassName         db 'Win EOS '
                    Ver_EOS,256 dup (0)
MsgTimer            db 'Cannot Initialize Timer',0
wc                  WNDCLASS <CS_HREDRAW or CS_VREDRAW,WndProc,0,0,0,0,0,0,0,szClassName>
msgbuf              MSG  <>
CurrentProcess      dd 0

SCODE

global DosStart : proc
DosStart:
            mov [Code32_Sel],cs
            mov [Flat_Code_Sel],cs
            mov [Data32_Sel],ds
            mov [Flat_Data_Sel],ds

            WIN32CALL GetCurrentProcess
            mov     [CurrentProcess],eax
            WIN32CALL GetModuleHandle,0
            mov     [wc.wcInstance],eax
            WIN32CALL LoadString,[wc.wcInstance],IDS_APP_TITLE,<O szTitle>,MAX_LOADSTRING
            WIN32CALL LoadString,[wc.wcInstance],IDS_APP_TITLE,<O szClassName>,MAX_LOADSTRING
            WIN32CALL FindWindow <O szClassName>,<O szTitle>
            test    eax,eax
            je      @@Not_Running
            mov     [wc.wcInstance],eax
            WIN32CALL ShowWindow,[wc.wcInstance],SW_RESTORE
            WIN32CALL BringWindowToTop,[wc.wcInstance]
            WIN32CALL SetForegroundWindow,[wc.wcInstance]
            WIN32CALL ExitProcess,0

@@Not_Running:

; VirtualProtect((void *)(PStart32 & 0xfffff000),65536*2,PAGE_EXECUTE_READWRITE,&popo);
            mov     eax,[wc.wcInstance]
            push eax
            WIN32CALL VirtualProtect,eax,20000h,PAGE_EXECUTE_READWRITE,esp
            add esp,4

            WIN32CALL LoadCursor,0,IDC_ARROW ; Default Cursor
            mov     [wc.wcCursor],eax

            WIN32CALL LoadIcon,[wc.wcInstance],IDI_APP_ICON
            mov     [wc.wcIcon],eax         ; Icon From Resource

            WIN32CALL RegisterClass,<O wc>
            test    eax,eax
            je      Panic_exit

;            WIN32CALL CreateWindowEx,0,<O szClassName>,<O szTitle>,WS_VISIBLE+WS_OVERLAPPEDWINDOW,0,0,640,480,0,0,[wc.wcInstance],0
            WIN32CALL CreateWindowEx,0,<O szClassName>,<O szTitle>,WS_VISIBLE+WS_POPUP,0,0,640,480,0,0,[wc.wcInstance],0
            test    eax,eax
            je      Panic_exit
            mov     [MainhWnd],eax
            WIN32CALL UpdateWindow,eax

            mov     [Exiting],Off
            CCALL   CheckWinMsg

            call    InitDosEnvironment
            call    Init_EOS
            call    InitDirectX
            CCALL   DiamondTimerInit,<O TimerHandle>,20
            test    eax,eax
            jne     @@TimerOk
            mov     ah,Exit_Error
            mov     edx,O MsgTimer
            Int_EOS
@@TimerOk:
            WIN32CALL BringWindowToTop,[wc.wcInstance]
            WIN32CALL SetForegroundWindow,[wc.wcInstance]
            CCALL   CheckWinMsg

            CCALL   SetAcquireInput,[hWnd],[AppActive] ; get Keyboard & Mouse
            CCALL   SetAcquireDraw,[hWnd],[AppActive]

            CCALL   Start32
            mov     ax,4c00h
            _int    21h
@@Loop:
            CCALL   CheckWinMsg

            jmp     @@Loop

_CheckWinMsg:
            cmp     [Exiting],On
            je      @@skip_msg
            pushad
            CCALL DDrawUnLock
@@msg_loop:
            WIN32CALL PeekMessage,<O msgbuf>,0,0,0,PM_REMOVE
            test    eax,eax
            jz      @@end_loop
            cmp     [msgbuf.msgMessage],WM_QUIT
            je      exit_eos
            cmp     [msgbuf.msgMessage],WM_ACTIVATEAPP
            jne     @@SkipDDraw
            mov     eax,[msgbuf.msgWparam]
            test    eax,eax
            jne     @@SkipDDraw
            CCALL   SaveDDraw
@@SkipDDraw:
            WIN32CALL TranslateMessage,<O msgbuf>
            WIN32CALL DispatchMessage,<O msgbuf>
            jmp     @@msg_loop

@@end_loop:
            cmp     [AppActive],0           ; Repeat until App is Ruuning
            je      @@msg_loop
            CCALL DDrawLock
            popad
@@skip_msg:
            ret

exit_eos:
            WIN32CALL GetCurrentProcess
            WIN32CALL SetPriorityClass,eax,NORMAL_PRIORITY_CLASS
            mov     [Exiting],On
            call    Close_EOS
            CCALL   DiamondTimerDone
            call    CloseDirectX
Panic_exit:
            WIN32CALL ExitProcess,0         ; (error) return code


;-------------------------------------------------------------------------------
;long FAR PASCAL WindowProc(HWND hWnd,UINT message,WPARAM wParam, LPARAM lParam)
WndProc:
arg hWnd,Message,wParam,lParam
            push    ebp
            mov     ebp,esp
            mov     eax,[Message]

            cmp     eax,WM_ACTIVATEAPP
            jne     @@Skip_Active
            mov     eax,[wParam]
            mov     [AppActive],eax
            CCALL   SetAcquireInput,[hWnd],[AppActive]
            CCALL   SetAcquireDraw,[hWnd],[AppActive]
            WIN32CALL GetCurrentProcess
            mov     ebx,NORMAL_PRIORITY_CLASS
            cmp     [AppActive],0
            je @@NotActive
            mov     ebx,REALTIME_PRIORITY_CLASS
@@NotActive:
            WIN32CALL SetPriorityClass,eax,ebx
            jmp     MsgExit
@@Skip_Active:

            cmp     eax,WM_CHAR
            jne     @@Skip_Char
            cmp     [Remove_Flag],Off       ; Use_Int_09 = Off
            jne     @@Skip_Char
            mov     al,B [wParam]
            mov     ah,B [lParam+2]
            xor     ebx,ebx
@@Repeat:
            cmp     [Buffer_Keyboard+ebx],0
            je      @@Add_Key
            add     ebx,2
            cmp     ebx,32
            jne     @@Repeat
            jmp     @@Exit
@@Add_Key:
            mov     [Buffer_Keyboard+ebx],ax
@@Exit:
            pop     ebp
            xor     eax,eax
            ret     16
@@Skip_Char:
            cmp     eax,WM_DESTROY
            jne     @@Skip_Destroy
            WIN32CALL PostQuitMessage,0     ; (error) return code
            jmp     MsgExit
@@Skip_Destroy:

MsgCarry:
            pop     ebp
            jmp     DefWindowProc

MsgExit:
            pop     ebp
            mov     eax,1
            ret     16

TimerHandle:
            cmp     [AppActive],0
            je      @@SkipUpdate
            CCALL   UpdateInputStateKeyboard,<O Key_Map>
            call    [Timer_Handler]
@@SkipUpdate:
            CCALL    Update_Diamond,[AppActive]
            ret 14h


Int_08:
            ret

;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
;�                              EOS                                         �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
INCLUDE EOS.ASM
INCLUDE VESA.ASM
INCLUDE JOYSTICK.ASM
INCLUDE INT_16.ASM
;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
;�                              EOS                                         �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
msg_dinput  db "Unable to Initialise Direct Input : %x %s",0
msg_ddraw   db "Unable to Initialise Direct Draw : %x %s",0
msg_dsound  db "Unable to Initialise Direct Sound : %x %s",0
SCODE
InitDirectX:
            push    ebp
            mov     ebp,esp
            sub     esp,256
            CCALL   GetDXVersion,<O DxVersion>,<O DxPlatform>

            CCALL   InitDirectInput,[wc.wcInstance],[MainhWnd]
            mov     edx,O msg_dinput
            test    eax,eax
            jne     @@Error_DirectX
            CCALL   InitDirectDraw,[wc.wcInstance],[MainhWnd]
            mov     edx,O msg_ddraw
            test    eax,eax
            jne     @@Error_DirectX
            CCALL   InitDirectSound,[wc.wcInstance],[MainhWnd]
            mov     edx,O msg_dsound
            test    eax,eax
            jne     @@Error_DirectX
            mov     esp,ebp
            pop     ebp
            ret

@@Error_DirectX:
            push    eax
            push    edx
            CCALL   getErrorString,eax
            pop     edx
            pop     ecx
            mov     ebx,esp
            WIN32CALL wsprintf,ebx,edx,ecx,eax
            mov ah,Exit_Error
            mov edx,esp
            Int_EOS
CloseDirectX:
            CCALL   FreeDirectSound
            CCALL   FreeDirectDraw
            CCALL   FreeDirectInput
            ret



InitDosEnvironment:
            WIN32CALL GetEnvironmentStrings
            mov esi,eax
            mov edi,eax
            xor eax,eax
            mov ecx,16384
            repne scasw
            mov edx,16384
            sub edx,ecx
            add edx,edx
            mov ecx,edx
            add edx,512
            mov ah,Allocate_Memory_Handle
            Int_EOS
            jc exit_eos
            mov [Environment_Addr],eax
@@Copy_Env:
            cmp W [esi],0
            movsb
            jne @@Copy_Env
            movsb
            WIN32CALL GetCommandLine
            mov esi,eax                     ; Skip '"'
            cmp B [esi],'"'
            jne @@DontSkip
            inc esi
@@DontSkip:
            mov ax,0001
            stosw
@@Copy_Name:
            movsb
            cmp B [esi],0
            je @@EndCopy_Name
            cmp B [esi],'"'
            jne @@Copy_Name
@@EndCopy_Name:
            ret


Simulate_Int:
            CCALL CheckWinMsg
            push ebx
            push eax
            mov al,B [esp+4*3]
            PushDS
            mov ebx,O List_Simulate_Int
            LoadDS
@@Ok1:
            cmp B [ebx],0
            je @@Invalid_Interrupt
            cmp B [ebx],al
            lea ebx,[ebx+5]
            jne @@Ok1
            mov ebx,D [ebx+1-5]
            PopDS
            pop eax
            xchg ebx,[esp]
            ret

@@Invalid_Interrupt:
            PopDS
            pop ebx
            LoadDS
            mov ah,al
            and ax,0ff0h
            shr al,4
            add ax,'00'
            Adjust_Hex al
            Adjust_Hex ah
            mov W [err_int],ax
            mov ah,Exit_Error
            mov edx,offset msg_int
            Int_EOS

Simulate_Int10h:
            test ah,ah
            je @@Set_Mode
            cmp ah,0fh
            je @@Get_Mode
            cmp ax,4f02h
            je @@Set_ModeVesa
            cmp ax,4f03h
            je @@Get_ModeVesa
            stc
            ret 4
@@Set_Mode:
            and eax,0ffh
            call Init_Vesa
            ret 4
@@Get_Mode:
            mov eax,CurrentMode.VesaModeNum
            ret 4

@@Set_ModeVesa:
            mov eax,ebx
            and eax,0ffffh
            call Init_Vesa
            mov eax,4fh
            ret 4

@@Get_ModeVesa:
            mov ebx,CurrentMode.VesaModeNum
            mov eax,4fh
            ret 4



            END DosStart