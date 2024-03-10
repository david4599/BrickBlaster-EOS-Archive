#ifndef __DIAMOND__
#define __DIAMOND__

#include <stdio.h>
#include <fcntl.h>      /* Needed only for _O_RDWR definition */
#include <stdlib.h>

#include <dsound.h>

#define     _BUFFERSIZE         16L*1024L

#define   LS_GetMem(a)          GlobalAlloc(GMEM_FIXED,(a))
#define		LS_GetMemHeap(a,b)		GlobalAlloc(GMEM_FIXED,(b))
#define   LS_Release(a)         GlobalFree((a))

#define   PTR         char *
#define   UBYTE       unsigned char

#define   On  1
#define   Off 0

HRESULT __cdecl InitDirectSound(HINSTANCE hInst,HWND hWnd);
void __cdecl FreeDirectSound();


void __cdecl Process_Diamond(void);
void __cdecl BPX(void);
void __cdecl Init_Diamond(void);
void __cdecl Restore_Data_Diamond(void);
void __cdecl Test_Update(void);
void __cdecl Mix_Data(BYTE *Addr1,LONG Size1,BYTE *Addr2,LONG Size2);
void __cdecl Buffer_To_DMA_Mixing();
void __cdecl Channel_Mixing();
void __cdecl Reset_Player();
void __cdecl Load_External_Sample(char *name);
void __cdecl Clear_All_External_Sample();

extern LONG  __cdecl Next_Dma_Value;
extern LONG  __cdecl Mixing_Size_Buffer_Full;
extern LONG  __cdecl Mixing_Size_Buffer;
extern LONG* __cdecl Addr_Buffer_Mixing;
extern LONG  __cdecl Current_DMA_Position;
extern LONG  __cdecl DMA_Size;
extern UBYTE __cdecl Mixing_Real_Stereo;
extern UBYTE __cdecl Mixing_Stereo;
extern UBYTE __cdecl Mixing_16;
extern LONG  __cdecl Replay_Rate;
extern void* __cdecl Addr_Volume_Table;
extern void* __cdecl Addr_Module;
extern LONG  __cdecl Size_Module;
extern UBYTE __cdecl Master_Volume;
extern UBYTE __cdecl Master_Volume_Sfx;
extern UBYTE __cdecl Number_Channel;
extern UBYTE __cdecl Number_Channel_Sfx;
extern UBYTE __cdecl Song_Lenght;
extern UBYTE __cdecl Song_Restart;
extern UBYTE __cdecl Module_Playing;
extern UBYTE __cdecl Index_Pattern_Order;
extern UBYTE __cdecl Current_Pattern;
extern UBYTE __cdecl Current_Note;
extern UBYTE __cdecl Current_BPM;
extern UBYTE __cdecl Current_Speed;
extern UBYTE __cdecl Pattern_Order[];
extern LONG  __cdecl End_Diamond_Autogen;
extern LONG  __cdecl List_Addr_Sample[256];


LONG __cdecl LSYS_PlayModule(void *mod);
LONG __cdecl LSYS_InitModule (void* AddressOfModule,LONG SizeOfModule,LONG NbSfxChannel);
LONG __cdecl LSYS_ReleaseModule (void *mod);
LONG __cdecl LSYS_StartModule();
LONG __cdecl LSYS_StopModule ();
LONG __cdecl LSYS_PauseModule ();
LONG __cdecl LSYS_ResumeModule ();
LONG __cdecl LSYS_SetModuleVolume (LONG generalVolume,LONG SfxVolume);
LONG __cdecl LSYS_GetModulePosition (LONG *position,LONG *patternLine);
LONG __cdecl LSYS_SetModulePosition (LONG positionNb);
LONG __cdecl LSYS_GetModulePositionNumber ();
LONG __cdecl LSYS_GetModuleStatus ();
VOID __cdecl LSYS_Set_Real_Stereo (BOOL val);


void __cdecl Update_Diamond(BOOL AppActive);


#endif