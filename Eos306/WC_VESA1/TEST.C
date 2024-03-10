//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ                                                                          บ
//บ This example show how to use Automatic Bank Switching with Vesa 1.0      บ
//บ                                                                          บ
//บ                                                                          บ
//บ                                                                          บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

#include <process.h>
#include <stdlib.h>
#include <bios.h>
#include "..\resource\eos.h"

void copyvideo(long selector_vesa,char *addr_file);
#pragma aux copyvideo modify [eax edx esi edi] parm [eax] [esi] =  \
   "push es"\
   "mov es,ax"\
   "xor edi,edi"\
   "add esi,10"\
   "mov edx,3c8h"\
   "xor al,al"\
   "out dx,al"\
   "inc dl"\
   "mov ecx,768"\
   "@@ok1:"\
   "lodsb"\
   "out dx,al"\
   "loop @@ok1"\
   "mov ecx,76800"\
   "rep movsd"\
   "pop es";

void main(int argn, char **argv)
{
   selector_t selector_vesa;
   char *addr_file;
   long size_file,handle_file;

   init_eos(_psp);

    if (init_vesa(0x101)==NULL)
    exit_error ("    þ Mode SVGA not supported or vesa not found ! \x0d\x0a" \
                "      To install a vesa driver, refer to your video card documentation. \x0d\x0a\x24");

   selector_vesa=init_vesa_bank();
   addr_file=load_external_file_handle ("..\\data\\test640.dlz",&size_file,&handle_file);
   copyvideo(selector_vesa,addr_file);

   _bios_keybrd(_KEYBRD_READ);

   restore_video_mode();

  exit (0);
}