@echo off
call diet -B blaster.exe
call diet -B blaster.cfg
call diet -B blaster.lv0
call diet -B blaster.lv1
call diet -B resource\*.mod
call diet -B resource\*.iff
call diet -B resource\*.flc
echo.
call llink complete.eos
echo.
copy media.gif pack\media.gif
copy blaster.flc pack\blaster.flc
copy blaster.lv0 pack\blaster.lv0
copy blaster.lv1 pack\blaster.lv1
copy sprite0.pal pack\sprite0.pal
copy sprite1.pal pack\sprite1.pal
copy blaster.cfg pack\blaster.cfg
dir pack\*.*
