//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ                                                                          บ
//บ This example show how to use FLI32 library with Watcom C                 บ
//บ                                                                          บ
//บ                                                                          บ
//บ                                                                          บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

#include <process.h>
#include <stdlib.h>
#include "..\resource\eos.h"

char *set_video_mode(long video_mode);
#pragma aux set_video_mode parm [eax] modify [eax] value [eax] = \
  "int 10h" \
  "mov eax,0a0000h";

void main(int argn, char **argv)
{
    init_eos(_psp);

    fli_selector=allocate_selector(set_video_mode(0x13),0x0f);

    if (load_fli("..//data//test.flc")==NULL)
       exit_error ("    þ File not found !\x0d\x0a\x24");

      first_frame_fli();
      while ( !kbhit() )
      {
        wait_vbl();
        next_frame_fli();
      }
      dispose_fli();

  exit (0);
}