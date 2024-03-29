//浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
//�                                                                          �
//� This example show how to use RS232 library with Watcom C                 �
//�                                                                          �
//�                                                                          �
//�                                                                          �
//藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕

#include <process.h>
#include <stdlib.h>
#include "..\resource\eos.h"

void print(char data);
#pragma aux print modify [eax edx] parm [edx] =  \
   "mov ah,2"\
   "int 21h";

main()
{
char ch;
int done=0;
  init_eos(_psp);

  printf("    � Null modem terminal communications program\n");

  serial_open(COM_2,SER_BAUD_115200,SER_PARITY_NONE | SER_BITS_8 | SER_STOP_1,4096);

  printf("    � Open...\n");
  serial_write_block("    � Remote machine Open...\x0d\x0a",30);

  while(!done)
     {

     if (kbhit())
        {
        ch = getch();
            print(ch);
            serial_write(ch);

        if (ch==27) done=1;

        if (ch==13)
            {
            print(10);
            serial_write(10);
            }

        } // end if kbhit

     if (ch = serial_read())
            print(ch);

     if (ch == 27)
        {
        printf("\n    � Remote machine closing connection");
        done=1;
        } // end if remote close

     }  // end while

  serial_close();

  printf("\n    � Closing connection\n");

  exit (0);

} // end main