#include <wineos.h>
#define MAX_MODES              40
#define MIN_FREQUENCY          60
#define MIN_WIDTH              400

  static  LPDIRECTDRAW                pDD;
  static  LPDIRECTDRAW4        g_pDD       = NULL;    // DirectDraw object
  static  LPDIRECTDRAWSURFACE4 g_pDDSPrimary = NULL;  // DirectDraw primary surface
  static  LPDIRECTDRAWSURFACE4 g_pDDSBack  = NULL;    // DirectDraw back surface
  static  LPDIRECTDRAWPALETTE  g_pDDPal = NULL;
  static  PALETTEENTRY         pe[256];
  static  PALETTEENTRY         oldpe[256];
  static  BOOL                 VideoOn=FALSE;
  static  BOOL                 WaitEnd=FALSE;
  static  DWORD                GraphicsMode;
  DWORD _cdecl                 VideoModeX;
  DWORD _cdecl                 VideoModeY;
  DWORD _cdecl                 SizeScreen;
  static  void                 *VideoSave=NULL;


//-----------------------------------------------------------------------------
// Function: InitDirectDraw
//
// Description:
//      Initialize the DirectDraw variables.
//
//-----------------------------------------------------------------------------
HRESULT _cdecl InitDirectDraw(HINSTANCE hInst, HWND hWnd )
{
    HRESULT                     hRet;
    HDC                         hdc;
    long                        i;

    ///////////////////////////////////////////////////////////////////////////
    // Create the main DirectDraw object
    ///////////////////////////////////////////////////////////////////////////
    hRet = DirectDrawCreate(NULL, &pDD, NULL);
    if (hRet != DD_OK)
        return hRet;

    // Fetch DirectDraw4 interface
    hRet = IDirectDraw_QueryInterface(pDD,&IID_IDirectDraw4, (LPVOID *) & g_pDD);
    if (hRet != DD_OK)
        return hRet;

    // Get normal mode
    hRet = IDirectDraw_SetCooperativeLevel(g_pDD,hWnd, DDSCL_NORMAL);
    if (hRet != DD_OK)
        return hRet;

    // Save System Pal
    hdc=GetDC(NULL);
    GetSystemPaletteEntries (hdc, 0, 256, oldpe);
    ReleaseDC (NULL, hdc);

    for (i = 0; i < 256; i++)
    {
      pe[i].peRed =pe[i].peGreen = pe[i].peBlue = 0;
      pe[i].peFlags = PC_RESERVED;

    }

    hRet = IDirectDraw_CreatePalette(g_pDD,DDPCAPS_8BIT, pe, &g_pDDPal, NULL);
    if (hRet != DD_OK)
      return hRet;

    GraphicsMode=0;
    return DD_OK;
}

HRESULT __cdecl SetMode (HWND hWnd,long ScreenX,long ScreenY,long Bpp)
{
    DDSURFACEDESC2              ddsd;
    DDSCAPS2                    ddscaps;
    HRESULT                     hRet;
    long                        i;

    if (g_pDD==NULL)
      return DD_OK;

    if (Bpp==0)
    {
      GraphicsMode=0;
      IDirectDraw_RestoreDisplayMode(g_pDD);
      IDirectDraw_SetCooperativeLevel(g_pDD,hWnd, DDSCL_NORMAL);
      IDirectDrawPalette_SetEntries(g_pDDPal,0, 0,256,oldpe);
      IDirectDraw_FlipToGDISurface(g_pDD);
      RedrawWindow(NULL,NULL,NULL, RDW_INVALIDATE | RDW_ERASE | RDW_ALLCHILDREN);
      SetCursor(LoadCursor( NULL, IDC_ARROW ));
      ShowCursor(TRUE);
      return DD_OK;
    }
    GraphicsMode=1;
    // Get exclusive mode
    hRet = IDirectDraw_SetCooperativeLevel(g_pDD,hWnd, DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN | DDSCL_ALLOWREBOOT);
    if (hRet != DD_OK)
        return hRet;

   // Set the video mode to 640x480x8
    if (IDirectDraw2_SetDisplayMode(g_pDD,ScreenX, ScreenY,Bpp,60,0)!=DD_OK)
      hRet = IDirectDraw2_SetDisplayMode(g_pDD,ScreenX, ScreenY,Bpp,0,0);
    if (hRet != DD_OK)
        return hRet;

    // Create the primary surface with 1 back buffer
    ZeroMem(&ddsd, sizeof(ddsd));
    ddsd.dwSize = sizeof(ddsd);
    ddsd.dwFlags = DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
    ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE | DDSCAPS_COMPLEX
        | DDSCAPS_FLIP ;
    ddsd.dwBackBufferCount = 1;
    hRet = IDirectDraw_CreateSurface(g_pDD,&ddsd, &g_pDDSPrimary, NULL);
    if (hRet != DD_OK)
        return hRet;

    // Get a pointer to the back buffer
    ddscaps.dwCaps = DDSCAPS_BACKBUFFER;
    hRet = IDirectDrawSurface_GetAttachedSurface(g_pDDSPrimary,&ddscaps, &g_pDDSBack);
    if (hRet != DD_OK)
        return hRet;

    IDirectDrawSurface_SetPalette(g_pDDSPrimary,g_pDDPal);

    for (i = 0; i < 256; i++)
    {
      pe[i].peRed =pe[i].peGreen = pe[i].peBlue = 0;
      pe[i].peFlags = PC_RESERVED;

    }
    IDirectDrawPalette_SetEntries(g_pDDPal,0,0,256, pe);

    SetCursor(NULL);
    ShowCursor(FALSE);
    VideoModeX=(DWORD)ScreenX;
    VideoModeY=(DWORD)ScreenY;
    switch (Bpp)
    {
      case 8:
        SizeScreen=VideoModeX*VideoModeY;
        break;
      case 15:
        SizeScreen=VideoModeX*VideoModeY*2;
        break;
      case 16:
        SizeScreen=VideoModeX*VideoModeY*2;
        break;
      case 24:
        SizeScreen=VideoModeX*VideoModeY*3;
        break;
      case 32:
        SizeScreen=VideoModeX*VideoModeY*4;
        break;
    }
    VideoOn=TRUE;
    return DD_OK;
}
//-----------------------------------------------------------------------------
// Function: SaveDDraw
//-----------------------------------------------------------------------------
void __cdecl SaveDDraw()
{
  if ((VideoOn==TRUE) & (GraphicsMode==1) & (VideoSave==NULL))
  {
    VideoSave=GlobalAlloc(GMEM_FIXED,SizeScreen);
    DDrawLock();
    _asm {
        pushad
        mov edi,[VideoSave]
        mov esi,[_0a0000h]
        mov ecx,[SizeScreen]
        rep movsb
        popad
        };
    DDrawUnLock();
  }
}



//-----------------------------------------------------------------------------
// Function: SetAcquireDraw
//-----------------------------------------------------------------------------
HRESULT __cdecl SetAcquireDraw( HWND hWnd,BOOL bActive )
{
    if (bActive)
    {
        if (g_pDDSBack != NULL)
          IDirectDrawSurface_Restore(g_pDDSBack);
        if (g_pDDSPrimary != NULL)
          IDirectDrawSurface_Restore(g_pDDSPrimary);
        if (VideoSave!=NULL)
        {
          DDrawLock();
          _asm {
              pushad
              mov edi,[_0a0000h]
              mov esi,[VideoSave]
              mov ecx,[SizeScreen]
              rep movsb
              popad
              };
          GlobalFree(VideoSave);
          VideoSave=NULL;
          DDrawUnLock();
        }
        if ((g_pDDPal != NULL)  & (g_pDDSPrimary != NULL))
        {
            IDirectDrawSurface_SetPalette(g_pDDSPrimary,g_pDDPal);
            IDirectDrawPalette_SetEntries(g_pDDPal,0,0,256,pe);
        }
    }
    return S_OK;
}


//-----------------------------------------------------------------------------
// Name: ReleaseAllObjects()
// Desc: Finished with all objects we use; release them
//-----------------------------------------------------------------------------
HRESULT __cdecl FreeDirectDraw()
{
    VideoOn=FALSE;
    RestorePalette();
    if (g_pDD != NULL)
    {
        if (g_pDDSBack != NULL)
        {
            IDirectDrawSurface_Release(g_pDDSBack);
            g_pDDSBack = NULL;
        }
        if (g_pDDSPrimary != NULL)
        {
            IDirectDrawSurface_Release(g_pDDSPrimary);
            g_pDDSPrimary = NULL;
        }
        if (g_pDDPal != NULL)
        {
            IDirectDrawPalette_Release(g_pDDPal);
            g_pDDPal = NULL;
        }
        IDirectDraw_Release(g_pDD);
        g_pDD = NULL;
    }
    // Clean up the screen on exit
    RedrawWindow(NULL,NULL,NULL, RDW_INVALIDATE | RDW_ERASE | RDW_ALLCHILDREN);
    return DD_OK;
}

void __cdecl RestorePalette()
{
  if (g_pDDPal != NULL)
  {
//    ZeroMem(_0a0000h,VideoModeX*VideoModeY);
    IDirectDrawPalette_SetEntries(g_pDDPal,0, 0,256,oldpe); //org, len, pe);
  }
}

void __cdecl DDrawLock()
{
  DDSURFACEDESC2              ddsd;
  HRESULT                     res;
  if ((g_pDDSPrimary!=NULL) & (GraphicsMode!=0))
  {
    ZeroMem(&ddsd, sizeof(ddsd));
    ddsd.dwSize = sizeof(ddsd);
    res=DDERR_WASSTILLDRAWING;
    while (res==DDERR_WASSTILLDRAWING)
    {
      res=IDirectDrawSurface_Lock(g_pDDSPrimary,NULL, &ddsd, 0, NULL);
      if (res==DDERR_SURFACELOST)
      {  // Should Never Happen, has been done by SetAcquireDraw
//        IDirectDrawSurface_Restore(g_pDDSPrimary);
//        res=DDERR_WASSTILLDRAWING;
      }
      else
        {
        _0a0000h=ddsd.lpSurface;
        direct_x_pitch=ddsd.lPitch;
        }
    }
  }

}

void __cdecl DDrawUnLock()
{
  if (g_pDDSPrimary!=NULL)
    IDirectDrawSurface_Unlock(g_pDDSPrimary,NULL);
}

void __cdecl Wait_Synchro()
{
static DWORD  OldTime=0;
//BOOL        ScanLine;

  if (( g_pDD != NULL ) && (VideoOn==TRUE))
  {
    if (WaitEnd==TRUE)
    {
      // Wait The BlockEnd only if Palette Change
      IDirectDraw_WaitForVerticalBlank(g_pDD,DDWAITVB_BLOCKEND,NULL);
//      ScanLine=FALSE;
//      while (ScanLine==FALSE)
//        IDirectDraw_GetVerticalBlankStatus(g_pDD,&ScanLine);
    }
    else
      IDirectDraw_WaitForVerticalBlank(g_pDD,DDWAITVB_BLOCKBEGIN,NULL);
    while ((timeGetTime()-OldTime)<Timer_Value) ;
      OldTime=timeGetTime();
  }
  WaitEnd=FALSE;
}

void __cdecl Set_Palette(long org,long len,char *palette)
{
  long  i,j;

  if (g_pDDPal!=NULL)
  {
    len=len/3;
    for (i=0,j=0;i<len;i++,j+=3)
    {
      pe[i+org].peRed   =palette[j]<<2;
      pe[i+org].peGreen =palette[j+1]<<2;
      pe[i+org].peBlue  =palette[j+2]<<2;
    }
 //   WaitEnd=TRUE;
    DDrawUnLock();
    IDirectDrawPalette_SetEntries(g_pDDPal,0,org, len, &pe[org]);
//    IDirectDrawPalette_SetEntries(g_pDDPal,0,0, 256, pe);
    DDrawLock();
  }
}

void __cdecl Get_Palette(char *palette)
{
  long  i,j;
  unsigned char *dest=(unsigned char *)palette;

  if (g_pDDPal!=NULL)
  {
    DDrawUnLock();
    IDirectDrawPalette_GetEntries(g_pDDPal,0,0,256, pe);
    DDrawLock();
    for (i=0,j=0;i<256;i++,j+=3)
    {
      dest[j]  = pe[i].peRed   >>2;
      dest[j+1]= pe[i].peGreen >>2;
      dest[j+2]= pe[i].peBlue  >>2;
    }
  }
}

LPDIRECTDRAWSURFACE4 __cdecl CreateCompatibleSurface(void *ptr,long x,long y,long bpp)
{
    LPDIRECTDRAWSURFACE4 g_pDDSurf  = NULL;
    DDSURFACEDESC2              ddsd;

    long  size;

    if (ptr==NULL)
      return NULL;

    ZeroMem(&ddsd, sizeof(ddsd));
    ddsd.dwSize = sizeof(ddsd);
    ddsd.dwFlags = DDSD_HEIGHT| DDSD_WIDTH|DDSD_CAPS | DDSD_LINEARSIZE | DDSD_PITCH | DDSD_LPSURFACE | DDSD_PIXELFORMAT;
    ddsd.ddsCaps.dwCaps = DDSCAPS_SYSTEMMEMORY ;
    switch (bpp)
    {
      case 8:
        size=x*y;
        break;
      case 15:
        size=x*y*2;
        break;
      case 16:
        size=x*y*2;
        break;
      case 32:
        size=x*y*4;
        break;
    }
    ddsd.lpSurface=ptr;
    ddsd.lPitch=x;
    ddsd.dwWidth=x;
    ddsd.dwHeight=y;
    ddsd.ddpfPixelFormat.dwSize=sizeof(DDPIXELFORMAT);
    IDirectDrawSurface_GetPixelFormat(g_pDDSPrimary,&ddsd.ddpfPixelFormat);

    if (IDirectDraw_CreateSurface(g_pDD,&ddsd, &g_pDDSurf, NULL)!=DD_OK)
    {
      GlobalFree(ddsd.lpSurface);
      return NULL;
    }
    return g_pDDSurf;
}

void __cdecl FlipToScreen(LPDIRECTDRAWSURFACE4 src,long x,long y,long sizex,long sizey)
{
    RECT                        Rect;
    HRESULT hr;
    char    msg_error[256];

    Rect.left=x;
    Rect.top=y;
    Rect.right=x+sizex;
    Rect.bottom=y+sizey;
    DDrawUnLock();
    hr=IDirectDrawSurface_BltFast(g_pDDSPrimary,0,0,src,&Rect,DDBLTFAST_NOCOLORKEY);
    if (hr!=DD_OK )
    {
      wsprintf (msg_error,"Unable to BltFast : %x %s",hr,getErrorString(hr));
      exit_error (msg_error);
    }
    DDrawLock();
}