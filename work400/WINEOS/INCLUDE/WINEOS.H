#include <ddraw.h>
#include <dinput.h>
#include <windows.h>
// #include "..\diam95\include\diam95.h"
#include <resource.h>
#include "..\resource\eos.h"

//Main.c
LPSTR __cdecl getErrorString( HRESULT ddrval );

// GETDXVER.C
void GetDXVersion(LPDWORD pdwDXVersion, LPDWORD pdwDXPlatform);

//Int_EOS.ASM
extern void __cdecl *_0a0000h;
extern long __cdecl direct_x_pitch;
extern DWORD __cdecl Timer_Value;

// DINPUT.C
HRESULT __cdecl InitDirectInput(HINSTANCE hInst,HWND hWnd );
HRESULT __cdecl SetAcquireInput( HWND hWnd,BOOL bActive );
HRESULT __cdecl UpdateInputStateMouse(DIMOUSESTATE *dims);
HRESULT __cdecl UpdateInputStateKeyboard(unsigned char *diks);
HRESULT __cdecl UpdateInputStateJoystick(DIJOYSTATE *js);
HRESULT __cdecl FreeDirectInput();

// DDRAW.C
HRESULT __cdecl InitDirectDraw(HINSTANCE hInst, HWND hWnd );
HRESULT __cdecl SetAcquireDraw( HWND hWnd,BOOL bActive );
HRESULT __cdecl FreeDirectDraw();
void __cdecl Wait_Synchro();
void __cdecl Set_Palette(long org,long len,char *palette);
void __cdecl Get_Palette(char *palette);
void __cdecl RestorePalette();
void __cdecl DDrawLock();
void __cdecl DDrawUnLock();
void __cdecl SaveDDraw();

LPDIRECTDRAWSURFACE4 __cdecl CreateCompatibleSurface(void *ptr,long x,long y,long bpp);
void __cdecl FlipToScreen(LPDIRECTDRAWSURFACE4 src,long x,long y,long sizex,long sizey);