
/*
 * Font Function
 *
 * Version 0.1
 * Copyright 1997 Thomas MANGIN
 */

#ifndef EOS_FONT_H
#define EOS_FONT_H

// Remove if you want to diffuse only the obj and the Include file
#include "eos.h"
// End of remove

#ifndef __EOS_H__
#  error You *MUST* use the EOS if you want to be able
#  error to use this shit of code in Vesa mode
#endif

/* 0 -> No Vesa used    */
/* 1 -> Vesa 1.x used   */
/* 2 -> Vesa 2.x used   */

/* Set default value of the Global variable */

#ifndef FONT_VESA_VERSION
#  pragma message ("FONT_VESA_VERSION set by default to 1")
#  define FONT_VESA_VERSION 1
#endif

#ifndef FONT_SCREEN_SIZE
#  pragma message ("FONT_SCREEN_SIZE  set by default to 320")
#  define FONT_SCREEN_SIZE 320
#endif

/*Documentation */

/* print_screen_size  : set the screen size. Needed before any 'drawing' call */
/* print_vesa_version : to allow me to do a bank switch in vesa 1.0           */
/* print_vesa_memory  : set the vesa memory for vesa 2.0 only                 */
/* print_goto_x       : change the 'cursor' position                          */
/* print_goto_y
/* print_goto_xy
/* print_color        : change the text color                                 */
/* print_char         : print a char at setted position and goto next position*/
/* print_text         : print a ASCIIZ string                                 */
/* print_hex          : print a number in hexa with minimum x character       */
/* print_dec          : print a number in hexa with minimum x character       */

/* Prototype */

void print_screen_size (unsigned short size);
void print_vesa_version (unsigned short version);
void print_vesa_memory (char* memory);
void print_goto_x (unsigned short pos_x);
void print_goto_y (unsigned short pos_y);
void print_goto_xy (unsigned short pos_x, unsigned short pos_y);
void print_color (char color);
void print_char (char car);
void print_text (char* text);
void print_hex (unsigned char size, signed long number);
void print_dec (unsigned char size, signed long number);

#endif