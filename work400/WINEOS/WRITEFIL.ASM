
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Write External File  Save a File on a Disk                                ³
;³                                                                          ³
;³Entree :                                                                  ³
;³        AH = Write_External_File                                          ³
;³       ECX = Taille du fichier                                            ³
;³       EDX = Offset du nom du fichier                                     ³
;³       ESI = Offset du buffer a sauver                                    ³
;³                                                                          ³
;³Sortie :                                                                  ³
;³       Carry = 0                                                          ³
;³        Tout Va Bien                                                      ³
;³                                                                          ³
;³       Carry = 1                                                          ³
;³        Erreur  Can't write file                                          ³
;³                                                                          ³
;³Autre Registre Modifie : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Write_External_File_EOS:
            pushad

            push ecx
            push esi
            mov ax,3c00h
            mov cx,32
            _int 21h
            pop edx
            pop ecx
            jc @@error

            mov bx,ax
            mov ah,40h
            _int 21h
            jnc @@close

            mov ah,3eh
            _int 21h
@@error:
            popad
            Set_Carry
            mIRETD
@@close:
            mov ah,3eh
            _int 21h

            popad
            Clear_Carry
            mIRETD





