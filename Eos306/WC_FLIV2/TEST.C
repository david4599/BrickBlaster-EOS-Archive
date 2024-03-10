//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ                                                                          บ
//บ this example show how to use fli32 library with linear frame buffer      บ
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
   char *addr_buffer;

    init_eos(_psp);

    addr_buffer=init_vesa2(0x101,640*480);
    fli_selector=allocate_selector(addr_buffer,0x0ffff);

    if (load_fli("..\\data\\test.flc")==NULL)
       exit_error ("    þ File not found !\x0d\x0a\x24");

    if (addr_buffer==NULL)
       exit_error ("    þ Mode SVGA not supported or vesa not found ! \x0d\x0a" \
                   "      To install a vesa driver, refer to your video card documentation. \x0d\x0a\x24");

    fli_scr_x=640;
    fli_scr_y=480;
    fli_ligne_shl=7;
    fli_svga=OFF;               // off = vga ou vesa2    on = vesa1
    fli_decal_x=(640/2)-160;
    fli_decal_y=(480/2)-100;

    first_frame_fli();
    while ( !kbhit() )
    {
      wait_vbl();
      next_frame_fli();
    }
    _bios_keybrd(_KEYBRD_READ);

    dispose_fli();

  exit (0);
}