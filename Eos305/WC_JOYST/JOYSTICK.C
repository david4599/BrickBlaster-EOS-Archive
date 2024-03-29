//浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
//�                                                                          �
//� This example show how to use JOYSTICK library.                           �
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
   joy_t *addr_joystick;

   init_eos(_psp);

   if (detect_joystick()==ANALOG_A)
   {
    printf("    � Joystick detected\x0D\x0A");
    addr_joystick=add_joystick(ANALOG_A,0);

    printf("    � Move joystick to UPPER LEFT and press FIRE\x0D\x0A");
    while (!upper_left(addr_joystick) & !kbhit() ){}
    while ( joy1.j_fire_1 & !kbhit() )
    {
      update_joystick();
    }

    printf("    � Move joystick to LOWER RIGHT and press FIRE\x0D\x0A");
    while (!lower_right(addr_joystick)& !kbhit() ){}
    while ( joy1.j_fire_1 & !kbhit() )
    {
      update_joystick();
    }

    printf("    � Move joystick to CENTER and press FIRE\x0D\x0A");
    while (!center(addr_joystick)& !kbhit() ){}
    while ( joy1.j_fire_1 & !kbhit() )
    {
      update_joystick();
    }

    printf("    � Press Fire_1 to quit\x0D\x0A");
    while ( !joy1.j_fire_1 & !kbhit() )
    {
      printf ("    � Left: %i Right: %i Up: %i Down: %i Fire_2: %i\r",joy1.j_current_left,joy1.j_current_right,joy1.j_current_up,joy1.j_current_down,joy1.j_fire_2);
      update_joystick();
    }

   };

  exit (0);
}