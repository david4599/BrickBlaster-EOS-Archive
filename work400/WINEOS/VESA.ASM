
SDATA
VesaMode    struc
VesaModeNum dd 0
VesaModeX   dd 0
VesaModeY   dd 0
VesaModeBpp dd 0
            ends


Align 4
ListVesaMode  VesaMode < 3h,0,0,0>
              VesaMode <13h,320,200,8>
              VesaMode <Mode640x400x256  ,640 ,400 ,8 >
              VesaMode <Mode640x480x256  ,640 ,480 ,8 >
              VesaMode <Mode800x600x256  ,800 ,600 ,8 >
              VesaMode <Mode1024x768x256 ,1024,768 ,8 >
              VesaMode <Mode1280x1024x256,1280,1024,8 >
              VesaMode <Mode320x200x32k  ,320 ,200 ,15>
              VesaMode <Mode640x480x32k  ,640 ,480 ,15>
              VesaMode <Mode800x600x32k  ,800 ,600 ,15>
              VesaMode <Mode1024x768x32k ,1024,768 ,15>
              VesaMode <Mode1280x1024x32k,1280,1024,15>
              VesaMode <Mode320x200x64k  ,320 ,200 ,16>
              VesaMode <Mode640x480x64k  ,640 ,480 ,16>
              VesaMode <Mode800x600x64k  ,800 ,600 ,16>
              VesaMode <Mode1024x768x64k ,1024,768 ,16>
              VesaMode <Mode1280x1024x64k,1280,1024,16>
              VesaMode <Mode320x200x16M  ,320 ,200 ,32>
              VesaMode <Mode640x480x16M  ,640 ,480 ,32>
              VesaMode <Mode800x600x16M  ,800 ,600 ,32>
              VesaMode <Mode1024x768x16M ,1024,768 ,32>
              VesaMode <Mode1280x1024x16M,1280,1024,32>
              VesaMode <0,0,0,0>

CurrentMode   VesaMode <0,0,0,0>

SCODE
_Init_Vesa:
            and eax,0ffffh
            mov esi,O ListVesaMode
@@Loop:
            cmp [esi.VesaMode.VesaModeNum],0
            je @@ModeNotFound
            cmp eax,[esi.VesaMode.VesaModeNum]
            je @@FoundVesaMode
            add esi,Size VesaMode
            jmp @@Loop

@@FoundVesaMode:
            push esi
            CCALL SetMode,MainhWnd,[esi.VesaMode.VesaModeX],[esi.VesaMode.VesaModeY],[esi.VesaMode.VesaModeBpp]
            pop esi
            test eax,eax
            jne @@ModeNotFound
            mov edi,O CurrentMode
            mov ecx,(Size VesaMode) /4
            rep movsd
@@Exit_Ok:
            clc
            ret
@@ModeNotFound:
            stc
            ret

_Init_Vesa_Bank:
            mov ebx,ds
            clc
            ret

_Close_Vesa_Bank:
            clc
            ret

_Set_Bank:
            ret

