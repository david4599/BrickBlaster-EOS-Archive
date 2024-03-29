//浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
//�                                                                          �
//� This example show how to use Diamond Player with Watcom C                �
//�                                                                          �
//�                                                                          �
//�                                                                          �
//藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <process.h>
#include <bios.h>
#include "..\resource\eos.h"

void main(int argn, char **argv)
{
   int  card=0,port=1,irq=2,dma=3,infos=4;
   unsigned char  position=1,pattern=2,note=3,volume=4,sfx_volume=5;


   init_eos(_psp);

   card=detect_sound_card  (1,&port,&irq,&dma,&infos);
   printf ("    � Card : %x Port : %x   Irq : %i   Dma : %i \n",card,port,irq,dma);

   load_module ("..\\data\\test.mod",0,44100,0);
   play_module();

   change_synchro_int_08(70);

   while ( !kbhit() )
   {
      get_info(&position,&pattern,&note,&volume,&sfx_volume);
      printf ("    � Position : %i Pattern : %i Note : %i Volume : %i  vbl : %i    \r",position,pattern,note,volume,wait_vbl());
   }
   _bios_keybrd(_KEYBRD_READ);
   printf ("\n");

   stop_module();
   clear_module();

   exit (0);
}