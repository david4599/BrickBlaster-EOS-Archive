#include <windows.h>
#include <resource.h>

void __cdecl GetDXVersion(LPDWORD pdwDXVersion, LPDWORD pdwDXPlatform);

#define NAME        "WinEOS Installation"
#define TITLE       "WinEOS Installation"
#define PIC_X       620
#define PIC_Y       460

static  BOOL                    g_bActive = FALSE;
static  HWND                    MainhWnd,MainhWnd2;
static  HANDLE                  hInst;
static  DWORD                   DirectX=0x600;
static  char                    RunEXE[MAX_PATH];
static  char                    DocEXE[MAX_PATH];
static  char                    InstallEXE[MAX_PATH];
static  char                    DirectXEXE[MAX_PATH];
static  char                    BonusEXE[MAX_PATH];
static  char                    FULLPATH[MAX_PATH];
static  char                    INIPATH[MAX_PATH];
static  char                    REGNAME[MAX_PATH];



BOOL execprg(char *prg)
{
  STARTUPINFO StartupInfo;
  PROCESS_INFORMATION ProcessInformation;
  char  tmp[256],*tmp2;
  char  path[256];
  long  i;

  memset (&ProcessInformation,0,sizeof(PROCESS_INFORMATION));
  memset (&StartupInfo,0,sizeof(STARTUPINFO));
  StartupInfo.cb=sizeof(STARTUPINFO);
  StartupInfo.dwFlags=STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow=SW_SHOW;

  path[0]=0;
  if (GetFullPathName(prg,256,tmp,&tmp2)==0)
    lstrcpy (tmp,prg);
  else
  {
    lstrcpyn (path,tmp,tmp2-tmp);
  }

  SetEnvironmentVariable("CMDLINE",tmp);
  if (CreateProcess(NULL,tmp,NULL,NULL,FALSE,0,NULL,path,&StartupInfo,&ProcessInformation)==FALSE)
  {
    wsprintf (tmp,"Le programme %s n'a pu etre execute",prg);
    MessageBox(MainhWnd,tmp,NAME,MB_OK | MB_ICONEXCLAMATION);
  }
  return FALSE;
}


void CheckDirectX()
{
  DWORD DXVersion,DXPlatform;
  long  res;
  char  tmp[256];

  GetDXVersion(&DXVersion,&DXPlatform);
  if (DXVersion<DirectX)
  {
    wsprintf (tmp,"This Program need Direct X %X.%X or Better to run\n"
                  "   Would you like to install Direct X %X.%X ",DirectX>>8,DirectX & 0xff,DirectX>>8,DirectX & 0xff);

    res=MessageBox (NULL,tmp,NAME,MB_YESNO);
    if (res==IDYES)
      execprg(DirectXEXE);
  }
}

// *********************************************************************
// La procédure d'évenement
// *********************************************************************

long FAR PASCAL WindowProc( HWND hWnd, UINT message,WPARAM wParam, LPARAM lParam )
{
	switch( message )
	{
    case WM_INITDIALOG:
        return (TRUE);
        break;

    case WM_ACTIVATEAPP:
        g_bActive = wParam;
        break;

    case WM_COMMAND:
      switch( ( wParam ))
      {
        case IDRUN:
          execprg(RunEXE);
          break;

        case IDDOC:
          execprg(DocEXE);
          break;

        case IDINSTALL:
          execprg(InstallEXE);
          break;

        case IDDIRECTX:
          execprg(DirectXEXE);
          break;

        case IDBONUS:
          execprg(BonusEXE);
          break;

        case IDQUIT:
          DestroyWindow( hWnd );
          break;
      }
      break;
    case WM_DESTROY:
        PostQuitMessage( 0 );
        break;
  }
  return DefWindowProc(hWnd, message, wParam, lParam);

} /* WindowProc */

// *********************************************************************
// *********************************************************************

static BOOL WIN_InitInstance( HANDLE hInstance, int nCmdShow )
{
/*
	hInst = hInstance;
	hwnd = CreateDialog(hInstance, "SoundApp", 0, NULL);
	CreateDialog(hInstance, "ID_SOUNDAPP_ABOUT", hwnd, NULL);
	ShowWindow (hwnd, nCmdShow);
*/


  WNDCLASS            wc;
  wc.style          = CS_HREDRAW | CS_VREDRAW;
  wc.lpfnWndProc    = WindowProc;
  wc.cbClsExtra     = 0;
  wc.cbWndExtra     = DLGWINDOWEXTRA;
  wc.hInstance      = hInstance;
  wc.hIcon          = LoadIcon( hInstance, IDI_APPLICATION );
  wc.hCursor        = LoadCursor( NULL, IDC_ARROW );
  wc.hbrBackground  = GetStockObject(BLACK_BRUSH);
  wc.lpszMenuName   = NULL;
  wc.lpszClassName  = "WinEOS Installation";
	RegisterClass( &wc );

	hInst = hInstance;

  MainhWnd=CreateDialog(hInstance,MAKEINTRESOURCE(IDD_DIALOG1),0,NULL);
  SetWindowText(MainhWnd,NAME);

  MoveWindow(MainhWnd,
      GetSystemMetrics(SM_CXSCREEN)/2-PIC_X/2,
      GetSystemMetrics(SM_CYSCREEN)/2-PIC_Y/2,
      PIC_X,PIC_Y,TRUE);

  MoveWindow(GetDlgItem(MainhWnd,IDRUN)     ,497,120,98,33,TRUE);
  MoveWindow(GetDlgItem(MainhWnd,IDDOC)     ,497,180,98,33,TRUE);
  MoveWindow(GetDlgItem(MainhWnd,IDINSTALL) ,497,240,98,33,TRUE);
  MoveWindow(GetDlgItem(MainhWnd,IDDIRECTX) ,497,300,98,33,TRUE);
  MoveWindow(GetDlgItem(MainhWnd,IDQUIT)    ,497,360,98,33,TRUE);
  MoveWindow(GetDlgItem(MainhWnd,IDBONUS)   ,40,360,98,33,TRUE);

  ShowWindow( MainhWnd, SW_SHOW);


  return TRUE;

} /* WIN_InitInstance */


// *********************************************************************
// Le Main Window
// *********************************************************************

int PASCAL WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,LPSTR lpCmdLine, int nCmdShow)
{
  MSG                     msg;
  char                    res[256],tmp[256],end;
  long                    i,j;
  DWORD                   size;
  HKEY                    hk;


  lpCmdLine=GetCommandLine();
  i=0;
  j=0;
  end=0;
  if (lpCmdLine[i]=='"')
  {
    i++;
    end='"';
  }
  while (lpCmdLine[i]!=end)
    FULLPATH[j++]=lpCmdLine[i++];

  lstrcpy (INIPATH,FULLPATH);

  while (INIPATH[j]!='\\')
    j--;
  lstrcpy (&INIPATH[j+1],"EOSINST.INI");


  GetPrivateProfileString("WinEOS","DirectX","300",res,256,INIPATH);
  sscanf(res,"%X",&DirectX);
  GetPrivateProfileString("WinEOS","RunEXE","",RunEXE,256,INIPATH);
  GetPrivateProfileString("WinEOS","DocEXE","",DocEXE,256,INIPATH);
  GetPrivateProfileString("WinEOS","InstallEXE","",InstallEXE,256,INIPATH);
  GetPrivateProfileString("WinEOS","DirectXEXE","",DirectXEXE,256,INIPATH);
  GetPrivateProfileString("WinEOS","BonusEXE","",BonusEXE,256,INIPATH);
  GetPrivateProfileString("WinEOS","Name","",REGNAME,256,INIPATH);
  size=MAX_PATH;
  wsprintf (tmp,"software\\wineos\\%s",REGNAME);
  RegOpenKeyEx(HKEY_LOCAL_MACHINE, tmp, 0, KEY_READ, &hk);
  RegQueryValueEx(hk,"name",NULL,NULL,RunEXE,&size);
  RegCloseKey(hk);

  CheckDirectX();

  if( !WIN_InitInstance( hInstance, nCmdShow ) )
    return FALSE;


    while (GetMessage(&msg, NULL, 0, 0))
    {
      TranslateMessage(&msg);
      DispatchMessage(&msg);
    }

  DestroyWindow(MainhWnd);
  return TRUE;
} /* WinMain */