;            ษอออออออออออออออออออออออออออออออออออออออออออออออออออป
;            บ       ๗๗๗๗๗๗๗๗๗๗๗๗๗๗ SETUP.INC ๗๗๗๗๗๗๗๗๗๗๗๗๗๗     บ
;            บ                                                   บ
;            บ       Useless sound system compilation setup.     บ
;            บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบ
;            บ   By Freddy Vtel (FreddyV/Useless)              บ
;            บ                                                   บ
;            บ   Code starts .................. 25/10/1996       บ
;            บ   Last update .................. 30/03/1996       บ
;            ศอออออออออออออออออออออออออออออออออออออออออออออออออออผ

Yes Equ 1
No  Equ 0

;----------------------------- Sound drivers ---------------------------------

UseGUS   Equ Yes  ; Include GUS driver ?
UseSB    Equ Yes  ; Include Sound Blaster driver ?
UseHP    Equ Yes  ; Include PC Speaker driver ?
UseNoSnd Equ Yes  ; Include No Sound driver ?

;-------------------------------- Setup --------------------------------------
;
; Setup function needs MEMORY.ASM to run and is bigger than Autosetup function.
; If you use the sound system for a GUS only intro, use only AutoSetup.

UseSetup Equ Yes
UseAutoSetup Equ Yes

;------------------------------- Mixing --------------------------------------
;
; Default Amplification is a very important variable for the mixing
; routines as there is no sound clipping in useless player mixing routines
;
; It define how mutch channels can be mix together (if the samples are
; at full volume)
; a value of 256 is for One 'Full' volume channel
; With 2*256, it can mix 2 channels, ....
; The Lower is DefAmpli, the louder is the sound.
;
; You must try by yourself (In Mono AND Stereo Mode) to get the best sound
; quality.

;DefAmpli EQU 256*2    ; It's good for 4/6 channels files
;DefAmpli EQU 256*3    ; 8 Channels files
DefAmpli EQU 256*5
;DefAmpli EQU 256*8    ; If you play a 24 channels file like DOPE.MOD

FastStereoOversampling EQU Yes ; No, Slow Stereo oversampling (16 bit)
                               ; Yes, Fast Stereo oversampling (8 bit)

;------------------------------- Loaders -------------------------------------
;
; USMP_FreeModule function can only free the files loaded by the externals
; files loaders (USMLoad, MODLoad, XMLoad...)
; When you don't use external loaders, you must set UseFreeModule to No


UseFreeModule Equ Yes ; Use FreeModule function ?

;------------------------------- Timer ---------------------------------------
; Number of timer you can use.
; (If you use the GUS or PC speaker drivers, you must add 1 to max_timers)

max_timers  EQU 3
timer_error EQU 1 ; 1, timer errors stop the program (No Error number return)
                  ; You must include ERROR.ASM when this is on
                  ; So It should be 0 in intros.

;------------------------------- Memory --------------------------------------
;
;   When you use EOS and DOS32, the player allocates its own heap
; The player heap size is (free memory-NeededMem).
; NeededMem value will depends on which DOS extender you use.
;
;For DOS32:
;   NeededMem is the total amount of memory you allocate with the DOS32
; memory allocation functions.
;   If you use the useless memory functions, you can put NeededMem to 0
;
;For EOS:
;   As EOS internally allocates memory for the LoadInternalFile and debugger,
; NeededMem is the memory you will allocate with the EOS memory functions +
; internal EOS memory allocations.
;   As you can see, it's more difficult with EOS because the memory is
; shared between the player, EOS internal needs and EOS memory functions,
; you will have to try different values to find the optimal one.
;
; BTW: EOS load_internal_file error is file not found instead of out of memory

NeededMem Equ 32*1024
