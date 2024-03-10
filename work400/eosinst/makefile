PRG     = eosinst
ULIB    = .\lib
UINC    = .

CDEP    =
CFLAGS  = -D_X86_=1 -D_WIN32 -DWIN32 -DWINVER=0x0400 /I=$(UINC) -5r -fp5 -ox -d0
RFLAGS  = -D_X86_=1 -D_WIN32 -DWIN32 -DWINVER=0x0400 /I $(UINC)

LLIBS   = DDRAW.LIB DINPUT.LIB


all : $(PRG).exe

$(PRG).exe: $(PRG).obj $(PRG).res getdxver.obj
        link -subsystem:windows -out:$(PRG).exe  \
        $(PRG).obj $(PRG).res getdxver.obj ddraw.lib  dxguid.lib


.rc.res:
        rc $(RFLAGS) $*.rc
.c.obj:
        wcc386 $(CFLAGS) -zw $*.c
.cpp.obj:
        wcc386 $(CFLAGS) -zw $*.cpp
.asm.obj:
        tasm $*.asm /ml /m /p /q /i$(UINC) /DWIN32=1

$(PRG).obj: $(PRG).c $(CDEP)