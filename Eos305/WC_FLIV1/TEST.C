//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ                                                                          บ
//บ This example show how to use FLI32 library with Automatic bank Switching บ
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

    fli_selector=init_vesa_bank();

    if (load_fli("..\\data\\test.flc")==NULL)
       exit_error ("    þ File not found !\x0d\x0a\x24");

    if (init_vesa(0x101)==NULL)
       exit_error ("    þ Mode SVGA not supported or vesa not found ! \x0d\x0a" \
                   "      To install a vesa driver, refer to your video card documentation. \x0d\x0a\x24");

    fli_scr_x=640;
    fli_scr_y=480;
    fli_ligne_shl=7;
    fli_svga=ON;
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