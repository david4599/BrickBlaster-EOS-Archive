@echo off
tasm ljoytest.asm
tlink ..\resource\eoslite.obj ..\resource\joystick.obj ljoytest.obj, ljoytest.exe /3
del ljoytest.map
del ljoytest.obj
