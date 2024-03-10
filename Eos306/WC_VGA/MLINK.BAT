@echo off
..\resource\unbind wc_vga
ren wc_vga.le linked.le
..\resource\diet linked.le
..\resource\llink wc_vga
del linked.le