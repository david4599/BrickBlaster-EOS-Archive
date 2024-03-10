

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
; Command : 0,0      = end
;           0,1..255 = color
;           13       = first colonne
;           10       = next ligne
;
; Syntax :  lea edx,texte
;           call Direct_Send
;
Direct_Send_EOS:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ifndef WIN32
            pushad
            mov esi,edx
            push esi
            mov ah,3
            mov bh,0
            _int 10h
            movzx ecx,dh             ; ecx=ligne ou se trouve le curseur
            pop esi

            PushES
            mov es,_CS[Flat_Data_Sel]

            mov ebp,0b8000h         ; ebp=adresse de l'‚cran couleur
                                    ; (en monochrome cette fonction n'a aucun interˆt)

            mov ah,7                ; couleur par d‚faut
            movzx edx,W es:[44ah]   ; edx=nombre de colonne
            shl edx,1

            or ecx,ecx
            jz @@cont
@@decal:
            add ebp,edx             ; ebp=adresse de la ligne en vram
            loop @@decal
@@cont:

            mov edi,ebp
@@again:
            lodsb
            or al,al
            jz @@couleur
            cmp al,10
            je @@nextligne
            cmp al,13
            je @@firstcolonne
            stosw
            jmp @@again
@@end:
            PopES
            popad
            mIRETD

@@nextligne:
            add ebp,edx
@@firstcolonne:
            push eax
            push edx
            mov ah,2
            mov dl,al
            _int 21h                 ; mise … jour de la pos curseur pour le bios
            pop edx
            pop eax
            mov edi,ebp
            jmp @@again

@@couleur:
            lodsb
            test al,al
            je @@end
            mov ah,al
            jmp @@again
else
            mov ah,9
            _int 21h
            mIRETD
endif