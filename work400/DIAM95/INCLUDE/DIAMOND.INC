CPUBLIC     macro x
public      _&x
            endm



CPUBLIC     DMA_Size
CPUBLIC     Next_Dma_Value
CPUBLIC     Mixing_Size_Buffer_Full
CPUBLIC     Mixing_Size_Buffer
CPUBLIC     Addr_Buffer_Mixing
CPUBLIC     Process_Diamond
CPUBLIC     Init_Diamond
CPUBLIC     Mix_Data
CPUBLIC     Mixing_Real_Stereo
CPUBLIC     Mixing_Stereo
CPUBLIC     Mixing_16
CPUBLIC     Replay_Rate
CPUBLIC     Addr_Volume_Table
CPUBLIC     Size_Module
CPUBLIC     Addr_Module
CPUBLIC     Master_Volume
CPUBLIC     Master_Volume_Sfx
CPUBLIC     Song_Lenght
CPUBLIC     Song_Restart
CPUBLIC     Module_Playing
CPUBLIC     Index_Pattern_Order
CPUBLIC     Current_Pattern
CPUBLIC     Current_Note
CPUBLIC     Current_BPM
CPUBLIC     Current_Speed
CPUBLIC     Pattern_Order
CPUBLIC     Number_Channel
CPUBLIC     Number_Channel_Sfx
CPUBLIC     Reset_Player


CPUBLIC     Buffer_To_DMA_Mixing
CPUBLIC     Channel_Mixing
CPUBLIC     End_Diamond_Autogen

global      Load_External_Sample : proc
global      _Load_External_Sample : proc
global      Clear_All_External_Sample : proc
global      _Clear_All_External_Sample : proc

public      Play_Sample_Diamond

global      List_Addr_Sample : dword
global      _List_Addr_Sample : dword

SOUND struc
Freq                dd 0
Size                dd 0
Support             dw 0
NbBlockAlign        dw 0
FormatTag           dw 0
NbChannels          dw 0
NbSamplesPerSec     dd 0
NbAvgBytesPerSec    dd 0
NbBitsPerSample     dd 0
Format              dw 0
                    dw 0
Extra               dd 0
      ends


;Global      Start_Playing_Diamond           : Proc
;Global      Stop_Playing_Diamond            : Proc
;Global      Initialise_Player_Diamond       : Proc
;Global      Clear_Module_Diamond            : Proc
;Global      Play_Sample_Diamond             : Proc

Dev_Func    Struc
Detect_             dd 0
Init_               dd 0
Manual_Setup_       dd 0
Load_Sample_        dd 0
Clear_Memory_       dd 0
Init_Sound_Card_    dd 0
Start_Playing_      dd 0
Stop_Playing_       dd 0
Play_Voice_         dd 0
Set_BPM_            dd 0
Get_Frequence_      dd 0
Mix_Data_           dd 0
Clear_Module_       dd 0
            ends


Player_Func Struc
Detect_             dd 0
Next_Tick_          dd 0
            ends