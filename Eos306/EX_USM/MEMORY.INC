;            浜様様様様様様様様様様様様様様様様様様様様様様様様様�
;            �     �������������� MEMORY.INC ��������������      �
;            �                                                   �
;            �              Useless Memory Manager               �
;            債陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
;            �   By Freddy V�tel� (FreddyV/Useless)              �
;            �                                                   �
;            �   Code Starts .................. 14/03/1996       �
;            �   Last Update .................. 11/11/1996       �
;            藩様様様様様様様様様様様様様様様様様様様様様様様様様�

ifndef _OS_
display 'OS.INC must be included before MEMORY.INC'
endif

; Public memory functions

Global _Malloc       :Near ; Allocate a memory block
Global _Calloc       :Near ; Allocate and clear a memory block
Global _Free         :Near ; Free an allocated memory block
Global _Maxavail     :Near ; Get the length of the biggest free block.
Global _MEMORY_Error :Near ; Display the Memory Error.
Global _Debug_MEMORY :Near

; Public Var

Global Memory_Return :dword

DirrectError EQU 1  ; 1 => Stop program immediatly after an error
                    ; 0 => Jump to the Proc Error label

;嬪様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様�
;�  Malloc: Allocate a memory block                                        �
;�                                                                         �
;� Input: Size of the memory block to allocate                             �
;�                                                                         �
;� Output: CF Set=> Error                                                  �
;�         EAX returns the error number                                    �
;�                                                                         �
;�         CF Clear                                                        �
;�         EAX pointer to the allocated memory block                       �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
Malloc 	MACRO Size
Local Malloc_NoError	

        pushad
        ifdifi <Size>,<eax>
        mov eax,Size
        endif
        call _Malloc
        popad
        mov eax,Memory_Return
if DirrectError Eq 1
        jnc Malloc_NoError
        call _MEMORY_Error
endif
Malloc_NoError:	
EndM

;嬪様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様�
;�  Calloc: Allocate and clear a memory block                              �
;�                                                                         �
;� Input: Size of the memory block to allocate                             �
;�                                                                         �
;� Output: CF Set=> Error                                                  �
;�         EAX returns the error number                                    �
;�                                                                         �
;�         CF Clear                                                        �
;�         EAX pointer to the allocated memory block                       �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
Calloc 	MACRO Size
Local Calloc_NoError

	pushad
        ifdifi <Size>,<eax>
        mov eax,Size
        endif				
        call _Calloc
        popad
        mov eax,Memory_Return
if DirrectError eq 1
        jnc Calloc_NoError
        call _MEMORY_Error
endif
Calloc_NoError:	
EndM

;嬪様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様�
;�  Free: Free an allocated memory block                                   �
;�                                                                         �
;� Input: Pointer to the memory block to free.                             �
;�                                                                         �
;� Output: CF Set=> Error                                                  �
;�         EAX returns the error number                                    �
;�                                                                         �
;�         CF Clear=> Ok                                                   �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
Free    MACRO Location
Local Free_NoError

        pushad
        ifdifi <Location>,<eax>
        mov eax,Location
        endif
        call _Free
        popad
        mov eax,Memory_Return
if DirrectError eq 1
        jnc Free_NoError
        call _MEMORY_Error
endif
Free_NoError:	
EndM

;嬪様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様�
;�  Maxavail: Get the length of the biggest free block.                    �
;�                                                                         �
;� Output: CF Set=> Error                                                  �
;�         EAX returns the error number                                    �
;�                                                                         �
;�         CF Clear=> Ok                                                   �
;�         EAX returns 'Maxavail'                                          �
;青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳�
Maxavail MACRO
Local Maxavail_NoError
        pushad
        call _Maxavail
        popad
        mov eax,Memory_Return
if DirrectError eq 1
        jnc Maxavail_NoError
        call _MEMORY_Error
endif
Maxavail_NoError:	
EndM

;MEMORY.INC (c) 1997 FreddyV/Useless
