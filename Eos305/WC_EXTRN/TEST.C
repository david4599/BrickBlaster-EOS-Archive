//浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
//�                                                                          �
//� This example show how to use WEOS, WEOSLITE, WDEBUG and DOS4GW           �
//�                                                                          �
//�                                                                          �
//�                                                                          �
//藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕

#include <process.h>
#include <stdlib.h>
#include <bios.h>
#include "..\resource\eos.h"

void main()
{
  printf("    � Hello world...\x0D\x0A");
  _bios_keybrd(_KEYBRD_READ);
  exit(0);
}