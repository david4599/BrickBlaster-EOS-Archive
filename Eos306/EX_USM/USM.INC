;            ษอออออออออออออออออออออออออออออออออออออออออออออออออออป
;            บ       ๗๗๗๗๗๗๗๗๗๗๗๗๗๗ USM.INC ๗๗๗๗๗๗๗๗๗๗๗๗๗๗       บ
;            บ                                                   บ
;            บ              Useless Module Definition            บ
;            บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบ
;            บ   By Freddy Vtel (FreddyV/Useless)              บ
;            บ                                                   บ
;            บ   Code Starts .................. 31/03/1996       บ
;            บ   Last Update .................. 01/12/1996       บ
;            ศอออออออออออออออออออออออออออออออออออออออออออออออออออผ
; USM format includes all XM feathures, I will soon add IT support.
; soon means at least 2 months, because I'm in the army...... :(
; See USSVAR.INC for the instruments ans samples format.

MAX_Patterns    EQU 256
MAX_Samples     EQU 256
MAX_Instruments EQU 128

USMHeaderLen EQU MInstrPtr+MAX_Instruments*4

USM struc
        MId          DD 0      	        ; Useless Module Id 'USLM'
        MLen         DD 0               ; Module Size
        MName        DB 32 DUP (0)      ; Module Name
        MFlags       DW 0               ; Module Flags
        MVersion     DW 0               ; Module Version
        MTracker     DW 0               ; Tracker
        MChannels    DW 0
        MSongLen     DW 0               ; Song Length
        MPatterns    DW 0               ; Number of Patterns
        MRestart     DW 0               ; Restart position
        MSamples     DW 0               ; Number of samples
        MInstruments DW 0               ; Number of instruments
        MTempo	     DB 0
        MBPM	     DB 0
        MOrder       DB 256 DUP (0)     ; Pattern order table
	MChPan       DB 32  DUP (0)     ; Channels panning Table
	MChVol       DB 32  DUP (0)     ; Channels volume table
	MPattPtr     DD MAX_Patterns    DUP (0)
	MSamplPtr    DD MAX_Samples     DUP (0)
	MInstrPtr    DD MAX_Instruments DUP (0)
USM Ends

; File Flags
F_Linear    EQU 1 ; Linear/Amiga Periode
F_FastVS    EQU 2 ; ST3 Fast Volume Slide
F_SetPann   EQU 4 ; Set Samples Panning (at sample starts)
F_InstrMode EQU 8 ; Samples/Instrument Mode

USMPatternSize EQU Prow+2

USMPattern Struc
        PId     DD 0                    ; Useless pattern Id 'USLP'
        PSize   DD 0
        Pnumber DW 0                    ; Pattern number
        Prow    DW 0
USMPattern Ends

NoteSize EQU 5

; Pattern rows format:
;
; Note (byte)        1 (C-0) to 96 (B-7) 255 is Key Off 
; Instrument (byte)  1 to 255
; Volume (byte)      FT2 like volume
; Command (byte)
; Parameter (byte)

Key_Off EQU 255
Row_End EQU 254

; 'Source' format constants
M_MOD Equ 1
M_669 Equ 2
M_STM Equ 3
M_S3M Equ 4
M_IT  EQU 5
M_XM  Equ 6

; USM.INC (c) 1997 FreddyV/Useless