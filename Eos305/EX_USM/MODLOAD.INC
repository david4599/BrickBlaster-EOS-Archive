;            浜様様様様様様様様様様様様様様様様様様様様様様様様様�
;            �     �������������� MODLOAD.INC ��������������     �
;            �                                                   �
;            �           Useless MOD Loader (MOD->USM)           �
;            債陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
;            �   Auteur������������������������ Freddy V�tel�    �
;            �                                                   �
;            �   D�but d'�criture�������������� 19/08/1996       �
;            �   Derni�re modification��������� 20/04/1997       �
;            藩様様様様様様様様様様様様様様様様様様様様様様様様様�

if _WATCOM
Global MOD_Load_  :Near
else
Global MOD_Load   :Near
endif

MODSampleSize EQU MODSLoopLen+2

MODSample Struc
	MODSName      DB 22 DUP (?)
	MODSLength    DW ?
	MODSFine      DB ?
	MODSVolume    DB ?
	MODSLoop      DW ?
	MODSLoopLen   DW ?
MODSample EndS		

; MODLOAD.INC (c) 1997 FreddyV/Useless