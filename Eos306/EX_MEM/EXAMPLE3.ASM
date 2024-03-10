;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ                                                                          บ
;บ This example show how to use EOSLITE, the memory and the selectors       บ
;บ                                                                          บ
;บ Tabs : 13 21 29 37                                                       บ
;บ                                                                          บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

.386
CODE32 SEGMENT PUBLIC PARA USE32 'CODE'
ASSUME  CS:CODE32,DS:CODE32,ES:CODE32

INCLUDE ..\RESOURCE\EOS.INC

Msg_Ok       db '    þ Allocate 1024 Mbytes ',13,10,36

Msg_Memory   db '    þ Not Enough Memory ...',13,10,36

Msg_Selector db '    þ No Free Selector ...',13,10,36

Msg_Filling1 db '    þ Filling With Logical Address',13,10,36

Msg_Filling2 db '    þ Filling With Selector Buffer',13,10,36


Logical_Address dd 0
Selector_Buffer dw 0


Start32:
            mov ah,Use_Int_09       ; Use Int 09 From EOS Easy to use !!
            mov bx,On
            Int_EOS

            mov ah,Use_Int_08       ; Use Int 08 to wait a stable Frame
            mov bx,On
            Int_EOS

            mov ah,9
            mov edx,O Msg_Ok
            int 21h

            mov ah,Allocate_Memory
            mov edx,1048576         ; Allocate 1024Mb
            Int_EOS
            jnc Allocate_Ok

            mov ah,Exit_Error
            mov edx,O Msg_Memory
            Int_EOS

Allocate_Ok:
            mov [Logical_Address],edx ; Save the Address of the buffer
            mov esi,eax
            mov ah,Allocate_Selector  ; Allocate a selector with
            mov edi,-1                ; start address from the buffer
            Int_EOS
            jnc Selector_Ok

            mov ah,Exit_Error         ; very very rare error
            mov edx,O Msg_Selector    ; you have 16 Selector Free Min
            Int_EOS

Selector_Ok:
            mov [Selector_Buffer],bx

            mov ah,9                  ; Display first message
            mov edx,O Msg_Filling1
            int 21h

Loop_1:
            xor eax,eax               ; Fill the buffer with the logical
            mov edi,[Logical_Address] ; address  ES=DS=[Data32_Sel]
            mov ecx,262144
            rep stosd

            mov ah,Wait_Vbl
            Int_EOS

            cmp [Key_Map+All],Off     ; Wait a key
            je Loop_1

            mov [Key_Map+All],Off     ; Clear keyboard buffer

            mov ah,9                  ; Display second message
            mov edx,O Msg_Filling2
            int 21h

Loop_2:
            xor eax,eax               ; Fill the buffer with a selector
            xor edi,edi               ; EDI = 0 begin of selector
            mov es,cs:[Selector_Buffer] ; ES = [Selector_Buffer]
            mov ecx,262144
            rep stosd

            mov ah,Wait_Vbl
            Int_EOS

            cmp [Key_Map+All],Off     ; Wait a key
            je Loop_2

            mov es,cs:[Data32_Sel]  ; Must have NO selector register use
                                    ; the Selector_Buffer before Calling
                                    ; DeAllocate_Selector

            mov ah,DeAllocate_Selector
            mov bx,[Selector_Buffer]
            Int_EOS

            mov ah,Deallocate_Memory
            Int_EOS

            mov ax,4c00h
            int 21h                 ; Exit with Error Code 0


            CODE32 ENDS

            END