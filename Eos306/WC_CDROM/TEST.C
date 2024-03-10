//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ                                                                          บ
//บ This example show how to use CDROM library.                              บ
//บ                                                                          บ
//บ                                                                          บ
//บ                                                                          บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

#include <process.h>
#include <stdlib.h>
#include <bios.h>
#include "..\resource\eos.h"

void main(int argn, char **argv)
{
   init_eos(_psp);

   if (detect_cdrom()==1)
    exit_error ("    þ CDROM or MSCDEX not found !\x0d\x0a\x24");

   play_track(1,1);    // play all tracks...

   printf("    þ Playing all tracks...\x0D\x0A");

  exit (0);
}