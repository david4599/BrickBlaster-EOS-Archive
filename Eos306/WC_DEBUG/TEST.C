//ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ                                                                          บ
//บ This example show how to use EOS Debugger with Watcom C                  บ
//บ                                                                          บ
//บ                                                                          บ
//บ                                                                          บ
//ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

#include <process.h>
#include <stdlib.h>
#include "..\resource\eos.h"

void main()
{
  init_eos(_psp);
  debug();
  addlog(_String,_Log_String,"eax+eax");
  addlog(_Address,_Log_String,"Hello World");
  printf("    þ Hello world...\x0D\x0A");
  exit(0);
}