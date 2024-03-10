//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ                                                                          บ
//บ This example show how to use the Linear FrameBuffer with Vesa 2.0        บ
//บ                                                                          บ
//บ                                                                          บ
//บ                                                                          บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

#include <process.h>
#include <stdlib.h>
#include <bios.h>
#include "..\resource\eos.h"

void copyvideo(char *addr_buffer,char *addr_file);
#pragma aux copyvideo modify [eax edx esi edi] parm [edi] [esi] =  \
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
   "rep movsd";

void main(int argn, char **argv)
{
   char *addr_buffer;
   char *addr_file;
   long size_file;

    init_eos(_psp);

    addr_buffer=init_vesa2(0x101,640*480);
    if ( addr_buffer==NULL )
    exit_error ("    þ Mode SVGA not supported or vesa not found ! \x0d\x0a" \
                "      To install a vesa driver, refer to your video card documentation. \x0d\x0a\x24");

    addr_file=load_internal_file ("..\\data\\test640.dlz",&size_file);
    copyvideo(addr_buffer,addr_file);

    _bios_keybrd(_KEYBRD_READ);

    restore_video_mode();

  exit (0);
}