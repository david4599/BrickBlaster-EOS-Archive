;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³                                                                          ³
;³                                                                          ³
;³Definition de Toutes les Fonctions Utilisees par L'EOS pour la Partie     ³
;³de la musique                                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SDATA
ifndef WIN32
Global      Detect_Sound_Card_Diamond       : Proc
Global      Start_Playing_Diamond           : Proc
Global      Stop_Playing_Diamond            : Proc
Global      Initialise_Player_Diamond       : Proc
Global      Clear_Module_Diamond            : Proc
Global      Manual_Setup_Diamond            : Proc
endif

Global      Play_Sample_Diamond             : Proc
Handle_Mod  dd 0

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Detect Sound Card   Detect with the environment varialble the sound       ³
;³                    card installed                                        ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Detect_Sound_Card                                            ³
;³        CX = 1  Display result of Searching                               ³
;³                                                                          ³
;³Out :                                                                     ³
;³        AX = 0  No_Card                                                   ³
;³           = 1  Sound Blaster 1.0                                         ³
;³           = 2  Sound Blaster 1.5                                         ³
;³           = 3  Sound Blaster 2.0                                         ³
;³           = 4  Sound Blaster Pro                                         ³
;³           = 5  Sound Blaster 16                                          ³
;³           = 6  Sound Blaster Awe 32                                      ³
;³           = 10h  Gus                                                     ³
;³           = 11h  Gus Max                                                 ³
;³           = 12h  Gus Ace                                                 ³
;³           = 13h  Gus Pnp                                                 ³
;³           = 20h  WSS                                                     ³
;³        BX = Port                                                         ³
;³        CX = Irq                                                          ³
;³        DX = Dma                                                          ³
;³        SI = Dsp Version (For Sb) ou                                      ³
;³             Size of RAM of the Gravis                                    ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Detect_Sound_Card_EOS:
ifndef WIN32
            PushDS
            PushES
            mov ax,_CS[Data32_Sel]
            mov ds,ax
            mov es,ax
            Call Detect_Sound_Card_Diamond
            PopES
            PopDS
else
            mov eax,0ffh
            xor ebx,ebx
            xor ecx,ecx
            xor edx,edx
            xor esi,esi
endif
            mIRETD


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load Module   Load a module & initialize into the memory                  ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Load_Module                                                  ³
;³        AL = Bit 0 = 1  Load a internal module (can be compress and link  ³
;³                        with LLINK)                                       ³
;³           = Bit 1 = 1  Load module  from memory                          ³
;³           = Bit 2 = 1  Force old mod Loading (15 instr)                  ³
;³        BX = Replay rate (16000 to 441000 Hz)                             ³
;³        CX = Number of Sfx Channel                                        ³
;³        DS:EDX = Offset of Module name or                                 ³
;³                 Offset into the memory of the beginning of the module    ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Can't Load Module                                            ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Load_Module_EOS:
            cmp _CS[Handle_Mod],0
            jne @@Ok12
            pushad
            test al,2
            jne @@Ok2
            mov ah,Load_External_File_Handle
            test al,1
            je @@Ok1
            mov ah,Load_Internal_File_Handle
@@Ok1:
            push ecx
            Int_EOS
            jc @@Ok10
            PushDS
            LoadDS
            mov [Handle_Mod],edi
            PopDS
            mov edx,eax
@@Ok2:
            pop eax
ifndef WIN32
            PushDS
            PushES
            mov esi,edx
            mov dx,_CS[Data32_Sel]
            mov ds,dx
            mov es,dx
            call Initialise_Player_Diamond
            PopES
            PopDS
            jc @@Ok11
else
            CCALL LSYS_InitModule,esi,ecx,eax
            test eax,eax
            je @@Ok11
            CCALL LSYS_PlayModule,[Handle_Mod]
endif
            popad
            mov eax,1
            Clear_Carry
            mIRETD

@@Ok10:
            pop ecx
@@Ok11:
            mov ah,DeAllocate_Memory_Handle
            mov edi,_CS[Handle_Mod]
            Int_EOS
            popad
@@Ok12:
            xor eax,eax
            Set_Carry
            mIRETD


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Play Module   Start playing the module                                    ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Play_Module                                                  ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Can't Play Module                                            ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Play_Module_EOS:
ifndef WIN32
            pushad
            PushDS
            PushES
            mov ax,_CS[Data32_Sel]
            mov ds,ax
            mov es,ax
            Call Start_Playing_Diamond
            jc @@Ok10
            PopES
            PopDS
            popad
            Clear_Carry
            mIRETD
@@Ok10:
            PopES
            PopDS
            popad
            Set_Carry
            mIRETD
else
            pushad
            CCALL LSYS_ResumeModule
            popad
            Clear_Carry
            mIRETD
endif


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Stop Module   Stop playing module                                         ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Stop_Module                                                  ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Stop_Module_EOS:
            pushad
ifndef WIN32
            PushDS
            PushES
            mov ax,_CS[Data32_Sel]
            mov ds,ax
            mov es,ax
            Call Stop_Playing_Diamond
            PopES
            PopDS
else
            CCALL LSYS_PauseModule
endif
            popad
            mIRETD

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Clear Module   Unload the module from memory                              ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Clear_Module                                                 ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Clear_Module_EOS:
            pushad
ifndef WIN32
            PushDS
            PushES
            mov ax,_CS[Data32_Sel]
            mov ds,ax
            mov es,ax
            Call Stop_Playing_Diamond
            xor edi,edi
            mov ah,DeAllocate_Memory_Handle
            xchg edi,[Handle_Mod]
            Int_EOS
            Call Clear_Module_Diamond
            PopES
            PopDS
else
            CCALL LSYS_PauseModule
            CCALL LSYS_StopModule
            CCALL LSYS_ReleaseModule,[Handle_Mod]
            mov ah,DeAllocate_Memory_Handle
            xor edi,edi
            xchg edi,[Handle_Mod]
            Int_EOS
endif
            popad
            mIRETD

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Manual Setup Sound Card                                                   ³
;³                                                                          ³
;³In :                                                                      ³
;³        AL = Type                                                         ³
;³        BX = Port                                                         ³
;³        CL = Irq1                                                         ³
;³        CH = Irq2      ; Irq Gus 2                                        ³
;³        DL = Dma1      ; Dma Gus 1 or Dma 8 Bits for SB                   ³
;³        DH = Dma2      ; Dma Gus 2 or Dma 16 Bits for SB                  ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry Off                                                         ³
;³        Init Ok                                                           ³
;³                                                                          ³
;³        Carry On                                                          ³
;³        No Sound Card Found                                               ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Manual_Setup_EOS:
ifndef WIN32
            call Manual_Setup_Diamond
            jc @@Ok1
            Clear_Carry
            mIRETD
@@Ok1:
            Set_Carry
            mIRETD
else
            Clear_Carry
            ret
endif


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set Volume   Set the master volume of the module                          ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Set_Volume                                                   ³
;³        BL = Volume (0 to 63)                                             ³
;³        CL = Sfx Volume (0 to 63)                                         ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set_Volume_EOS:
ifndef WIN32
            PushDS
            LoadDS
            mov [Master_Volume],bl
            mov [Master_Volume_Sfx],cl
            PopDS
            mIRETD
else
            pushad
            and ebx,0ffh
            and ecx,0ffh
            CCALL LSYS_SetModuleVolume,ebx,ecx
            popad
            mIRETD
endif

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Load Sample   Load a sample & initialize into the memory                  ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Load_Sample                                                  ³
;³        AL = Bit 0 = 1  Load a internal module (can be compress and link  ³
;³                        with LLINK)                                       ³
;³        DS:EDX = Offset of Sample name or                                 ³
;³                 Offset into the memory of the beginning of the sample    ³
;³                                                                          ³
;³Out :                                                                     ³
;³        Carry = 0                                                         ³
;³             All Done                                                     ³
;³                                                                          ³
;³        Carry = 1                                                         ³
;³             Can't Load Module                                            ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Load_Sample_EOS:
            push ebx
            push ecx
            push edx
            push esi
            push edi
            mov ah,Load_External_File_Handle
            test al,1
            je @@Ok1
            mov ah,Load_Internal_File_Handle
@@Ok1:
            Int_EOS
            jc @@Ok11
            mov edx,eax
ifndef WIN32
else
            CCALL _Load_External_Sample,edx
            jc @@Ok10
endif
            pop edi
            pop esi
            pop edx
            pop ecx
            pop ebx
            Clear_Carry
            mIRETD
@@Ok10:
            mov ah,DeAllocate_Memory_Handle
            Int_EOS
@@Ok11:
            pop edi
            pop esi
            pop edx
            pop ecx
            pop ebx
            Set_Carry
            mIRETD



;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Play Sample   Play a sample include into the module                       ³
;³                                                                          ³
;³In :                                                                      ³
;³        AH = Play_Sample                                                  ³
;³        BX = Sample numbers                                               ³
;³        CX = Sample Frequecy                                              ³
;³        DX = voice of sample                                              ³
;³                                                                          ³
;³Out :                                                                     ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Play_Sample_EOS:
            pushad
ifndef WIN32
            PushDS
            PushES
            mov ax,_CS[Data32_Sel]
            mov ds,ax
            mov es,ax
endif
            call Play_Sample_Diamond
ifndef WIN32
            PopES
            PopDS
endif
            popad
            mIRETD


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Get Info   Get information about the module when playing                  ³
;³                                                                          ³
;³In:                                                                       ³
;³        AH = Get_Info                                                     ³
;³                                                                          ³
;³Out:                                                                      ³
;³        AH = Position                                                     ³
;³        AL = Pattern                                                      ³
;³        BX = Note                                                         ³
;³        CL = Master Volume                                                ³
;³        DL = Master Volume Sfx                                            ³
;³                                                                          ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Get_Info_EOS:
            PushDS
            LoadDS
            mov ah,B [Index_Pattern_Order]
            mov al,[Current_Pattern]
            movzx bx,[Current_Note]
            mov cl,[Master_Volume]
            mov dl,[Master_Volume_Sfx]
            PopDS
            mIRETD


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Set Pattern  Set the current position of the playing module               ³
;³                                                                          ³
;³In:                                                                       ³
;³        AH = Set_Pattern                                                  ³
;³        BX = New_Position                                                 ³
;³        CX = New_Note                                                     ³
;³                                                                          ³
;³Out:                                                                      ³
;³                                                                          ³
;³Other Registers Change : None                                             ³
;³                                                                          ³
;³                                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set_Pattern_EOS:
            PushDS
            push ebx
            LoadDS
;            test cl,cl
;            jne @@Ok1
;            dec bx
;            mov cl,64
;@@Ok1:
;            test bx,bx
;            jns @@Ok2
;            mov ebx,-1
;            mov cl,64
;@@Ok2:
            movsx ebx,bx
            mov [Index_Pattern_Order],ebx
            mov bl,[Pattern_Order+ebx]
            mov [Current_Pattern],bl
            mov [Current_Note],cl
            pop ebx
            PopDS
            mIRETD