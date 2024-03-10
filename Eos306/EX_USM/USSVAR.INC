;            ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;            º    ÷÷÷÷÷÷÷÷÷÷÷÷÷÷ USSVAR.INC ÷÷÷÷÷÷÷÷÷÷÷÷÷÷       º
;            º                                                   º
;            º         Useless Sound System 'Variables'          º
;            ºÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄº
;            º   By Freddy V‚tel‚ (FreddyV/Useless)              º
;            º                                                   º
;            º   Code starts .................. 03/08/1996       º
;            º   Last update .................. 03/01/1997       º
;            ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

; ** Devices var **

Global _DEV_Number      :WORD
Global _DEV_Name        :DWORD
Global _DEV_BasePort    :WORD
Global _DEV_IRQ         :BYTE
Global _DEV_DMA         :BYTE
Global _DEV_Freq        :WORD
Global _DEV_Mode        :WORD
Global _DEV_MaxChannels :WORD

; ** Devices Type Mask **

DM_8bit   EQU 1      ; 8 bit device
DM_16bit  EQU 2      ; 16 bit device
DM_Mono   EQU 4      ; Mono Device
DM_Stereo EQU 8      ; Stereo Device
DM_Signed EQU 16     ; Need a signed or an unsigned buffer (used in mix.asm)
DM_Interp EQU 32     ; 16 bit interpolation and 32 bit mixing...

DM_Mixed  EQU 256    ; Software mixed or hardware mixed device
DM_DRAM   EQU 512
DM_MIDI   EQU 1024   ; MIDI Device (Not used yet)
DM_FM     EQU 2048   ; FM Device (Adlib, Not used yet)

; ** Global var **

Global SSSampleOffsetT  :DWORD
Global SSInstrOffsetT   :DWORD
Global SSLinearPeriode  :BYTE 
Global SSInstrumentMode :BYTE
Global SSGlobalVol      :BYTE
Global SSActiveChannels :DWORD

; ** Channels var **

Global VChControl    :WORD

Global VChInsAdress  :DWORD
Global VChPeriod     :WORD
Global VChFreq       :DWORD
Global VChannelVol   :BYTE
Global VChVolume     :BYTE
Global VChFVolume    :BYTE
Global VChPanning    :BYTE
Global VChFPanning   :BYTE

Global VChSmpAdress  :DWORD
Global VChSmpOffset  :DWORD

Global VChFadeoutVol   :WORD

Global VChVolEnvPos    :WORD
Global VChVolEnvSegPos :WORD
Global VChEnvVol       :BYTE

Global VChPanEnvPos    :WORD
Global VChPanEnvSegPos :WORD
Global VChEnvPan       :BYTE

Global VChAVibPos      :BYTE
Global VChAVibSwpPos   :BYTE
Global VChAVibPitch    :WORD

Global Period_Table :WORD

; ** Channel Control masques **

CC_Playing   EQU 1
CC_StopVoice EQU 2
CC_FadeVol   EQU 4

CC_ChSample  EQU 16
CC_ChPeriod  EQU 32
CC_ChVolume  EQU 64
CC_ChPanning EQU 128

CC_Backgrnd  EQU 256
CC_Active    EQU 512

CNNA_Stop    EQU 1024
CNNA_Fade    EQU 2048

; ** Instrument and sample definition **

USSInstrSize EQU IVFadeout+2

USSInstr Struc
	IId         DD 0		;'INST'
	ILen	    DD 0
	IName       DB 32  DUP (0)
	INbSmp      DW 0
	INNA        DB 0
	IDNC        DB 0
	ISNumber    DB 120 DUP (0) 	;Sample number for all notes 
	IVEnvelope  DW 24  DUP (0)
	IPEnvelope  DW 24  DUP (0)
	IVPoints    DB 0
	IPPoints    DB 0
	IVSustain   DB 0
	IVLoopStart DB 0
	IVLoopEnd   DB 0
	IPSustain   DB 0
	IPLoopStart DB 0
	IPLoopEnd   DB 0
	IVType	    DB 0	
	IPType      DB 0
	IVibType    DB 0
	IVibSweep   DB 0
	IVibdepth   DB 0
	IVibrate    DB 0
	IVFadeout   DW 0
USSInstr Ends

; Envelope Type Mask

E_On      EQU 1
E_Sustain EQU 2
E_Loop    EQU 4

USSSampleSize EQU SPointer+4		; ! Can't be >255 !

USSSample Struc
	SId	    DD 0		; 'SMPL'
	SLen        DD 0
	SName       DB 32 DUP (0)
	SLength     DD 0
	SLoop	    DD 0
	SLoopEnd    DD 0
	SType       DB 0
	SVolume     DB 0
	SPanning    DB 0
	SRelNote    DB 0
	SFine	    DW 0
	SPointer    DD 0
USSSample Ends

; Sample Type Mask

SM_Adlib  EQU 1
SM_NSigne EQU 2
SM_16bit  EQU 4
SM_Loop   EQU 8
SM_Bidi   EQU 16
SM_Delta  EQU 32
SM_Loaded EQU 128

; USSVAR.INC (c) 1997 FreddyV/Useless