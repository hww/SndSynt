/* File: testdata16.h */

#ifndef __TESTDATA16_H
#define __TESTDATA16_H

#include <stdio.h>

#include "port.h"
#include "prototype.h"


#ifdef __cplusplus
extern "C" {
#endif


/* Data organized by input for operation, then resulting output */

#define ABS_S_SPAN 2
EXPORT const UInt16 len_abs_s_data;
EXPORT const Frac16 abs_s_data []; 

#define ADD_SPAN 3
EXPORT const UInt16 len_add_data;
EXPORT const Frac16 add_data [];

#define SUB_SPAN 3
EXPORT const UInt16 len_sub_data;
EXPORT const Frac16 sub_data [];

#define DIV_S_SPAN 3
EXPORT const UInt16 len_div_s_data;
EXPORT const Frac16 div_s_data [];

#define MIN_MAX_SPAN 1
EXPORT const UInt16 len_min_max_data;
EXPORT const Frac16 min_max_data [];
 
#define MULT_SPAN 3
EXPORT const UInt16 len_mult_data;
EXPORT const Frac16 mult_data [];

#define MULT_R_SPAN 3
EXPORT const UInt16 len_mult_r_data;
EXPORT const Frac16 mult_r_data [];

#define NEGATE_SPAN 2
EXPORT const UInt16 len_negate_data;
EXPORT const Frac16 negate_data [];

#define SHR_SPAN 3
EXPORT const UInt16 len_shr_data;
EXPORT const Frac16 shr_data [];

#define SHR_R_SPAN 3
EXPORT const UInt16 len_shr_r_data;
EXPORT const Frac16 shr_r_data [];

#define SHL_SPAN 3
EXPORT const UInt16 len_shl_data;
EXPORT const Frac16 shl_data [];

#define EXTRACT_H_SPAN 2
EXPORT const UInt16 len_extract_h_data;
EXPORT const Frac32 extract_h_data [];

#define EXTRACT_L_SPAN 2
EXPORT const UInt16 len_extract_l_data;
EXPORT const Frac32 extract_l_data [];

#define NORM_S_SPAN 2
EXPORT const UInt16 len_norm_s_data;
EXPORT const Frac16 norm_s_data [];

#define SQRT_SPAN 2
EXPORT const UInt16 len_sqrt_data;
EXPORT const Frac16 sqrt_data [];

#define RAND_SPAN 1
EXPORT const UInt16 len_rand_data;
EXPORT const Frac16 rand_data [];


#ifdef __cplusplus
}
#endif

#endif


