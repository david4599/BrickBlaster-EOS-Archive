; Resource Define
IDI_APP_ICON        = 125
IDS_APP_TITLE       = 126
TRUE        = 1
FALSE       = 0


MAX_LOADSTRING      = 100

DIMOUSESTATE struc
lX          dd 0
lY          dd 0
lZ          dd 0
rgbButtons  db 0,0,0,0
            ends


_FILETIME           STRUC
dwLowDateTime       dd 0
dwHighDateTime      dd 0
_FILETIME		ENDS

_WIN32_FIND_DATA    STRUC
dwFileAttributes    dd 0
ftCreationTime      _FILETIME <>
ftLastAccessTime    _FILETIME <>
ftLastWriteTime     _FILETIME <>
nFileSizeHigh       dd 0
nFileSizeLow        dd 0
dwReserved0         dd 0
dwReserved1         dd 0
cFileName           db 260 DUP (0)
cAlternateFileName  db 14 DUP (0)
_WIN32_FIND_DATA    ENDS

_DOS_FIND_DATA      STRUC
fReserved           db 21 dup (0)
fAttributes         db 0
fLastWriteTime      dw 0
fLastWriteDate      dw 0
fFileSize           dd 0
fFileName           db 14 dup (0)
_DOS_FIND_DATA      ENDS




Adjust_Hex macro x
Local aaaa
            cmp x,'9'
            jbe aaaa
            add x,'A'-'9'-1
aaaa:
	   endm

Set_EmulateInt  Macro x,y
                    db x
                    dd offset y
         endm


WINAPI      macro x,y,z
ifb       <z>
global      _&x&@&y& : proc
x           equ _&x&@&y&
else
global      _&x&A@&y& : proc
x           equ _&x&A@&y&
endif
&x&_PARAM   equ y/4
            endm

WINAPI2     macro x,z
ifb       <z>
global      _&x : proc
x           equ _&x
else
global      _&x&A : proc
x           equ _&x&A
endif
&x&_PARAM   equ -1
            endm

CAPI        macro x
global      _&x : proc
x           equ _&x
            endm

CVAR        macro x,y
ifb       <y>
global      _&x : dword
else
global      _&x : y
endif
x           equ _&x
            endm

WIN32CALL   macro WIN32FUNC,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13
            LOCAL count
            count=0
             IRP tmp,<arg13,arg12,arg11,arg10,arg9,arg8,arg7,arg6,arg5,arg4,arg3,arg2,arg1>
               IFNB <tmp>
               push tmp
               count=count+1
               ENDIF
              ENDM
              IF &WIN32FUNC&_PARAM NE -1
               IF count NE &WIN32FUNC&_PARAM
                .ERR "Invalid Number of Parameter"
               ENDIF
              ENDIF
            call   WIN32FUNC
            IF &WIN32FUNC&_PARAM EQ -1
            add esp,count*4
            ENDIF

            endm
CCALL       macro CFUNC,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13
            LOCAL count
            count=0
             IRP tmp,<arg13,arg12,arg11,arg10,arg9,arg8,arg7,arg6,arg5,arg4,arg3,arg2,arg1>
               IFNB <tmp>
               push tmp
               count=count+1
               ENDIF
              ENDM
            call CFUNC
            IF count NE 0
            add esp,count*4
            ENDIF
            ENDM


;WIN32       macro

WINAPI      GetCurrentDirectory,8,A
WINAPI      SetCurrentDirectory,4,A
WINAPI      GetEnvironmentStrings,0
WINAPI      GetCommandLine,0,A
;PosquitMessage(UINT uExitCode);
WINAPI      PostQuitMessage,4
;ExitProcess(UINT uExitCode);
WINAPI      ExitProcess,4
;MessageBox(HWND hWnd , LPCSTR lpText, LPCSTR lpCaption,UINT uType)
WINAPI      MessageBox,16,A
WINAPI      SetFocus,4
WINAPI      DefWindowProc,16,A
WINAPI      GetModuleHandle,4,A
;BOOL SetPriorityClass(HANDLE hProcess,DWORD dwPriorityClass)
WINAPI      SetPriorityClass,8


WINAPI      RegisterClass,4,A
WINAPI      RegisterClassEx,4,A


WINAPI      CreateWindowEx,48,A
;  UpdateWindow( MainhWnd );
WINAPI      UpdateWindow,4
WINAPI      ShowWindow,8

WINAPI      PeekMessage,20,A
WINAPI      GetMessage,16,A
WINAPI      TranslateMessage,4
WINAPI      DispatchMessage,4,A

WINAPI2     wsprintf,A

;HANDLE FindFirstFile(LPCTSTR lpFileName,LPWIN32_FIND_DATA lpFindFileData);
WINAPI      FindFirstFile,8,A
;BOOL FindNextFile(HANDLE hFindFile,LPWIN32_FIND_DATA lpFindFileData);
WINAPI      FindNextFile,8,A
;BOOL FindClose(HANDLE hFindFile);
WINAPI      FindClose,4
;BOOL FileTimeToDosDateTime(FILETIME *lpFileTime,LPWORD lpFatDate,LPWORD lpFatTime);
WINAPI      FileTimeToDosDateTime,12
;DWORD GetShortPathName(LPCTSTR lpszLongPath,LPTSTR lpszShortPath,DWORD cchBuffer);
WINAPI      GetShortPathName,12,A


;LoadIcon( hInstance, (LPCSTR)IDI_APP_ICON);
WINAPI      LoadIcon,8,A
WINAPI      LoadCursor,8,A
WINAPI      SetCursor,4
WINAPI      ShowCursor,4
;  VirtualProtect((void *)(PStart32 & 0xfffff000),65536*2,PAGE_EXECUTE_READWRITE,&popo);
WINAPI      VirtualProtect,16
WINAPI      GetCurrentProcess,0
WINAPI      SetPriorityClass,8
;    hwndFind = FindWindow (szWindowClass, szTitle);
WINAPI      FindWindow,8,A
;   BringWindowToTop (hwndLast);
WINAPI      BringWindowToTop,4
;    SetForegroundWindow (hwndLast);
WINAPI      SetForegroundWindow,4
;  LoadString(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
WINAPI      LoadString,16,A

WINAPI      GlobalAlloc,8
WINAPI      GlobalLock,4
WINAPI      GlobalFree,4
WINAPI      GlobalReAlloc,12

;HANDLE CreateFile(  LPCTSTR lpFileName,          // pointer to name of the file
;  DWORD dwDesiredAccess,       // access (read-write) mode
;  DWORD dwShareMode,           // share mode
;  LPSECURITY_ATTRIBUTES lpSecurityAttributes,
;                               // pointer to security attributes
;  DWORD dwCreationDisposition,  // how to create
;  DWORD dwFlagsAndAttributes,  // file attributes
;  HANDLE hTemplateFile         // handle to file with attributes to
;                               // copy);
WINAPI      CreateFile,28,A
WINAPI      ReadFile,20
WINAPI      WriteFile,20
WINAPI      CloseHandle,4
WINAPI      SetFilePointer,16


Global Interrupt_EOS : proc
Global Simulate_Int : proc

; EOSC.C Declaration

;void GetDXVersion(LPDWORD pdwDXVersion, LPDWORD pdwDXPlatform)
CAPI GetDXVersion
;long __cdecl  DiamondTimerInit(void *proc,long msInterval)       /* Event interval */
CAPI DiamondTimerInit
;void __cdecl DiamondTimerDone()
CAPI DiamondTimerDone




; DINPUT.C
;HRESULT __cdecl InitDirectInput(HINSTANCE hInst,HWND hWnd );
CAPI InitDirectInput

;HRESULT __cdecl SetAcquireInput( HWND hWnd,BOOL bActive );
CAPI SetAcquireInput
;HRESULT __cdecl UpdateInputStateMouse(DIMOUSESTATE *dims);
CAPI UpdateInputStateMouse
;HRESULT __cdecl UpdateInputStateKeyboard(unsigned char *diks);
CAPI UpdateInputStateKeyboard
;HRESULT __cdecl UpdateInputStateJoystick(DIJOYSTATE *js)
CAPI UpdateInputStateJoystick
;HRESULT __cdecl FreeDirectInput();
CAPI FreeDirectInput

; DDRAW.C
;HRESULT __cdecl InitDirectDraw(HINSTANCE hInst, HWND hWnd );
CAPI InitDirectDraw
;HRESULT __cdecl SetAcquireDraw( HWND hWnd,BOOL bActive );
CAPI SetAcquireDraw
;HRESULT __cdecl SetMode (HWND hWnd,long ScreenX,long ScreenY,long Bpp)
CAPI SetMode
;HRESULT __cdecl FreeDirectDraw();
CAPI FreeDirectDraw
;void __cdecl Wait_Synchro();
CAPI Wait_Synchro
;void __cdecl Set_Palette(long org,long len,char *palette);
CAPI Set_Palette
;void __cdecl RestorePalette();
CAPI RestorePalette
;void __cdecl SaveDDraw();
CAPI SaveDDraw
;void __cdecl DDrawLock();
CAPI DDrawLock
;void __cdecl DDrawUnLock();
CAPI DDrawUnLock
;void __cdecl Set_Palette(long org,long len,char *palette)
CAPI Set_Palette

; DSOUND.C
;HRESULT __cdecl InitDirectSound(HINSTANCE hInst,HWND hWnd)
CAPI InitDirectSound

;void __cdecl FreeDirectSound()
CAPI FreeDirectSound
;void __cdecl UpdateDiamond(BOOL AppActive)
CAPI Update_Diamond

;DIAM95.C
; LSYS_InitModule(void* AddressOfModule,LONG SizeOfModule);
CAPI LSYS_InitModule
; LSYS_PlayModule(void *mod);
CAPI LSYS_PlayModule
; LSYS_ReleaseModule(void *mod);
CAPI LSYS_ReleaseModule
CAPI LSYS_StartModule
CAPI LSYS_StopModule
CAPI LSYS_PauseModule
CAPI LSYS_ResumeModule
CAPI LSYS_SetModuleVolume
; LSYS_GetModulePosition(LONG *position,LONG *patternLine);
CAPI LSYS_GetModulePosition
; LSYS_SetModulePosition(LONG positionNb)
CAPI LSYS_SetModulePosition
CAPI LSYS_GetModulePositionNumber
CAPI LSYS_GetModuleStatus
;LSYS_Set_Real_Stereo(BOOL val);
CAPI LSYS_Set_Real_Stereo

CAPI Load_External_Sample

CAPI Start32


;LPSTR __cdecl getErrorString( HRESULT ddrval )
CAPI getErrorString
;static void myTimerInit(void);
;static UINT myTimerSet(long msInterval);       /* Event interval */

CAPI CheckWinMsg

; Vesa Public Variables
CVAR      VideoModeX
CVAR      VideoModeY
CVAR      SizeScreen
global    __0a0000h : dword


global    _direct_x_pitch : dword
global    direct_x_pitch : dword
global    _Timer_Value : dword
global    Timer_Value : dword

Global      _IRQ_Table : dword