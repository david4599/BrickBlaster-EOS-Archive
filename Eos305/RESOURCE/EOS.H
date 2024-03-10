
/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º EOS.H   (Tabs : 13 21 29 37)                                             º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/

#ifndef __EOS_H__
#define __EOS_H__


#define OFF 0
#define ON  1

#define RAW         0x01
#define XMS         0x02
#define VCPI        0x04
#define DPMI        0x08


#ifdef __cplusplus
extern "C"
{
#endif

#ifndef bool_t
typedef long bool_t;
#endif



typedef unsigned short selector_t;

#define asm_mov_ah 0xb4
#define Int_EOS 0xcd 0x61

#define Exit_Error                    0x01
#define Use_Int_08                    0x02
#define Change_Synchro_Int_08         0x03
#define Use_Int_09                    0x04
#define Restore_Video_Mode            0x07
#define Detect_Windows                0x0A
#define Direct_Send                   0x0E
#define Load_Internal_File            0x10
#define Load_External_File            0x11
#define Load_Internal_File_Handle     0x12
#define Load_External_File_Handle     0x13
#define Write_External_File           0x14
#define Wait_Vbl                      0x20
#define Get_Nb_Vbl                    0x21
#define Detect_Sound_Card             0x30
#define Load_Module                   0x32
#define Play_Module                   0x34
#define Stop_Module                   0x35
#define Clear_Module                  0x36
#define Manual_Setup                  0x37
#define Set_Volume                    0x3a
#define Play_Sample                   0x3b
#define Get_Info                      0x3e
#define Set_Pattern                   0x3f
#define DeAllocate_Memory             0x41
#define DeAllocate_Memory_Handle      0x43
#define Allocate_Selector             0x45
#define DeAllocate_Selector           0x46
#define Physical_Address_Mapping      0x47
#define Free_Physical_Address_Mapping 0x48
#define Set_Mono                      0xe0
#define Set_String_Mono               0xe1
#define Set_Value_Mono                0xe2

/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º EOS Functions                                                            º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/


/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º                                System                                    º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Exit Error   Restore initial Video mode , interrupts , free all reserved  ³
  ³             memory ,stop music if played and exit (with error code 1)    ³
  ³             with a error message                                         ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void exit_error(char *msg_error);
#pragma aux exit_error parm [edx] modify [eax] = \
   asm_mov_ah Exit_Error \
   Int_EOS;

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Use Int 08   Use Int 08 (IRQ 0) to count frame rate and have a stable     ³
  ³             vertical retrace                                             ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void use_int_08(long value);
#pragma aux use_int_08 modify [eax] parm [ebx] = \
   asm_mov_ah Use_Int_08 \
   Int_EOS;


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Change Synchro Int 08   Change frequency for Interupt 08                  ³
  ³                        Defaults frequency is 70Hz                        ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void change_synchro_int_08(short value);
#pragma aux change_synchro_int_08 modify [eax] parm [ebx] = \
   asm_mov_ah Change_Synchro_Int_08 \
   Int_EOS;


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Use Int 09   Use Internal Keyboard handler to use keyboard                ³
  ³             return address of the array of 128 char                      ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
typedef struct keyboard_ {
  unsigned char all;
  unsigned char scancodes[127];
}keyboard_t;

keyboard_t* use_int_09(long value);
#pragma aux use_int_09 modify [eax] parm [ebx] value [eax] = \
   asm_mov_ah Use_Int_09 \
   Int_EOS;


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Restore Video Mode   Restore the inital video which is be active at the   ³
  ³                     start of the program                                 ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void restore_video_mode();
#pragma aux restore_video_mode modify [eax] = \
   asm_mov_ah Restore_Video_Mode \
   Int_EOS;


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Detect Windows       Detect If Windows is running                         ³
  ³                                                                          ³
  ³Other Registers Change : None                                             ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
#define WINDOWS_3X           3
#define WINDOWS_95           4
unsigned char detect_windows();
#pragma aux detect_windows modify [eax] value [al] = \
   asm_mov_ah Detect_Windows \
   Int_EOS;


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Direct Send          Write a text directly to video ram . Color allowed   ³
  ³                                                                          ³
  ³Command : 0,0      = end                                                  ³
  ³          0,1..255 = color                                                ³
  ³          13       = first colonne                                        ³
  ³          10       = next ligne                                           ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void direct_send(char *msg);
#pragma aux direct_send modify [eax edx] parm [edx] = \
   asm_mov_ah Direct_Send \
   Int_EOS;



/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º                                 Files                                    º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Load Internal file   Load a file which is link with LLINK                 ³
  ³                     if the file is not present the program stop and      ³
  ³                     display a error message                              ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
char *load_internal_file(char *file_name,long *size_file);
#pragma aux load_internal_file modify [eax ecx edx esi edi] value [eax] parm [edx] [ecx] =\
   " push ecx " \
   asm_mov_ah Load_Internal_File \
   Int_EOS \
   " pop edx " \
   " mov [edx],ecx " \
   " mov eax,esi ";

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Load Internal file Handle  Load a file which is link with LLINK           ³
  ³                           if the file is not present the program stop    ³
  ³                           and display a error message                    ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
char *load_internal_file_handle(char *file_name,long *size_file,long *handle_file);
#pragma aux load_internal_file_handle modify [eax ecx edx esi edi] value [eax] parm [edx] [ecx] [edi] =\
   " push ecx " \
   " push edi " \
   asm_mov_ah Load_Internal_File_Handle \
   Int_EOS \
   " pop edx " \
   " mov [edx],edi " \
   " pop edx " \
   " mov [edx],ecx " \
   " mov eax,esi ";

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Load External file   Load a external file and uncompress it if it has     ³
  ³                     been compress with Diet 1.44                         ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
char *load_external_file(char *file_name,long *size_file);
#pragma aux load_external_file modify [eax ecx edx esi edi] value [eax] parm [edx] [ecx] =\
   " push ecx" \
   asm_mov_ah Load_External_File \
   Int_EOS \
   " pop edx" \
   " mov [edx],ecx" \
   " mov eax,esi" \
   " jnc no_error" \
   " xor eax,eax" \
   "no_error:";


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Load External file Handle  Load a external file and uncompress it if it   ³
  ³                           has been compress with Diet 1.44               ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
char *load_external_file_handle(char *file_name,long *size_file,long *handle_file);
#pragma aux load_external_file_handle "_Load_External_File_Handle" modify [eax ecx edx esi edi] value [eax] parm [edx] [ecx] [edi] =\
   " push ecx " \
   " push edi " \
   asm_mov_ah Load_External_File_Handle \
   Int_EOS \
   " pop edx " \
   " mov [edx],edi " \
   " pop edx " \
   " mov [edx],ecx " \
   " mov eax,esi " \
   " jnc no_error " \
   " xor eax,eax" \
   "no_error:";


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Write External File  Save a File on a Disk                                ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long write_external_file(char *file_name,long *addr_file,long size_file);
#pragma aux write_external_file modify [eax ebx ecx edx esi edi] value [eax] parm [edx] [esi] [ecx] =\
   asm_mov_ah Write_External_File \
   Int_EOS \
   "jnc no_error " \
   "xor eax,eax" \
   "no_error:";


/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º                           Memory Allocation                              º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³DeAllocate Memory Handle  Free the last allocate memory                   ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void deallocate_memory();
#pragma aux deallocate_memory modify [eax] = \
   asm_mov_ah DeAllocate_Memory \
   Int_EOS;


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³DeAllocate Memory Handle  Free the allocate memory with this handle       ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void deallocate_memory_handle(long handle_memory);
#pragma aux deallocate_memory_handle modify [eax edi] parm [edi] = \
   asm_mov_ah DeAllocate_Memory_Handle \
   Int_EOS;


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Allocate Selector   Create a new selector                                 ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
selector_t allocate_selector(char* vram_addr, long vram_size);
#pragma aux allocate_selector modify [eax ebx esi edi] parm [esi] [edi] value [bx] = \
   asm_mov_ah Allocate_Selector \
   Int_EOS \
   "jnc no_error" \
   "xor bx,bx" \
   "no_error:";


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³DeAllocate Selector       Free a selector                                 ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long deallocate_selector(selector_t selector);
#pragma aux deallocate_selector modify [eax ebx] parm [ebx] value [ebx] =\
   asm_mov_ah DeAllocate_Selector \
   Int_EOS \
   "jnc no_error" \
   "xor ebx,ebx" \
   "no_error:";



/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º                              Synchronization                             º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Wait Vbl   Wait the vertical retrace                                      ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long wait_vbl();
#pragma aux wait_vbl modify [eax] value [eax] =\
   asm_mov_ah Wait_Vbl \
   Int_EOS;

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Get Nb Vbl Return the number of VBL Without waiting the VBL               ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long get_nb_vbl();
#pragma aux get_nb_vbl modify [eax] value [eax] =\
   asm_mov_ah Get_Nb_Vbl \
   Int_EOS;



/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º                              Diamond Player                              º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/
#define  NO_CARD    0x00
#define  SB_10      0x01
#define  SB_15      0x02
#define  SB_20      0x03
#define  SB_PRO     0x04
#define  SB_16      0x05
#define  SB_AWE     0x06
#define  GRAVIS     0x10
#define  GRAVIS_MAX 0x11
#define  GRAVIS_ACE 0x12
#define  GRAVIS_PNP 0x13
#define  WSS        0x20

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Detect Sound Card   Detect with the environment variable the sound        ³
  ³                    card installed                                        ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
int detect_sound_card(int display,int *port,int *irq,int *dma,int *infos);
#pragma aux detect_sound_card modify [eax ebx ecx edx esi edi] parm [ecx] [ebx] [edx] [esi] [edi] =\
   " push ebx " \
   " push edx " \
   " push esi " \
   " push edi " \
   asm_mov_ah Detect_Sound_Card \
   Int_EOS \
   " pop edi " \
   " mov [edi],esi " \
   " pop edi " \
   " mov [edi],edx " \
   " pop edi " \
   " mov [edi],ecx " \
   " pop edi " \
   " mov [edi],ebx ";


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Load Module   Load a module & initialize into the memory                  ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
bool_t load_module(char *file_name,unsigned char type,int replay,int sfx_channel);
#pragma aux load_module modify [eax ebx ecx edx esi edi] value [eax] parm [edx] [eax] [ebx] [ecx] =\
   asm_mov_ah Load_Module \
   Int_EOS \


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Play Module   Start playing the module                                    ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void play_module();
#pragma aux play_module modify [eax] =\
   asm_mov_ah Play_Module \
   Int_EOS;



/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Stop Module   Stop playing the module                                     ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void stop_module();
#pragma aux stop_module modify [eax] =\
   asm_mov_ah Stop_Module \
   Int_EOS;



/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Clear Module   Unload the module from memory                              ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void clear_module();
#pragma aux clear_module modify [eax] =\
   asm_mov_ah Clear_Module \
   Int_EOS;



/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Set Volume   Set the master volume of the module                          ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void set_volume(unsigned char volume,unsigned char sfx_volume);
#pragma aux set_volume modify [eax ecx edx] parm [cl] [dl] =\
   asm_mov_ah Set_Volume \
   Int_EOS;


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Play Sample   Play a sample include into the module                       ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void play_sample(int num_sample,int frequence,int voice);
#pragma aux play_sample modify [eax ebx ecx edx] parm [ebx] [ecx] [edx] =\
   asm_mov_ah Play_Sample \
   Int_EOS;



/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Get Info   Get information about the module when playing                  ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void get_info(unsigned char *position,unsigned char *pattern,unsigned char *note,unsigned char *volume,unsigned char *sfx_volume);
#pragma aux get_info modify [eax ebx ecx edx esi] parm [eax] [ebx] [ecx] [edx] [esi] =\
   " push eax " \
   " push ebx " \
   " push ecx " \
   " push edx " \
   " push esi " \
   asm_mov_ah Get_Info \
   Int_EOS \
   " pop esi " \
   " mov [esi],dl " \
   " pop esi " \
   " mov [esi],cl " \
   " pop esi " \
   " mov [esi],bl " \
   " pop esi " \
   " mov [esi],al " \
   " pop esi " \
   " mov [esi],ah ";


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Set Pattern  Set the current position of the playing module               ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void set_pattern(int position,int note);
#pragma aux set_pattern parm [ebx] [ecx] modify [eax ecx edx] =\
   asm_mov_ah Set_Pattern \
   Int_EOS;




/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º Monochrome display                                                       º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Set Mono   Force On/Off the display of all the Monochrome Function        ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void set_mono(unsigned char value);
#pragma aux set_mono parm [ebx] modify [eax] =\
   asm_mov_ah Set_Mono \
   Int_EOS;



/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Set String Mono   Display a string on the Monochrome adapter              ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void set_string_mono(char *msg,int x,int y);
#pragma aux set_string_mono parm [edx] [ebx] [ecx] modify [eax ebx ecx edx] =\
   asm_mov_ah Set_String_Mono \
   Int_EOS;



/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Set Value Mono   Display A Word in Hexadecimal on the Monochrome adapter  ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void set_value_mono(long value,int x,int y);
#pragma aux set_value_mono parm [edx] [ebx] [ecx] modify [eax ebx ecx edx] =\
   asm_mov_ah Set_Value_Mono \
   Int_EOS;



/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º EOS Library                                                              º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/


/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º VESA                                                                     º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/

/* ------------ VBE v1.0  ------------------ */
#define Mode640x400x256             0x100
#define Mode640x480x256             0x101
#define Mode800x600x16              0x102
#define Mode800x600x256             0x103
#define Mode1024x768x16             0x104
#define Mode1024x768x256            0x105
#define Mode1280x1024x16            0x106
#define Mode1280x1024x256           0x107
#define Mode80x60                   0x108
#define Mode132x25                  0x109
#define Mode132x43                  0x10a
#define Mode132x50                  0x10b
#define Mode132x60                  0x10c
/* ------------ VBE v1.2+ ------------------ */
#define Mode320x200x32k             0x10d
#define Mode320x200x64k             0x10e
#define Mode320x200x16M             0x10f
#define Mode640x480x32k             0x110
#define Mode640x480x64k             0x111
#define Mode640x480x16M             0x112
#define Mode800x600x32k             0x113
#define Mode800x600x64k             0x114
#define Mode800x600x16M             0x115
#define Mode1024x768x32k            0x116
#define Mode1024x768x64k            0x117
#define Mode1024x768x16M            0x118
#define Mode1280x1024x32k           0x119
#define Mode1280x1024x64k           0x11a
#define Mode1280x1024x16M           0x11b


extern unsigned char  vesa_current_bank;
#pragma aux  vesa_current_bank "Vesa_Current_Bank"

extern unsigned char  vesa_clear_palette;
#pragma aux  vesa_clear_palette "Vesa_Clear_Palette"


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Init Vesa   Initialize A Vesa video mode                                  ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
bool_t init_vesa(int vesa_mode);
#pragma aux init_vesa "Init_Vesa" parm [eax] modify [eax ebx ecx edx esi edi] value [eax]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Init Vesa2  Initialize A Vesa 2.0 Linear FrameBuffer mode                 ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
char *init_vesa2(long vesa_mode,long vesa_size);
#pragma aux init_vesa2 "Init_Vesa2" parm [eax] [ecx] modify [eax ebx ecx edx esi edi] value [eax]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Init Vesa Bank  Init the Automatic Bank Switching                         ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
selector_t init_vesa_bank();
#pragma aux init_vesa_bank "Init_Vesa_Bank" modify [eax ebx ecx edx esi edi] value [bx]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Set Bank   Set the current bank                                           ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void set_bank(long new_bank);
#pragma aux set_bank "Set_Bank" parm [edx]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Next Bank   Set the next bank                                             ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void next_bank();
#pragma aux next_bank "Next_Bank"



/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º FLI32                                                                    º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/

extern char  fli_err;
#pragma aux  fli_err "Fli_Err"
extern char  fli_svga;
#pragma aux  fli_svga "Fli_Svga"
extern char  fli_swap;
#pragma aux  fli_swap "Fli_Swap"
extern char  fli_restart;
#pragma aux  fli_restart "Fli_ReStart"
extern char  fli_loop;
#pragma aux  fli_loop "Fli_Loop"
extern char  fli_trackdisk;
#pragma aux  fli_trackdisk "Fli_TrackDisk"
extern char  fli_last_frame;
#pragma aux  fli_last_frame "Fli_Last_Frame"
extern char  fli_ligne_shl;
#pragma aux  fli_ligne_shl "Fli_Ligne_Shl"
extern short fli_selector;
#pragma aux  fli_selector "Fli_Selector"
extern long  fli_delay;
#pragma aux  fli_delay "Fli_Delay"
extern long  fli_buffer;
#pragma aux  fli_buffer "Fli_Buffer"
extern long  fli_scr_x;
#pragma aux  fli_scr_x "Fli_Scr_X"
extern long  fli_scr_y;
#pragma aux  fli_scr_y "Fli_Scr_Y"
extern long  fli_decal_y;
#pragma aux  fli_decal_y "Fli_Decal_Y"
extern long  fli_decal_x;
#pragma aux  fli_decal_x "Fli_Decal_X"
extern long  fli_current_frame;
#pragma aux  fli_current_frame "Fli_Current_Frame"

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Load_Fli(*adrs_file_name)                                                ³
  ³                                                                          ³
  ³ Cette routine charge et v‚rifie le header d'un fichier FLI ou FLC        ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long load_fli(char *file_name);
#pragma aux load_fli "Load_Fli" modify [eax ebx ecx edx esi edi] value [eax] parm [edx]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ First_Frame_Fli()                                                        ³
  ³                                                                          ³
  ³ Cette routine d‚compresse la premiŠre image d'un fichier FLI ou FLC      ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void first_frame_fli();
#pragma aux first_frame_fli "First_Frame_Fli" modify [eax ebx ecx edx esi edi]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Next_Frame_Fli()                                                         ³
  ³                                                                          ³
  ³ Cette routine d‚compresse la prochaine image d'un fichier FLI ou FLC     ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void next_frame_fli();
#pragma aux next_frame_fli "Next_Frame_Fli" modify [eax ebx ecx edx esi edi]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Dispose_Fli()                                                            ³
  ³                                                                          ³
  ³ Cette routine libŠre la m‚moire allou‚e par la fonction Load_Fli         ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void dispose_fli();
#pragma aux dispose_fli "Dispose_Fli" modify [eax ebx ecx edx esi edi]


/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º SNAP                                                                     º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Snap        Grab a 256 Colors screen in Non-Mode and save it in IFF format³
  ³            Scroll Lock to lunch it                                       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Init Snap   Initialize the screen grabber . (You can change the int 09    ³
  ³            function Use_Int_09 after this Init                           ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void init_snap();
#pragma aux init_snap "Init_Snap"

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Snap IFF    Grab the current Screen from Video RAM                        ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void snap_iff();
#pragma aux snap_iff "Snap_Iff"

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Save IFF    Save a buffer to IFF                                          ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void save_iff(int x,int y,char *file_name,char *addr_file);
#pragma aux save_iff "Save_Iff" parm [eax] [ebx] [edx] [esi] modify [eax ebx edx esi]


/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º JOYSTICK                                                                 º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/

#define ANALOG_A          0x1
#define ANALOG_B          0x2
#define LPT_A             0x10
#define LPT_B             0x20

#define LPT1              0x1
#define LPT2              0x2
#define LPT3              0x3
#define LPT4              0x4

typedef struct joy_ {
  unsigned char j_type;
  unsigned short j_addr;
  long j_value_x;
  long j_value_y;
  long j_min_x;
  long j_max_x;
  long j_min_y;
  long j_max_y;
  long j_center_x;
  long j_center_y;
  long j_calibrate_left;
  long j_calibrate_right;
  long j_calibrate_up;
  long j_calibrate_down;
  unsigned char j_current_left;
  unsigned char j_current_right;
  unsigned char j_current_up;
  unsigned char j_current_down;
  unsigned char j_fire_1;
  unsigned char j_fire_2;
  unsigned char j_fire_3;
  unsigned char j_fire_4;
}joy_t;

extern struct joy_ joy1;
#pragma aux  joy1 "joy1"
extern struct joy_ joy2;
#pragma aux  joy2 "joy2"
extern struct joy_ joy3;
#pragma aux  joy3 "joy3"
extern struct joy_ joy4;
#pragma aux  joy4 "joy4"
extern struct joy_ joy5;
#pragma aux  joy5 "joy5"
extern struct joy_ joy6;
#pragma aux  joy6 "joy6"


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Init_Joystick  Init all port                                              ³
  ³                                                                          ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void init_joystick();
#pragma aux init_joystick "Init_Joystick" modify [eax ebx ecx edx esi edi]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Dectect_Joystick  Find if a analogic joystick is plug in port 1 ,2 or Both³
  ³                                                                          ³
  ³Out :        NULL No joystick                                             ³
  ³             1    A joystick is plug in port 1                            ³
  ³             2    A joystick is plug in port 2                            ³
  ³             3    2 joystick is plug in port 1 and 2                      ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long detect_joystick();
#pragma aux detect_joystick "Detect_Joystick" modify [eax ebx ecx edx esi edi] value [eax]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Add_Joystick                  Add a new joystick to be use by the library ³
  ³                                                                          ³
  ³In :                                                                      ³
  ³        Type Of joystick                                                  ³
  ³             ANALOG_A                                                     ³
  ³             ANALOG_B                                                     ³
  ³             LPT_A                                                        ³
  ³             LPT_B                                                        ³
  ³        Address of port                                                   ³
  ³             LPT1                                                         ³
  ³             LPT2                                                         ³
  ³             LPT3                                                         ³
  ³             LPT4                                                         ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³           NULL No Joystick Available                                     ³
  ³           or   Address of structure of joystick                          ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
joy_t *add_joystick(long type,long port);
#pragma aux add_joystick "Add_Joystick" modify [eax ebx ecx edx esi edi] value [esi] parm [eax] [ebx]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Update_Joystick  Must be call often update all structure of all Joystick  ³
  ³                 declare with Add_Joystick                                ³
  ³                                                                          ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void update_joystick();
#pragma aux update_joystick "UpDate_Joystick" modify [eax ebx ecx edx esi edi]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Sub_Joystick   Delete a Joystick create by Add_Joystick                   ³
  ³                                                                          ³
  ³In :                                                                      ³
  ³           Address of structure to be delete                              ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³           NULL Structure not found                                       ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long sub_joystick(joy_t* joy);
#pragma aux sub_joystick "Sub_Joystick" modify [eax ebx ecx edx esi edi] parm [esi] value [eax]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Upper_Left     Take Value For Upper Left Joystick's Coordonate            ³
  ³                                                                          ³
  ³In :                                                                      ³
  ³           Address of structure                                           ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³           NULL No fire press                                             ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long upper_left(joy_t* joy);
#pragma aux upper_left "Upper_Left" modify [eax ebx ecx edx esi edi] parm [esi] value [eax]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Lower_Right    Take Value For Lower Right Joystick's Coordonate           ³
  ³                                                                          ³
  ³In :                                                                      ³
  ³           Address of structure                                           ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³           NULL No fire press                                             ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long lower_right(joy_t* joy);
#pragma aux lower_right "Lower_Right" modify [eax ebx ecx edx esi edi] parm [esi] value [eax]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Center         Take Value For Center Joystick's Coordonate                ³
  ³                                                                          ³
  ³In :                                                                      ³
  ³           Address of structure                                           ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³           NULL No fire press                                             ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long center(joy_t* joy);
#pragma aux center "Center" modify [eax ebx ecx edx esi edi] parm [esi] value [eax]


/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º MEMORY                                                                   º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Init_Memory    Turn the display memory on                                 ³
  ³                                                                          ³
  ³In :                                                                      ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³                                                                          ³
  ³Other Registers Change : None                                             ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void init_memory();
#pragma aux init_memory "Init_Memory"


/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º RS232                                                                    º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/

#define COM_1             0x3F8   /* base port address of port 0 */
#define COM_2             0x2F8   /* base port address of port 1 */

#define SER_BAUD_300      384     /*    300 bauds */
#define SER_BAUD_1200     96      /*   1200 bauds */
#define SER_BAUD_2400     48      /*   2400 bauds */
#define SER_BAUD_4800     24      /*   4800 bauds */
#define SER_BAUD_9600     12      /*   9600 bauds */
#define SER_BAUD_14400    8       /*  14400 bauds */
#define SER_BAUD_19200    6       /*  19200 bauds */
#define SER_BAUD_28800    4       /*  28800 bauds */
#define SER_BAUD_38400    3       /*  38400 bauds */
#define SER_BAUD_57600    2       /*  57600 bauds */
#define SER_BAUD_115200   1       /* 115200 bauds */

#define SER_STOP_1        0       /* 1 stop bit per character */
#define SER_STOP_2        4       /* 2 stop bits per character */

#define SER_BITS_5        0       /* send 5 bit characters */
#define SER_BITS_6        1       /* send 6 bit characters */
#define SER_BITS_7        2       /* send 7 bit characters */
#define SER_BITS_8        3       /* send 8 bit characters */

#define SER_PARITY_NONE   0       /* no parity */
#define SER_PARITY_ODD    8       /* odd parity */
#define SER_PARITY_EVEN   24      /* even parity */

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Open(COM_1,SER_BAUD_9600,SER_PARITY_NONE | SER_BITS_8 | SER_STOP_1³
  ³             ,taille buffer) -> NULL or Circular buffer address           ³
  ³                                                                          ³
  ³ this function sets the serial port up.                                   ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
char *serial_open(long port_base,long baud,long configuration,long taille_buffer);
#pragma aux serial_open "Serial_Open" modify [eax ebx ecx edx esi edi] parm [edx] [eax] [ecx] [edi] value [eax]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Close()                                                           ³
  ³                                                                          ³
  ³ This procedure closes the serial port.                                   ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void serial_close();
#pragma aux serial_close "Serial_Close" modify [eax ebx ecx edx esi edi]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Read()                                                            ³
  ³                                                                          ³
  ³ This procedue reads a character in the circular buffer                   ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
char serial_read();
#pragma aux serial_read "Serial_Read" modify [eax ebx ecx edx esi edi] value [al]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Read_Block(char *buffer,long size)                                ³
  ³                                                                          ³
  ³                                                                          ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void serial_read_block(char *buffer,long size);
#pragma aux serial_read_block "Serial_Read_Block" modify [eax ebx ecx edx esi edi] parm [edi] [ecx] value [eax]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Write(caractŠre) -> TRUE ou FALSE                                 ³
  ³                                                                          ³
  ³ This procedure sends characters.                                         ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long serial_write(char data);
#pragma aux serial_write "Serial_Write" modify [eax ebx ecx edx esi edi] parm [ebx] value [eax]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Write_Block(char *Block,long Size) -> TRUE ou FALSE               ³
  ³                                                                          ³
  ³                                                                          ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long serial_write_block(char *Block,long Size);
#pragma aux serial_write_block "Serial_Write_Block" modify [eax ebx ecx edx esi edi] parm [esi] [ecx] value [eax]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Clear_Buffer()                                                    ³
  ³                                                                          ³
  ³ This procedure clears the circular buffer.                               ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void serial_clear_buffer();
#pragma aux serial_clear_buffer "Serial_Clear_Buffer" modify [eax ebx ecx edx esi edi]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Status()                                                          ³
  ³                                                                          ³
  ³ This procedure gets the status of the modem.                             ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
char serial_status();
#pragma aux serial_status "Serial_Status" modify [eax ebx ecx edx esi edi] value [al]

      /*    7    6     5     4      3     2      1      0
        ÚÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄ¿
        ³ DCD ³ RI ³ DSR ³ CTS ³ dDCD ³ dRI ³ dDSR ³ dCTS ³
        ÀÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÙ

        Bit 0 (dCTS): Change in CTS
        Bit 1 (dDSR): Change in DSR
        Bit 2 (dRI): Change in RI
        Bit 3 (dDCD): Change in DCD
        Bit 4 (CTS): Clear To Send. Modem sets this line indicating that
                it is ready for data, after computer indicates that it
                is ready for data with an RTS. It used to be a signal
                that the local modem has connected with a remote modem
                too, in the olden days.
        Bit 5 (DSR): Data Set Ready. This is the completing signal in a
                DTR-DSR pair. Computer sends DTR to modem, saying it
                wants to connect with it. Modem sends DSR back to
                computer, saying that connection has been established.
        Bit 6 (RI): Ring Indicator. Indicates that there is remote modem
                attempting to call your local modem.
        Bit 7 (DCD): Data Carrier Detect. Indicates that the remote
                modem has established connection with local modem.
*/
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Set_Dtr()                                                         ³
  ³                                                                          ³
  ³ sets the DTR bit to 1                                                    ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void serial_set_dtr();
#pragma aux serial_set_dtr "Serial_Set_Dtr" modify [eax ebx ecx edx esi edi]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Reset_Dtr()                                                       ³
  ³                                                                          ³
  ³ sets the DTR bit to 0                                                    ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void serial_reset_dtr();
#pragma aux serial_reset_dtr "Serial_Reset_Dtr" modify [eax ebx ecx edx esi edi]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Set_Rtr()                                                         ³
  ³                                                                          ³
  ³ sets the RTS bit to 1                                                    ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void serial_set_rts();
#pragma aux serial_set_rts "Serial_Set_Rts" modify [eax ebx ecx edx esi edi]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Reset_Rts()                                                       ³
  ³                                                                          ³
  ³ sets the RTS bit to 0                                                    ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
void serial_reset_rts();
#pragma aux serial_reset_rts "Serial_Reset_Rts" modify [eax ebx ecx edx esi edi]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Buffer_Full                                                       ³
  ³                                                                          ³
  ³ sets the RTS bit to 1                                                    ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
extern char serial_buffer_full;
#pragma aux serial_buffer_full "Serial_Buffer_Full"

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ Serial_Stand_By                                                          ³
  ³                                                                          ³
  ³ sets the RTS bit to 0                                                    ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
extern volatile long serial_stand_by;
#pragma aux serial_stand_by "Serial_Stand_By"


/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º CDROM                                                                    º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/

typedef struct track_info {
  unsigned char _adr;
  unsigned char _track;
  unsigned char _index;
  unsigned char _min;
  unsigned char _sec;
  unsigned char _frame;
  unsigned char _zero;
  unsigned char _amin;
  unsigned char _asec;
  unsigned char _aframe;
}track_info_t;

extern struct track_info track_info;
#pragma aux track_info "Track_Info"

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Detect CDROM  Detect is a cdrom is connected to the system using the      ³
  ³              MSCDEX functions                                            ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³       1 = No CDROM detected                                              ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long detect_cdrom();
#pragma aux detect_cdrom "Detect_CDROM" modify [eax ebx ecx edx esi edi] value [eax]

extern int first_cdrom;
#pragma aux first_cdrom "First_CDROM"
extern int number_cdrom;
#pragma aux number_cdrom "Number_CDROM"
extern int version_mscdex;
#pragma aux version_mscdex "Version_MSCDEX"


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Play a Track  Play a track from the CDROM                                 ³
  ³                                                                          ³
  ³In :                                                                      ³
  ³                                                                          ³
  ³       Track number  = 1..xx                                              ³
  ³       Play all      = ON or OFF                                          ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³       1 = Error on playing                                               ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long play_track(long track_number,long play_all);
#pragma aux play_track "Play_Track" modify [eax ebx ecx edx esi edi] value [eax] parm [eax] [ebx]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Open CDROM   Open the CDROM door                                          ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³       1 = Error on command                                               ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long open_cdrom();
#pragma aux open_cdrom "Open_CDROM" modify [eax ebx ecx edx esi edi] value [eax]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Close CDROM   Close the CDROM door                                        ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³       1 = Error on command                                               ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long close_cdrom();
#pragma aux close_cdrom "Close_CDROM" modify [eax ebx ecx edx esi edi] value [eax]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Stop CDROM stop the music from the CDROM                                  ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³       1 = Error on command                                               ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long stop_cdrom();
#pragma aux stop_cdrom "Stop_CDROM" modify [eax ebx ecx edx esi edi] value [eax]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Resume CDROM  Resume the music from the CDROM                             ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³       1 = Error on command                                               ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long resume_cdrom();
#pragma aux resume_cdrom "Resume_CDROM" modify [eax ebx ecx edx esi edi] value [eax]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Get Nb Tracks Get the number of Tracks in the CDROM                       ³
  ³              (Will also reload all the database all track a bit slow)    ³
  ³Out :                                                                     ³
  ³       1 = Error on command                                               ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long get_nb_tracks();
#pragma aux get_nb_tracks "Get_Nb_Tracks" modify [eax ebx ecx edx esi edi] value [eax]

extern long track_nbs;
#pragma aux track_nbs "Track_Nbs"


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Get Track Info  Get the Track info on the CDROM                           ³
  ³                                                                          ³
  ³In :                                                                      ³
  ³       Track number = 1..xx                                               ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³       1 = Error on command                                               ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long get_track_info(long track_number);
#pragma aux get_track_info "Get_Track_Info" modify [eax ebx ecx edx esi edi] value [eax] parm [eax]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Get Current Track Info  Get the current Track info on the CDROM           ³
  ³                                                                          ³
  ³Out :                                                                     ³
  ³       1 = Error on command                                               ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
long get_current_track_info();
#pragma aux get_current_track_info "Get_Current_Track_Info" modify [eax ebx ecx edx esi edi] value [eax]



/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º GIF                                                                      º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/

extern long gif_handle;
#pragma aux gif_handle "gif_handle"
extern unsigned short gif_x;
#pragma aux gif_x "gif_x"
extern unsigned short gif_y;
#pragma aux gif_y "gif_y"
extern char *gif_palette;
#pragma aux gif_palette "gif_palette"

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ char *Load_External_Gif_Handle(*adrs_file_name)                          ³
  ³                                                                          ³
  ³ Cette routine charge et d‚compresse un fichier (compression GIF) et      ³
  ³ retourne un pointeur sur le fichier d‚compresse si la requˆte a          ³
  ³ pu ˆtre satisfaite ou NULL si elle n'a pu ˆtre honor‚e                   ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
char *load_external_gif_handle(char *File_Name);
#pragma aux load_external_gif_handle "Load_External_Gif_Handle" modify [eax ebx ecx edx esi edi] value [eax] parm [edx]


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                                                                          ³
  ³ char *Load_Internal_Gif_Handle(*adrs_file_name)                          ³
  ³                                                                          ³
  ³ Cette routine charge et d‚compresse un fichier (compression GIF) et      ³
  ³ retourne un pointeur sur le fichier d‚compresse si la requˆte a          ³
  ³ pu ˆtre satisfaite ou NULL si elle n'a pu ˆtre honor‚e                   ³
  ³                                                                          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
char *load_internal_gif_handle(char *File_Name);
#pragma aux load_internal_gif_handle "Load_Internal_Gif_Handle" modify [eax ebx ecx edx esi edi] value [eax] parm [edx]


/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º The 32bit debugger                                                       º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/

void debug();
#pragma aux debug "Debug"
void debug_back();
#pragma aux debug_back "Debug_Back"

void break_point();
#pragma aux break_point = "int 3";

/*ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  º                                                                          º
  º The EOS Emulation when using WATCON                                      º
  º                                                                          º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼*/

void init_eos(unsigned __near psp);
#pragma aux init_eos "Init_EOS" parm [ebx]

#ifdef __cplusplus
};
#endif

#endif