
/*
 * Font Function
 *
 * Version 0.1
 * Copyright 1997 Thomas MANGIN
 */

#include <i86.h>
#include <assert.h>
#include "font.h"
#include "font.dat"

#define FONT_BIG_NUMBER   50
const char* Hex_Table = "0123456789ABCDEF";

unsigned short Font_Screen_Size  = FONT_SCREEN_SIZE;
unsigned short Font_Vesa_Version = FONT_VESA_VERSION;
char           Font_Color        = 1;
unsigned short Font_X            = 0;
unsigned short Font_Y            = 0;
unsigned short Is_Selector_init  = 0;
selector_t     Font_Vesa_Selector= 0;
char*          Font_Vesa_Memory  = 0;
/* Internal functions */

void print_pixel_offset (unsigned long offset)
{
   if(Font_Vesa_Version < 2)
   {
      if(Font_Screen_Size>=640)
         offset &=0xFFFF;
      (*((char*)(0xA0000+offset))) = Font_Color;
   }
   else
   {
      if (Font_Vesa_Memory == 0)
         exit_error("    þ Cannot found VESA 2.x linear frame buffer \0xa \0xd $");
      Font_Vesa_Memory[offset] = Font_Color;
   }
}

void print_number (unsigned char size, unsigned char base, signed long number)
{
   signed short   pos_text;
   char           letter;
   char           final[FONT_BIG_NUMBER];
   char*          printed;

   pos_text = size;
   final[size+1] = '\0';

   if(number < 0)
   {
      final[0]='-';
      number = -number;
      printed = final;
   }
   else
   {
      final[0]=' ';
      printed = final+1;
   }

   while (pos_text > 0 || number != 0)
   {
      letter = number - ((number /base) * base);
		number = number / base;
      final[pos_text] = Hex_Table[letter];
      pos_text --;
   }

   print_text(printed);
}

/* Public functions */

void print_screen_size (unsigned short size)
{
   if(Font_Vesa_Version == 0)
      if(size>=640)
         exit_error("    þ print_screen_size failed size too big \0xa \0xd $");
   Font_Screen_Size = size;
}

void print_vesa_version (unsigned short version)
{
   Font_Vesa_Version = version;
}

void print_vesa_memory (char* memory)
{
   Font_Vesa_Memory = memory;
}
void print_goto_x (unsigned short pos_x)
{
   Font_X = pos_x;
}

void print_goto_y (unsigned short pos_y)
{
   Font_Y = pos_y;
}

void print_goto_xy (unsigned short pos_x, unsigned short pos_y)
{
   print_goto_x(pos_x);
   print_goto_y(pos_y);
}

void print_color (char color)
{
   Font_Color = color;
}

void print_char (char car)
{
   unsigned short index_x, index_y;
   unsigned long  offset;
   char           masque;

   for (index_y=0; index_y<8; index_y++)
   {
      masque = Font_Data[car][index_y];
      offset = (Font_Y+index_y)*Font_Screen_Size+Font_X;
      for(index_x=0; index_x<8; index_x++, masque <<= 1)
         if(masque & 0x80)
         {
            if(Font_Vesa_Version == 1)
               if(Font_Screen_Size >= 640)
                  set_bank((offset+index_x)>>16);
            print_pixel_offset(offset+index_x);
         }
   }

   Font_X+=8;
   if(Font_X > Font_Screen_Size-8)
   {
      Font_X-=Font_Screen_Size;
      Font_Y+=8;
   }
}

void print_text (char* text)
{
   while (*text != '\0')
      print_char(*(text++));
}

void print_hex (unsigned char size, signed long number)
{
   print_number(size,16,number);
}

void print_dec (unsigned char size, signed long number)
{
   print_number(size,10,number);
}