//浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
//�                                                                          �
//� This example show how to use CDROM library.                              �
//�                                                                          �
//�                                                                          �
//�                                                                          �
//藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕

#include <process.h>
#include <stdlib.h>
#include <bios.h>
#include "..\resource\eos.h"

void main(int argn, char **argv)
{
   init_eos(_psp);

   if (detect_cdrom()==1)
    exit_error ("    � CDROM or MSCDEX not found !\x0d\x0a\x24");

   play_track(1,1);    // play all tracks...

   printf("    � Playing all tracks...\x0D\x0A");

  exit (0);
}