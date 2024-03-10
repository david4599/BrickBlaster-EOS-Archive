//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ                                                                          บ
//บ This example show how to use GIF library with Vesa 1.0                   บ
//บ                                                                          บ
//บ                                                                          บ
//บ                                                                          บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

#include <process.h>
#include <stdlib.h>
#include <bios.h>
#include "..\resource\eos.h"

void fade_down(char *addr_pic);
#pragma aux fade_down modify [eax ebx ecx edx esi edi] parm [esi] =  \
   "push esi"\
   "mov ecx,768"\
   "@@loop1:"\
   "sub byte ptr [esi],1"\
   "adc byte ptr [esi],0"\
   "inc esi"\
   "loop @@loop1"\
   "pop esi"\
   "mov dx,3c8h"\
   "xor al,al"\
   "out dx,al"\
   "mov ecx,768"\
   "inc dl"\
   "rep outsb";

void copyvideo(long selector_vesa,char *addr_file);
#pragma aux copyvideo modify [eax edx esi edi] parm [eax] [esi] =  \
   "push es"\
   "mov es,ax"\
   "xor edi,edi"\
   "mov ecx,76800"\
   "rep movsd"\
   "pop es";

void setpalette(char *addr_palette);
#pragma aux setpalette modify [eax edx esi edi] parm [esi] =  \
   "mov edx,3c8h"\
   "xor al,al"\
   "out dx,al"\
   "inc dl"\
   "mov ecx,768"\
   "rep outsb";

void main(int argn, char **argv)
{
   long selector_vesa;
   char *addr_file;
   int i;

   init_eos(_psp);

    if (init_vesa(0x101)==NULL)
    exit_error ("    þ Mode SVGA not supported or vesa not found ! \x0d\x0a" \
                "      To install a vesa driver, refer to your video card documentation. \x0d\x0a\x24");

   selector_vesa=init_vesa_bank();
   addr_file=load_external_gif_handle ("..\\data\\test640.gif");

   setpalette(gif_palette);
   copyvideo(selector_vesa,addr_file);

   _bios_keybrd(_KEYBRD_READ);

   for ( i=0; i!=63; i++ )
   {
     wait_vbl();
     fade_down(gif_palette);
   }

   restore_video_mode();

  exit (0);
}