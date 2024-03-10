#include <stdio.h>
#include <stdlib.h>
#include <i86.h>

#include "eos.h"

typedef union
{
  struct
  {
      unsigned long edi;
      unsigned long esi;
      unsigned long ebp;
      unsigned long res;
      unsigned long ebx;
      unsigned long edx;
      unsigned long ecx;
      unsigned long eax;
  } x;

  struct
  {
     unsigned short di,  di_hi;
     unsigned short si,  si_hi;
     unsigned short bp,  bp_hi;
     unsigned short res, res_hi;
     unsigned short bx,  bx_hi;
     unsigned short dx,  dx_hi;
     unsigned short cx,  cx_hi;
     unsigned short ax,  ax_hi;

     unsigned short flags;
     unsigned short es;
     unsigned short ds;
     unsigned short fs;
     unsigned short gs;
     unsigned short ip;
     unsigned short cs;
     unsigned short sp;
     unsigned short ss;
  } w;

  struct
  {
      unsigned char edi[4];
      unsigned char esi[4];
      unsigned char ebp[4];
      unsigned char res[4];
      unsigned char bl, bh, bl_hi, bh_hi;
      unsigned char dl, dh, dl_hi, dh_hi;
      unsigned char cl, ch, cl_hi, ch_hi;
      unsigned char al, ah, al_hi, ah_hi;
  } h;
} dpmi_regs_t;

char* Font_ROM;

int dpmi_int (unsigned short vector, dpmi_regs_t *regs)
{
    union REGS r;
    struct SREGS sr;

    segread(&sr);
    //sr.es = sr.ds;
    r.w.ax  = 0x300;
    r.h.bl  = vector;
    r.h.bh  = 0;
    r.w.cx  = 0;
    r.x.edi = (unsigned long)regs;
    int386x(0x31,&r,&r,&sr);

    return regs->w.flags;
}


void main (void)
{
   int x,y;
   dpmi_regs_t r;

   init_eos(_psp);
   debug_back();

   r.w.ax = 0x1130;
   r.h.bh = 0x3;
   dpmi_int(0x10,&r);

   printf("/* Saving Font located at adress : %x:%x */\n",r.w.es,r.w.bp);

   Font_ROM = (char*) ((r.w.es<<4) + r.w.bp);

   printf("char Font_Data [256][8] = {\n");
   for(y=0; y<256; y++)
   {
      switch (y)
      {
         case 0x09:
            printf("/* %03d 0x%02x [\\t] */ {",y,y);
            break;
         case 0x0A:
            printf("/* %03d 0x%02x [\\n] */ {",y,y);
            break;
         case 0x0D:
            printf("/* %03d 0x%02x [\\r] */ {",y,y);
            break;
         default:
            printf("/* %03d 0x%02x [%c]  */ {",y,y,y);
            break;
      }

      for(x=0; x<8; x++)
      {
         printf(" 0x%02x",Font_ROM[y*8+x]);
         if(x != 7)
            printf(",");
      }
      printf(" }");
      if (y != 255)
         printf(",");
      printf("\n");
   }
   printf("};\n");
}