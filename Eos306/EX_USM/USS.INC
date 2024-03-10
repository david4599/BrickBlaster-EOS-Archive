;            ษอออออออออออออออออออออออออออออออออออออออออออออออออออป
;            บ     ๗๗๗๗๗๗๗๗๗๗๗๗๗๗ USS.INC ๗๗๗๗๗๗๗๗๗๗๗๗๗๗         บ
;            บ                                                   บ
;            บ              Useless Sound System V1.0            บ
;            บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบ
;            บ   By Freddy Vtel (FreddyV/Useless)              บ
;            บ                                                   บ
;            บ   Code starts .................. 04/08/1996       บ
;            บ   Last Update .................. 28/03/1997       บ
;            ศอออออออออออออออออออออออออออออออออออออออออออออออออออผ

if _WATCOM
Global USS_Setup_          :Near
Global USS_AutoSetup_      :Near
else
Global USS_Setup           :Near
Global USS_AutoSetup       :Near
endif

Global USS_StartOutput     :Near
Global USS_StopOutput      :Near
Global USS_UpdateOutput    :Near

Global USS_LoadSample      :Near
Global USS_FreeSample      :Near
Global USS_GetGlobalVolume :Near
Global USS_SetGlobalVolume :Near
Global USS_StartInstrument :Near
Global USS_InitInstrEnv    :Near
Global USS_GetInstrument   :Near
Global USS_GetSample       :Near
Global USS_SetSampleOffset :Near
Global USS_SetNote         :Near
Global USS_GetPeriod       :Near
Global USS_SetPeriod       :Near
Global USS_GetVolume       :Near
Global USS_SetVolume       :Near
Global USS_GetPanning      :Near
Global USS_SetPanning      :Near
Global USS_KeyOff          :Near
Global USS_UpdateInstr     :Near

; ** Some usefull functions for the player **

Global Get_NotePeriod      :Near
Global GetVibData          :Near

; USS.INC (c) 1997 FreddyV/Useless
