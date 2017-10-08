#ifndef _INPUT_H_
#define _INPUT_H_

#include "port.h"


#define RFFT_MIN_LENGTH 8
#define RFFT_MAX_LENGTH 2048

#define RIFFT_MIN_LENGTH RFFT_MIN_LENGTH
#define RIFFT_MAX_LENGTH RFFT_MAX_LENGTH


/*-------------*/
/* CFFT Tables */
/*-------------*/
/* Test case covering N = 8, 16, 32, 64, 128, 256, 1024,
   and 2048 */ 

EXPORT const CFrac16 pX_input[];
    
    
/*-------------*/
/* RFFT Tables */
/*-------------*/

EXPORT const CFrac16 Actual_op_8 [];
EXPORT const CFrac16 Actual_op_16[]; 
EXPORT const CFrac16 Actual_op_32[];
EXPORT const CFrac16 Actual_op_64[];
EXPORT const CFrac16 Actual_op_128[];
EXPORT const CFrac16 Actual_op_256[];
EXPORT const CFrac16 Actual_op_512[];
EXPORT const CFrac16 Actual_op_1024[];
EXPORT const CFrac16 Actual_op_2048[];

EXPORT const CFrac16 pX32_input[];

EXPORT const CFrac16 Actual_op_option_1[];
EXPORT const CFrac16 Actual_op_option_2[];
                           
EXPORT const Frac16  Actual_op_rifft_option_1[32];  
EXPORT const Frac16  Actual_op_rifft_option_2[32];                                    
                                 

#endif
    