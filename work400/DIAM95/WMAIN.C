#include <windows.h>
#include <mmsystem.h>
#include <ddraw.h>
#include <diam95.h>
#include <resource.h>
void* __cdecl LS_LoadModule (UBYTE *filename);
UBYTE* __cdecl LS_LoadFile (UBYTE *filename);

#define NAME        "Diamond 95"
#define TITLE       "Diamond 95"

  BOOL                    g_bActive = FALSE;
  HWND                    MainhWnd;
  HANDLE                  hInst;
  void                    *mod3;

void RequestLoadMod()
{
  OPENFILENAME            ofn;
  BOOL                    result;
  char                    szFileBuffer[MAX_PATH];
  char                    szFileTitle[MAX_PATH];

  szFileBuffer[0]='\0';
  memset( &ofn, 0, sizeof(OPENFILENAME));
  ofn.lStructSize = sizeof(OPENFILENAME);
  ofn.hwndOwner = MainhWnd;
  ofn.lpstrFilter = "Modules\0*.mod\0\0";
  ofn.nFilterIndex  = 1;
  ofn.lpstrFile = szFileBuffer;
  ofn.nMaxFile  = sizeof(szFileBuffer);
  ofn.lpstrFileTitle  = szFileTitle;
  ofn.nMaxFileTitle = sizeof(szFileTitle);
  ofn.lpstrInitialDir = NULL;
  ofn.lpstrDefExt = "mod\0\0";
  ofn.lpstrTitle  = "Load Module File...";
  ofn.Flags   = OFN_HIDEREADONLY;
  if ((result=GetOpenFileName(&ofn))==TRUE)
  {

    LSYS_StopModule(0);
//    Sleep(100);
    LSYS_ReleaseModule(mod3);
    mod3=LS_LoadModule(ofn.lpstrFileTitle);
    LSYS_PlayModule(mod3);
  }
}

// *********************************************************************
// La procédure d'évenement
// *********************************************************************

long FAR PASCAL WindowProc( HWND hWnd, UINT message,
							WPARAM wParam, LPARAM lParam )
{
	switch( message )
	{
		case WM_ACTIVATEAPP:
        g_bActive = wParam;
        break;

    case WM_DESTROY:
        PostQuitMessage( 0 );
        break;
    case WM_COMMAND:
      switch( ( wParam ))
      {
        case ID_FILE_OPEN:
          RequestLoadMod();
          break;
        case ID_FILE_QUIT:
          PostMessage(hWnd,WM_DESTROY,0,0);
          break;
      }
    case WM_TIMER:
      Update_Diamond(1);
      Update_Diamond(1);
      Update_Diamond(1);
      break;
  }
  return DefWindowProc(hWnd, message, wParam, lParam);

} /* WindowProc */


// *********************************************************************
// *********************************************************************

static BOOL WIN_InitInstance( HANDLE hInstance, int nCmdShow )
{
	WNDCLASS            wc;

   /*
    * set up and register window class
    */
  wc.style = CS_HREDRAW | CS_VREDRAW;
	wc.lpfnWndProc = WindowProc;
	wc.cbClsExtra = 0;
	wc.cbWndExtra = 0;
	wc.hInstance = hInstance;
	wc.hIcon = LoadIcon( hInstance, IDI_APPLICATION );
  wc.hCursor = LoadCursor( NULL, IDC_ARROW );
	wc.hbrBackground = GetStockObject(BLACK_BRUSH);
  wc.lpszMenuName = (LPSTR)MAKEINTRESOURCE(IDR_MENU1);
  wc.lpszClassName = NAME;
	RegisterClass( &wc );

	hInst = hInstance;
  MainhWnd = CreateWindowEx(0,NAME,TITLE,
        WS_OVERLAPPEDWINDOW+WS_CAPTION,
//        WS_OVERLAPPED+WS_THICKFRAME+WS_SYSMENU+WS_MAXIMIZE+WS_CAPTION+WS_MINIMIZEBOX+WS_MAXIMIZEBOX+WS_POPUP,
        0,0,640,480,
        NULL,NULL,hInstance,NULL);

	if( !MainhWnd )
    return FALSE;

	ShowWindow( MainhWnd, nCmdShow );
	UpdateWindow( MainhWnd );
  SetTimer( MainhWnd, 0, 1000/50, NULL );

  return TRUE;

} /* WIN_InitInstance */


// *********************************************************************
// Le Main Window
// *********************************************************************

/*int PASCAL WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
                    LPSTR lpCmdLine, int nCmdShow )
 */
BOOL main()
{
  char  *ptr;
/*  MSG                     msg;

  if( !WIN_InitInstance( hInstance, nCmdShow ) )
    return FALSE;
*/
  if (InitDirectSound(NULL,GetForegroundWindow())!=DS_OK)
    return FALSE;

  LSYS_Set_Real_Stereo(FALSE);
  mod3=LS_LoadModule("TEST.MOD");
  LSYS_PlayModule(mod3);
  LSYS_ResumeModule();
  ptr=LS_LoadFile("test3.iff");
  Load_External_Sample(ptr);


    while ( !kbhit() )
    {
      Update_Diamond(1);
    }
    getch();

/*    while (GetMessage(&msg, NULL, 0, 0))
    {
      TranslateMessage(&msg);
      DispatchMessage(&msg);
    }
*/
    LSYS_StopModule(0);
    Sleep(100);
    LSYS_ReleaseModule(mod3);

	// Close DirectSound
  FreeDirectSound();

  return TRUE;
} /* WinMain */

LONG __cdecl LS_GetFileSize (UBYTE *filename)
{
  FILE                    *fd;
  LONG                    size;

	if ((fd = fopen (filename,"rb"))==NULL)
		return 0L;

	fseek (fd,0,SEEK_END);                // Lecture du modules
	size = ftell (fd);
	fseek (fd,0,SEEK_SET);
	fclose (fd);
  return (size+4096);                   // on ajoute 4096 octects pour sauver
}                                       // les datas pour les mods


UBYTE* __cdecl LS_LoadFile (UBYTE *filename)
{
  LONG                    size;
  FILE                    *fd;
  UBYTE                   *ptr;

	size = LS_GetFileSize(filename);
	if ((fd = fopen (filename,"rb"))==NULL)
		return NULL;

  ptr = GlobalAlloc(GMEM_FIXED,(size));
	fread (ptr,size,1,fd);
	fclose (fd);
	return ptr;
}

// **********************************************************************
// **********************************************************************

void* __cdecl LS_LoadModule (UBYTE *filename)
{
  void                  *mod;
  long                  Size;
  void                  *Start;

  Size = LS_GetFileSize(filename);
  Start = LS_LoadFile(filename);
  LSYS_InitModule (Start,Size,0);
  return Start;
}