;            ษอออออออออออออออออออออออออออออออออออออออออออออออออออป
;            บ    ๗๗๗๗๗๗๗๗๗๗๗๗๗๗ USMPLAY.INC ๗๗๗๗๗๗๗๗๗๗๗๗๗๗      บ
;            บ                                                   บ
;            บ              Useless Module Player                บ
;            บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบ
;            บ   By Freddy Vtel (FreddyV/Useless)              บ
;            บ                                                   บ
;            บ   Code starts .................. 09/08/1996       บ
;            บ   Last update .................. 25/10/1996       บ
;            ศอออออออออออออออออออออออออออออออออออออออออออออออออออผ

if _WATCOM
Global USMP_LoadInternalModule_ :Near
Global USMP_FreeModule_         :Near

Global USMP_StartPlay_          :Near
Global USMP_StopPlay_           :Near

Global USMP_PrevOrder_          :Near
Global USMP_NextOrder_          :Near
Global USMP_SetOrder_           :Near
else
Global USMP_LoadInternalModule :Near
Global USMP_FreeModule         :Near

Global USMP_StartPlay          :Near
Global USMP_StopPlay           :Near

Global USMP_PrevOrder          :Near
Global USMP_NextOrder          :Near
Global USMP_SetOrder           :Near
endif

Global _SynchroCount :DWORD
Global _SynchroVal   :BYTE
Global _MusicEnd     :BYTE
