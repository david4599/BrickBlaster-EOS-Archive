SDATA
ifndef WIN32
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
variables:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Old_IRQ1_vector 	dd 0,0
else
Global _Key_Map     : byte
_Key_Map            Label Byte
endif
Key_Map             Label Byte
ifndef WIN32
                    db 128 dup (0)
else
                    db 256 dup (0)
endif

Remove_Flag         db 0

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Use Int 09   Met ou enleve L'int 09                                       ³
;³                                                                          ³
;³Entree :                                                                  ³
;³        AH = Use_Int_09                                                   ³
;³        BX = Off Enleve L'int 09                                          ³
;³           = On  Met L'int 09                                             ³
;³                                                                          ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³                                                                          ³
;³      EAX = Physical address of the key_map array (for watcom users)      ³
;³                                                                          ³
;³Autre Registre Modifie : Aucun                                            ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SCODE
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Use_Int_09_EOS:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ifndef WIN32
            pushad
            PushDS
            LoadDS
            or bx,bx
            je @@Ok1
            call Install_Int9
            jmp @@Ok2
@@Ok1:
            call Remove_Int9
@@Ok2:
            PopDS
            popad
            lea eax,_CS[Key_Map]
            add eax,_CS[Code32_Addr]
            mIRETD
else
            mov [Remove_Flag],bl
            mov eax,O Key_Map
            mIRETD
endif


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Install_Int9:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ifndef WIN32
            cmp Remove_Flag,1
            je @@end
            mov ah,Get_Irq
            mov bl,1
            Int_EOS
            mov Old_IRQ1_vector,edx
            mov word ptr Old_IRQ1_vector+4,cx

            mov ah,Set_Irq
            mov bl,1
            mov EDX,offset Int9
            mov cx,cs
            Int_EOS

	mov Remove_Flag,1
@@end:
endif
	ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Remove_Int9:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ifndef WIN32
	cmp Remove_Flag,1
	jne @@end

            mov ah,Set_Irq
            mov bl,1
       	mov edx,Old_IRQ1_vector
       	mov cx,word ptr Old_IRQ1_vector+4
            Int_EOS

            mov Remove_Flag,0
@@end:
endif
	ret
ifndef WIN32

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Int9:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

            PushDS
        	push ebx
            push eax
            LoadDS
@@read_ag:
	in al,60h
            cmp al,128
            jae @@Cont
            mov Key_Map,al
@@Cont:

	mov bl,al
	and ebx,01111111b
	add ebx,offset Key_Map

	not al
	shr al,7

	mov byte ptr [ebx],al

	in al,64h
	test al,1
	jnz @@read_ag

            mov al,20h
        	out 20h,al

            pop eax
        	pop ebx
            PopDS

            mIRETD
endif