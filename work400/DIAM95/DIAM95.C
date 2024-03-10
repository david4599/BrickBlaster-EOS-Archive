#include "..\resource\eos.h"
#include <diam95.h>
#include <resource.h>
#include <windowsx.h>
#include <mmsystem.h>

// *****************************************************************

  LPDIRECTSOUND           DSoundPtr;
  LPDIRECTSOUNDBUFFER     PrimaryBuffer;

// *****************************************************************

  LPDIRECTSOUNDBUFFER     Diamond_Buffer;
  CRITICAL_SECTION        cs;
  BYTE                    *pbdata2 = NULL;
  DWORD                   dwLength;
  static LONG             LS_Module_Init = FALSE;
  static volatile BOOL    Mutex=FALSE;
  static BOOL             Exit=FALSE;



HRESULT __cdecl InitDirectSound(HINSTANCE hInst,HWND hWnd)
{
  HRESULT                 hr;
  DSBUFFERDESC            dsbd;
  WAVEFORMATEX            fx;
  DWORD                   id;
  DWORD                   popo;

  if (LS_Module_Init)
    return TRUE;

  DSoundPtr = NULL;

  // Initialisation de directsound
  if((hr = DirectSoundCreate( NULL, &DSoundPtr, NULL ))!=DS_OK)
    return hr;

  hr = IDirectSound_SetCooperativeLevel( DSoundPtr,hWnd,DSSCL_PRIORITY);

	// Creation du buffer de son
  ZeroMem(&dsbd, sizeof(DSBUFFERDESC));
	dsbd.dwSize   = sizeof(DSBUFFERDESC);
  dsbd.dwFlags  = DSBCAPS_PRIMARYBUFFER | DSBCAPS_GETCURRENTPOSITION2 ;
  hr = IDirectSound_CreateSoundBuffer(DSoundPtr,&dsbd,&PrimaryBuffer,NULL);
	if( hr != DS_OK )
    return hr;

  fx.wFormatTag       = WAVE_FORMAT_PCM;
  fx.nChannels        = 2;
  fx.nSamplesPerSec   = 44100L;
  fx.nBlockAlign      = 2 * fx.nChannels;
  fx.wBitsPerSample   = 16;
	fx.nAvgBytesPerSec	= fx.nSamplesPerSec * fx.nBlockAlign;
  fx.cbSize           = 0;
  hr = IDirectSoundBuffer_SetFormat(PrimaryBuffer,&fx);

  hr = IDirectSoundBuffer_Play(PrimaryBuffer, 0, 0, DSBPLAY_LOOPING);
	if( hr != DS_OK )
    return hr;

  LS_Module_Init = FALSE;

	// Set up the direct sound buffer.
  ZeroMem(&dsbd,  sizeof(DSBUFFERDESC));
	dsbd.dwSize          = sizeof(DSBUFFERDESC);
	dsbd.dwFlags         = 0;
  dsbd.dwFlags        |= DSBCAPS_CTRLDEFAULT;
  dsbd.dwFlags        |= DSBCAPS_LOCSOFTWARE;
  dsbd.dwFlags        |= DSBCAPS_GETCURRENTPOSITION2;
  dsbd.dwFlags        |= DSBCAPS_GLOBALFOCUS;
  dsbd.dwFlags        |= DSBCAPS_CTRLPOSITIONNOTIFY;
	dsbd.dwBufferBytes   = _BUFFERSIZE;
	dsbd.lpwfxFormat     = &fx;

  if (IDirectSoundBuffer_GetFormat(PrimaryBuffer,&fx,sizeof (WAVEFORMATEX),NULL)!= DS_OK)
    return DDERR_GENERIC;

	if (IDirectSound_CreateSoundBuffer(DSoundPtr,&dsbd,&Diamond_Buffer,NULL )!= DS_OK)
    return DDERR_GENERIC;

	if (fx.wBitsPerSample==16)
		Mixing_16 = On;
   else
		Mixing_16 = Off;

	if (fx.nChannels==2)
		Mixing_Stereo=On;
   else
		Mixing_Stereo=Off;

	Replay_Rate = fx.nSamplesPerSec;
	DMA_Size = _BUFFERSIZE;

	if (Addr_Volume_Table == NULL)
	{
		// Allocation de la table de volume
		Addr_Volume_Table = LS_GetMem (65*256*4+16384*4+16);
    if (!Addr_Volume_Table)
      return DDERR_GENERIC;
	}

	LS_Module_Init = TRUE;
  Mixing_Real_Stereo=Off;

  Reset_Player();

  VirtualProtect(Channel_Mixing,End_Diamond_Autogen,PAGE_EXECUTE_READWRITE,&popo);

  return DS_OK;
}

void __cdecl FreeDirectSound()
{
  if (LS_Module_Init)
	{
    if (!Addr_Volume_Table)
		{
			LS_Release (Addr_Volume_Table);
			Addr_Volume_Table = NULL;
		}
    if (Diamond_Buffer!=NULL)
      IDirectSoundBuffer_Release(Diamond_Buffer);
    if (DSoundPtr!=NULL)
      IDirectSound_Release(DSoundPtr);
  }
}

// **********************************************************************
// **********************************************************************

LONG __cdecl LSYS_PlayModule(void *mod)
{
  if (mod!=NULL)
  {
    if (LSYS_GetModuleStatus () == TRUE)
      return FALSE;
    return LSYS_StartModule();
  }
  return 0;
}

// **********************************************************************
// **********************************************************************

LONG __cdecl LSYS_InitModule (void* AddressOfModule,LONG SizeOfModule,LONG NbSfxChannel)
{
  if (AddressOfModule!=NULL)
  {
    Addr_Module = AddressOfModule;
    Size_Module = SizeOfModule;
    DMA_Size = _BUFFERSIZE;
    Number_Channel_Sfx=NbSfxChannel;
    Init_Diamond();                       // converti le module cree la
                                          // table de volume et sauve
    return TRUE;                          // ses donees 4096 octects avant
  }                                       // la fin du module
  Addr_Module = NULL;
  Size_Module = 0;
  return FALSE;
}

// **********************************************************************
// **********************************************************************

LONG __cdecl LSYS_ReleaseModule (void *mod)
{
  long  i;
  if (mod!=NULL)
  {
    // Attention peut bouclé sans la gestion des évenement Windows
    LSYS_StopModule ();
    Exit=TRUE;
    while (Mutex==TRUE);
    for (i=128;i<256;i++)
    {
     if (List_Addr_Sample[i]!=0)
     {
        GlobalFree((HGLOBAL)List_Addr_Sample[i]);
        List_Addr_Sample[i]=0;
     }
    }
    Addr_Module = NULL;
    Size_Module = 0;
  }
    Exit=FALSE;
    return TRUE;
}

// **********************************************************************
// **********************************************************************

LONG __cdecl LSYS_StartModule()
{
  if (Diamond_Buffer!=NULL)
  {
    LSYS_SetModulePosition (0);
    Current_BPM = 125;
    Current_Speed = 6;
    IDirectSoundBuffer_Lock(Diamond_Buffer,0,_BUFFERSIZE,&pbdata2,&dwLength,NULL,NULL,0L);
    ZeroMem(pbdata2, _BUFFERSIZE);
    IDirectSoundBuffer_Unlock(Diamond_Buffer,pbdata2,dwLength,NULL,0);
    IDirectSoundBuffer_Play(Diamond_Buffer,0,0,DSBPLAY_LOOPING);
//  InitializeCriticalSection(&cs);
    return TRUE;
  }
  else
    return FALSE;
}

// **********************************************************************
// **********************************************************************

LONG __cdecl LSYS_StopModule ()
{
  if (Diamond_Buffer!=NULL)
  {
    Module_Playing = Off;
    IDirectSoundBuffer_Stop(Diamond_Buffer);
  }
//  while (Mutex==FALSE);
//  DeleteCriticalSection(&cs);

	return TRUE;
}

// **********************************************************************
// **********************************************************************

LONG __cdecl LSYS_PauseModule (VOID)
{
	Module_Playing = Off;
	return TRUE;
}

// **********************************************************************
// **********************************************************************

LONG __cdecl LSYS_ResumeModule (VOID)
{
	Module_Playing = On;
	return TRUE;
}

// **********************************************************************
// **********************************************************************

LONG __cdecl LSYS_SetModuleVolume (LONG generalVolume,LONG SfxVolume)
{
	if (generalVolume < 0)
		generalVolume = 0;
	if (generalVolume>64)
		generalVolume = 64;

  if (SfxVolume < 0)
    SfxVolume = 0;
  if (SfxVolume>64)
    SfxVolume = 64;

	Master_Volume = (UBYTE) generalVolume;
  Master_Volume_Sfx = (UBYTE) SfxVolume;
	return TRUE;
}

// **********************************************************************
// **********************************************************************

LONG __cdecl LSYS_GetModulePosition (LONG *position,LONG *patternLine)
{
	*position = (LONG) Index_Pattern_Order;
	*patternLine = (LONG) Current_Note;
	return TRUE;
}

// **********************************************************************
// **********************************************************************

LONG __cdecl LSYS_SetModulePosition (LONG positionNb)
{
	Index_Pattern_Order = (UBYTE) positionNb;
	Current_Note = 0;
	Current_Pattern = Pattern_Order[positionNb];
	return TRUE;
}

// **********************************************************************
// **********************************************************************

LONG __cdecl LSYS_GetModulePositionNumber (VOID)
{
	return (LONG) Song_Lenght;
}

// **********************************************************************
// **********************************************************************

LONG __cdecl LSYS_GetModuleStatus (VOID)
{
  return Module_Playing;
}


// **********************************************************************
// **********************************************************************

void __cdecl Update_Diamond(BOOL AppActive)
{
  LONG                    Current_Position;
  LONG                    Position_Write;
  // ne pas utiliser Position_Write car ne marche
  LONG                    Repeat_Diamond=2;
  // pas avec ma gravis (ou tres mal)
  LONG                    i;
  LONG                    tmp=0,tmp2;
  BYTE                    *Addr1 = NULL;
  DWORD                   Size1;
  BYTE                    *Addr2 = NULL;
  DWORD                   Size2;
  DWORD                   dwStatus;

  if ((Exit==FALSE) & (LS_Module_Init==TRUE) & (Mutex==FALSE))
  {
    Mutex=TRUE;
    IDirectSoundBuffer_GetStatus(Diamond_Buffer, &dwStatus);
    if (DSBSTATUS_BUFFERLOST & dwStatus)
    {
      _asm { int 3 }
      //
      // Restore the buffer, reset some variables, and play it again
      //
      IDirectSoundBuffer_Restore( Diamond_Buffer);
    }

//    EnterCriticalSection(&cs);
    IDirectSoundBuffer_GetCurrentPosition(Diamond_Buffer,(ULONG*)&Current_Position,(ULONG*)&Position_Write);
//    Current_Position=Position_Write;

    if ((LONG)Current_Position-Next_Dma_Value<0)
      tmp=DMA_Size;

    if ((Current_Position-Next_Dma_Value+tmp)>((Repeat_Diamond)*Mixing_Size_Buffer_Full)+16)
    {
      for (i=0;i<Repeat_Diamond;i++)
      {
        if ((AppActive==FALSE) | (Module_Playing==Off))
          ZeroMem (Addr_Buffer_Mixing,Mixing_Size_Buffer*2);
        else
          Process_Diamond();
        IDirectSoundBuffer_Lock(Diamond_Buffer,Next_Dma_Value,Mixing_Size_Buffer_Full,&Addr1,&Size1,&Addr2,&Size2,0L);
        Mix_Data(Addr1,Size1,Addr2,Size2);
        IDirectSoundBuffer_Unlock(Diamond_Buffer,Addr1,Size1,Addr2,Size2);
        if ((Next_Dma_Value+=Mixing_Size_Buffer_Full)>=DMA_Size)
          Next_Dma_Value-=DMA_Size;
      }
    }
    Mutex=FALSE;
  }
//  LeaveCriticalSection(&cs);
}

// **********************************************************************
// **********************************************************************
VOID __cdecl LSYS_Set_Real_Stereo (BOOL val)
{
  if ( val==TRUE )
    Mixing_Real_Stereo=On;
  else
    Mixing_Real_Stereo=Off;
}