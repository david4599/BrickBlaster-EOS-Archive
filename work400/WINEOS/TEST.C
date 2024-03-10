
#include <direct.h>
#include <windows.h>
#include "..\resource\eos.h"
#include <wineos.h>

void __cdecl Start32()
{
  long        i;
  char *addr_file;
  long size_file,handle_file;
  LPDIRECTDRAWSURFACE4    pic;
  char msg_error[256];
  HRESULT hr;

  init_eos(0);
  use_int_09(ON);
  if ((hr=init_vesa(0x101))!=0)
  {
    wsprintf (msg_error,"Unable to Initialise Direct Draw : %x %s",hr,getErrorString(hr));
    exit_error(msg_error);
  }
  load_module ("..\\data\\test.mod",0,44100,2);
  play_module();
//  j=load_sample ("..\\diam95\\test3.iff",1);
  addr_file=load_external_file_handle ("..\\data\\test640.dlz",&size_file,&handle_file);
  pic=CreateCompatibleSurface(&addr_file[778],640,480,8);
  Set_Palette(0,768,&addr_file[10]);
  FlipToScreen(pic,0,0,639,479);
//  snap_iff();

//  play_sample(j+1,0x15f,0);
  for ( i=0;i<100;i++ )
  {
    wait_vbl();
  }
//  init_vesa(3);
//  exit_error("Test");
  for ( i=0;i<1000;i++ )
  {
    wait_vbl();
  }
}