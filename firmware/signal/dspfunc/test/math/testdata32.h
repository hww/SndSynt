/* File: testdata32.h */

#ifndef __TESTDATA32_H
#define __TESTDATA32_H

#include <stdio.h>

#include "port.h"
#include "prototype.h"


#ifdef __cplusplus
extern "C" {
#endif


/* Data organized by input for operation, then resulting output */

#define L_ABS_SPAN 2
EXPORT const UInt16 len_l_abs_data;
EXPORT const Frac32 l_abs_data []; 

#define L_ADD_SPAN 3
EXPORT const UInt16 len_l_add_data;
EXPORT const Frac32 l_add_data [];

#define L_SUB_SPAN 3
EXPORT const UInt16 len_l_sub_data;
EXPORT const Frac32 l_sub_data [];

#define DIV_LS_SPAN 3
EXPORT const UInt16 len_div_ls_data;
EXPORT const Frac32 div_ls_data [];

#define L_MIN_MAX_SPAN 1
EXPORT const UInt16 len_l_min_max_data;
EXPORT const Frac32 l_min_max_data [];

#define L_MULT_SPAN 3
EXPORT const UInt16 len_l_mult_data;
EXPORT const Frac32 l_mult_data [];

#define L_MULT_LS_SPAN 3
EXPORT const UInt16 len_l_mult_ls_data;
EXPORT const Frac32 l_mult_ls_data [];

#define L_NEGATE_SPAN 2
EXPORT const UInt16 len_l_negate_data;
EXPORT const Frac32 l_negate_data [];

#define L_SHR_SPAN 3
EXPORT const UInt16 len_l_shr_data;
EXPORT const Frac32 l_shr_data [];

#define L_SHR_R_SPAN 3
EXPORT const UInt16 len_l_shr_r_data;
EXPORT const Frac32 l_shr_r_data [];

#define L_SHL_SPAN 3
EXPORT const UInt16 len_l_shl_data;
EXPORT const Frac32 l_shl_data [];

#define L_MAC_SPAN 4
EXPORT const UInt16 len_l_mac_data;
EXPORT const Frac32 l_mac_data [];

#define MAC_R_SPAN 4
EXPORT const UInt16 len_mac_r_data;
EXPORT const Frac32 mac_r_data [];

#define MSU_R_SPAN 4
EXPORT const UInt16 len_msu_r_data;
EXPORT const Frac32 msu_r_data [];

#define L_MSU_SPAN 4
EXPORT const UInt16 len_l_msu_data;
EXPORT const Frac32 l_msu_data [];

#define NORM_L_SPAN 2
EXPORT const UInt16 len_norm_l_data;
EXPORT const Frac32 norm_l_data [];

#define ROUND_SPAN 2
EXPORT const UInt16 len_round_data;
EXPORT const Frac32 round_data [];

#define L_SQRT_SPAN 2
EXPORT const UInt16 len_l_sqrt_data;
EXPORT const Frac32 l_sqrt_data [];


#ifdef __cplusplus
}
#endif

#endif

