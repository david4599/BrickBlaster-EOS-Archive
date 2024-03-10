#include <wineos.h>
#define TARGET_RESOLUTION 1  /* Try for 1-millisecond accuracy. */

  static  TIMECAPS        tc;
  static  UINT            wTimerRes;
  static  UINT            wTimerID;

typedef struct
{
    HRESULT	rval;
    LPSTR	str;
} ERRLIST;


static ERRLIST elErrors[] =
{
    { DD_OK, "DD_OK" },
    { DDERR_ALREADYINITIALIZED, "DDERR_ALREADYINITIALIZED" },
    { DDERR_CANNOTATTACHSURFACE, "DDERR_CANNOTATTACHSURFACE" },
    { DDERR_CANNOTDETACHSURFACE, "DDERR_CANNOTDETACHSURFACE" },
    { DDERR_CURRENTLYNOTAVAIL, "DDERR_CURRENTLYNOTAVAIL" },
    { DDERR_EXCEPTION, "DDERR_EXCEPTION" },
    { DDERR_GENERIC, "DDERR_GENERIC" },
    { DDERR_HEIGHTALIGN, "DDERR_HEIGHTALIGN" },
    { DDERR_INCOMPATIBLEPRIMARY, "DDERR_INCOMPATIBLEPRIMARY" },
    { DDERR_INVALIDCAPS, "DDERR_INVALIDCAPS" },
    { DDERR_INVALIDCLIPLIST, "DDERR_INVALIDCLIPLIST" },
    { DDERR_INVALIDMODE, "DDERR_INVALIDMODE" },
    { DDERR_INVALIDOBJECT, "DDERR_INVALIDOBJECT" },
    { DDERR_INVALIDPARAMS, "DDERR_INVALIDPARAMS" },
    { DDERR_INVALIDPIXELFORMAT, "DDERR_INVALIDPIXELFORMAT" },
    { DDERR_INVALIDRECT, "DDERR_INVALIDRECT" },
    { DDERR_LOCKEDSURFACES, "DDERR_LOCKEDSURFACES" },
    { DDERR_NO3D, "DDERR_NO3D" },
    { DDERR_NOALPHAHW, "DDERR_NOALPHAHW" },
    { DDERR_NOCLIPLIST, "DDERR_NOCLIPLIST" },
    { DDERR_NOCOLORCONVHW, "DDERR_NOCOLORCONVHW" },
    { DDERR_NOCOOPERATIVELEVELSET, "DDERR_NOCOOPERATIVELEVELSET" },
    { DDERR_NOCOLORKEY, "DDERR_NOCOLORKEY" },
    { DDERR_NOCOLORKEYHW, "DDERR_NOCOLORKEYHW" },
    { DDERR_NOEXCLUSIVEMODE, "DDERR_NOEXCLUSIVEMODE" },
    { DDERR_NOFLIPHW, "DDERR_NOFLIPHW" },
    { DDERR_NOGDI, "DDERR_NOGDI" },
    { DDERR_NOMIRRORHW, "DDERR_NOMIRRORHW" },
    { DDERR_NOTFOUND, "DDERR_NOTFOUND" },
    { DDERR_NOOVERLAYHW, "DDERR_NOOVERLAYHW" },
    { DDERR_NORASTEROPHW, "DDERR_NORASTEROPHW" },
    { DDERR_NOROTATIONHW, "DDERR_NOROTATIONHW" },
    { DDERR_NOSTRETCHHW, "DDERR_NOSTRETCHHW" },
    { DDERR_NOT4BITCOLOR, "DDERR_NOT4BITCOLOR" },
    { DDERR_NOT4BITCOLORINDEX, "DDERR_NOT4BITCOLORINDEX" },
    { DDERR_NOT8BITCOLOR, "DDERR_NOT8BITCOLOR" },
    { DDERR_NOTEXTUREHW, "DDERR_NOTEXTUREHW" },
    { DDERR_NOVSYNCHW, "DDERR_NOVSYNCHW" },
    { DDERR_NOZBUFFERHW, "DDERR_NOZBUFFERHW" },
    { DDERR_NOZOVERLAYHW, "DDERR_NOZOVERLAYHW" },
    { DDERR_OUTOFCAPS, "DDERR_OUTOFCAPS" },
    { DDERR_OUTOFMEMORY, "DDERR_OUTOFMEMORY" },
    { DDERR_OUTOFVIDEOMEMORY, "DDERR_OUTOFVIDEOMEMORY" },
    { DDERR_OVERLAYCANTCLIP, "DDERR_OVERLAYCANTCLIP" },
    { DDERR_OVERLAYCOLORKEYONLYONEACTIVE, "DDERR_OVERLAYCOLORKEYONLYONEACTIVE" },
    { DDERR_PALETTEBUSY, "DDERR_PALETTEBUSY" },
    { DDERR_COLORKEYNOTSET, "DDERR_COLORKEYNOTSET" },
    { DDERR_SURFACEALREADYATTACHED, "DDERR_SURFACEALREADYATTACHED" },
    { DDERR_SURFACEALREADYDEPENDENT, "DDERR_SURFACEALREADYDEPENDENT" },
    { DDERR_SURFACEBUSY, "DDERR_SURFACEBUSY" },
    { DDERR_SURFACEISOBSCURED, "DDERR_SURFACEISOBSCURED" },
    { DDERR_SURFACELOST, "DDERR_SURFACELOST" },
    { DDERR_SURFACENOTATTACHED, "DDERR_SURFACENOTATTACHED" },
    { DDERR_TOOBIGHEIGHT, "DDERR_TOOBIGHEIGHT" },
    { DDERR_TOOBIGSIZE, "DDERR_TOOBIGSIZE" },
    { DDERR_TOOBIGWIDTH, "DDERR_TOOBIGWIDTH" },
    { DDERR_UNSUPPORTED, "DDERR_UNSUPPORTED" },
    { DDERR_UNSUPPORTEDFORMAT, "DDERR_UNSUPPORTEDFORMAT" },
    { DDERR_UNSUPPORTEDMASK, "DDERR_UNSUPPORTEDMASK" },
    { DDERR_VERTICALBLANKINPROGRESS, "DDERR_VERTICALBLANKINPROGRESS" },
    { DDERR_WASSTILLDRAWING, "DDERR_WASSTILLDRAWING" },
    { DDERR_XALIGN, "DDERR_XALIGN" },
    { DDERR_INVALIDDIRECTDRAWGUID, "DDERR_INVALIDDIRECTDRAWGUID" },
    { DDERR_DIRECTDRAWALREADYCREATED, "DDERR_DIRECTDRAWALREADYCREATED" },
    { DDERR_NODIRECTDRAWHW, "DDERR_NODIRECTDRAWHW" },
    { DDERR_PRIMARYSURFACEALREADYEXISTS, "DDERR_PRIMARYSURFACEALREADYEXISTS" },
    { DDERR_NOEMULATION, "DDERR_NOEMULATION" },
    { DDERR_REGIONTOOSMALL, "DDERR_REGIONTOOSMALL" },
    { DDERR_CLIPPERISUSINGHWND, "DDERR_CLIPPERISUSINGHWND" },
    { DDERR_NOCLIPPERATTACHED, "DDERR_NOCLIPPERATTACHED" },
    { DDERR_NOHWND, "DDERR_NOHWND" },
    { DDERR_HWNDSUBCLASSED, "DDERR_HWNDSUBCLASSED" },
    { DDERR_HWNDALREADYSET, "DDERR_HWNDALREADYSET" },
    { DDERR_NOPALETTEATTACHED, "DDERR_NOPALETTEATTACHED" },
    { DDERR_NOPALETTEHW, "DDERR_NOPALETTEHW" },
    { DDERR_BLTFASTCANTCLIP, "DDERR_BLTFASTCANTCLIP" },
    { DDERR_NOBLTHW, "DDERR_NOBLTHW" },
    { DDERR_NODDROPSHW, "DDERR_NODDROPSHW" },
    { DDERR_OVERLAYNOTVISIBLE, "DDERR_OVERLAYNOTVISIBLE" },
    { DDERR_NOOVERLAYDEST, "DDERR_NOOVERLAYDEST" },
    { DDERR_INVALIDPOSITION, "DDERR_INVALIDPOSITION" },
    { DDERR_NOTAOVERLAYSURFACE, "DDERR_NOTAOVERLAYSURFACE" },
    { DDERR_EXCLUSIVEMODEALREADYSET, "DDERR_EXCLUSIVEMODEALREADYSET" },
    { DDERR_NOTFLIPPABLE, "DDERR_NOTFLIPPABLE" },
    { DDERR_CANTDUPLICATE, "DDERR_CANTDUPLICATE" },
    { DDERR_NOTLOCKED, "DDERR_NOTLOCKED" },
    { DDERR_CANTCREATEDC, "DDERR_CANTCREATEDC" },
    { DDERR_NODC, "DDERR_NODC" },
    { DDERR_WRONGMODE, "DDERR_WRONGMODE" },
    { DDERR_IMPLICITLYCREATED, "DDERR_IMPLICITLYCREATED" },
};

/*
 * getErrorString
 */
LPSTR __cdecl getErrorString( HRESULT ddrval )
{
    int	i;

    for( i=0;i<sizeof( elErrors )/sizeof( elErrors[0] );i++ )
      if( ddrval == elErrors[i].rval )
        return elErrors[i].str;
    return "Unknown Error Code";


}
/*
void __cdecl Init_EOSC(HWND hWnd)
{
  HRESULT hr;
  char    msg_error[256];
  DWORD   pdwDXVersion,pdwDXPlatform;

  GetDXVersion(&pdwDXVersion,&pdwDXPlatform);
  switch (pdwDXPlatform)
  {
    case VER_PLATFORM_WIN32_NT:
        if (pdwDXVersion < 0x300)
        {
          wsprintf (msg_error,"This program need DirectX 3.0 or above \n"
                             "and your current version of DirectX is %x.%x",pdwDXVersion>>8,(pdwDXVersion&0xff));
          exit_error (msg_error);
        }
        break;

    case VER_PLATFORM_WIN32_WINDOWS:
        if (pdwDXVersion < 0x600)
        {
          wsprintf (msg_error,"This program need DirectX 5.0 or above \n"
                             "and your current version of DirectX is %x.%x",pdwDXVersion>>8,(pdwDXVersion&0xff));
          exit_error (msg_error);
        }
        break;
  }

  if ((hr=InitDirectInput(hWnd))!=S_OK)
  {
    wsprintf (msg_error,"Unable to Initialise Direct Input : %x %s",hr,getErrorString(hr));
    exit_error (msg_error);
  }

  if ((hr=InitDirectDraw(hWnd))!=DD_OK)
  {
    wsprintf (msg_error,"Unable to Initialise Direct Draw : %x %s",hr,getErrorString(hr));
    exit_error (msg_error);
  }
  if ((hr=DSOUND_Init(hWnd))!=DS_OK)
  {
    wsprintf (msg_error,"Unable to Initialise Direct Sound : %x %s",hr,getErrorString(hr));
    exit_error (msg_error);
  }

  myTimerInit();
  myTimerSet(20);
//  SetPriorityClass(GetCurrentProcess(),HIGH_PRIORITY_CLASS);

}
*/
/*void __cdecl Close_EOSC(hWnd)
{
  SetPriorityClass(GetCurrentProcess(),NORMAL_PRIORITY_CLASS);
  myTimerDone();
  DSOUND_Close();
  FreeDirectDraw();
  FreeDirectInput();
}
*/

/*static void PASCAL TimerHandler(UINT wTimerID, UINT msg,
    DWORD dwUser, DWORD dw1, DWORD dw2)
{
  if (g_bActive )  // update only when active
  {
    UpdateInputStateMouse(&Dims);
    UpdateInputStateKeyboard(&Key_Map);
  }

  Update_Diamond();
}
*/
long __cdecl  DiamondTimerInit(void *proc,long msInterval)       /* Event interval */
{

  if(timeGetDevCaps(&tc, sizeof(TIMECAPS)) != TIMERR_NOERROR)
    return TIMERR_NOCANDO;

  wTimerRes = min(max(tc.wPeriodMin, TARGET_RESOLUTION),tc.wPeriodMax);
  timeBeginPeriod(wTimerRes);
  timeKillEvent(wTimerID);

  wTimerID = timeSetEvent(
         msInterval,                  /* Delay                        */
         wTimerRes,                   /* Resolution (global variable) */
         (LPTIMECALLBACK) proc,       /* Callback function   */
         (DWORD) NULL    ,            /* User data             */
         TIME_PERIODIC);              /* Event type  */


  if (wTimerID != 0)
    return TIMERR_NOCANDO;
  else
    return TIMERR_NOERROR;
}

void __cdecl DiamondTimerDone()
{
    timeKillEvent(wTimerID);
    timeEndPeriod(wTimerRes);
}