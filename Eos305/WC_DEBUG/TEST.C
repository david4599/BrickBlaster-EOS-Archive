//浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様融
//�                                                                          �
//� This example show how to use EOS Debugger with Watcom C                  �
//�                                                                          �
//�                                                                          �
//�                                                                          �
//藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕

#include <process.h>
#include <stdlib.h>
#include "..\resource\eos.h"

void main()
{
  init_eos(_psp);
  debug();
  printf("    � Hello world...\x0D\x0A");
  exit(0);
}