;            浜様様様様様様様様様様様様様様様様様様様様様様様様様�
;            �     �������������� STMLOAD.INC ��������������     �
;            �                                                   �
;            �           Useless STM Loader (STM->USM)           �
;            債陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
;            �   By Freddy V�tel� (FreddyV/Useless)              �
;            �                                                   �
;            �   Code Starts .................. 19/08/1996       �
;            �   Last Update .................. 20/04/1997       �
;            藩様様様様様様様様様様様様様様様様様様様様様様様様様�

if _WATCOM
Global STM_Load_  :Near
else
Global STM_Load   :Near
endif

STMHeaderSize EQU STMFill2+13

STMHeader Struc
          STMName      DB 20 DUP (0) 
	  STMIdent     DB 8  DUP (0) ; Tracker Name ('!SCREAM!', for example)
          STMFill1     DB 0
	  STMFileType  DB 0          ; 1=song, 2=module 
          STMVer_major DB 0
	  STMVer_minor DB 0
	  STMTempo     DB 0
	  STMPatterns  DB 0
	  STMVolume    DB 0
	  STMFill2     DB 13 DUP (0) ; Reserved data
STMHeader Ends

STMSampleSize EQU STMSFill3+6

STMSample Struc
	STMSName      DB 14 DUP (0)
        STMSFill1     DW 0         ; Reserved word
	STMSLength    DW 0         ; Sample Length 
	STMSLoop      DW 0         ; Loop Start
	STMSLoopEnd   DW 0         ; Loop end
        STMSVolume    DB 0         ; Sample volume 
	STMSFill2     DB 0         ; Reserved byte
	STMSFine      DW 0         ; C4 Freq
        STMSFill3     DB 6 DUP (0) ; More reserved data
STMSample EndS		

; STMLOAD.INC (c) 1997 FreddyV/Useless