//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ                                                                          บ
//บ This example show how to use WEOS, WEOSLITE, WDEBUG and DOS4GW           บ
//บ                                                                          บ
//บ                                                                          บ
//บ                                                                          บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

#include <process.h>
#include <stdlib.h>
#include <bios.h>
#include "..\resource\eos.h"

void main()
{
  printf("    þ Hello world...\x0D\x0A");
  _bios_keybrd(_KEYBRD_READ);
  exit(0);
}