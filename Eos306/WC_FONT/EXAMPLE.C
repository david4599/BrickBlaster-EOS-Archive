#include <stdlib.h>  /* _psp definition */
#include <conio.h>   /* getch */
#include "eos.h"
#include "font.h"

void mode13 (void);
#pragma aux mode13 = \
"pusha" \
"mov ax,13h" \
"int 10h" \
"popa";

int main (void)
{
   int index;
   int pos;

   init_eos(_psp);

   for (index=0;index<3;index++)
   {
      switch (index)
      {
         case 0:
            vesa_clear_palette = OFF;
            mode13();
            break;
         case 1:
            vesa_clear_palette = OFF;
            init_vesa(0x101);
            print_screen_size(640);
            break;
         case 2:
            vesa_clear_palette = OFF;
            print_vesa_memory (init_vesa2(0x103,1024*1024));
            print_vesa_version(2);
            print_screen_size(800);
            break;
      }

      print_color(1);
      print_goto_xy(0,0);
      print_text("Hello word");

      print_color(2);
      print_goto_xy(0,8);
      print_text("This is a C font drawer");

      print_goto_xy(0,16);
      print_text("All the sources are included");

      print_color(3);
      print_goto_xy(0,32);
      print_text("Enjoy the EOS ..");

      print_color(5);
      print_goto_xy(16,48);
      print_text("10 in decimal (3 digit) : ");
      print_dec(3,10);

      print_color(6);
      print_goto_xy(16,64);
      print_text("-10 in hexa (6 digit): ");
      print_hex(6,-10);

      print_color(7);
      print_goto_xy(0,170);
      for(pos=0; pos<320/8; pos++)
         print_char('0'+pos);

      print_color(8);
      print_goto_xy(250,180);
      print_text("Thomas");

      getch();
   }
   return -1;
}