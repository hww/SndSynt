/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         appconst.h
*
* Description:       Description of Application constant for appconst.c file
*
* Modules Included:  
*                    
* 
*****************************************************************************/
#include "port.h"
#include "arch.h"
#include "prototype.h"

#ifndef __APPCONST_H
#define __APPCONST_H

/* Testing of IIR Filter is done for 3 biquads*/
#define SCALE_FACT_IIR 2
#define NUM_SAMPLES_IIR 16

#define CORR_NX      5   /* Length of input vector */
#define CORR_NY      3   /* Length of output vector */
#define CORR_OPTIONS CORR_RAW  /* CORR_RAW =0, CORR_BIAS = 1, CORR_UNBIAS = 2*/

#define AUTO_CORR_NX      5           /* Length of input vector */
#define AUTO_CORR_NZ      9           /* Length of output vector*/
#define AUTO_CORR_OPTIONS CORR_RAW    /* CORR_RAW = 0, CORR_BIAS = 1, CORR_UNBIAS = 2*/

#define FIR_RESULTS_LENGTH 16
#define FIR_DEC_RESULT_LENGTH 8
#define FIR_INT_RESULTS_LENGTH 32

#define FIR_INT3_RESULTS_LENGTH 32 


#define FIR_COEF_LENGTH	51 

#define IIR_COEF_LENGTH 15

#define SINWAVE_SIZE	17  


                         
                              
	


EXPORT const Frac16 FirCoefs[FIR_COEF_LENGTH];


EXPORT const Frac16 sinWave[SINWAVE_SIZE];



EXPORT const Frac16 IirCoefs[IIR_COEF_LENGTH]; 

EXPORT const Frac16 EXP_IIR_OUT[]; 

EXPORT const Frac16 FirResults[]; 
EXPORT const Frac16 FirDecResults[FIR_DEC_RESULT_LENGTH];
EXPORT const Frac16 FirIntResults[FIR_INT_RESULTS_LENGTH];
EXPORT const Frac16 FirInt3Results[FIR_INT3_RESULTS_LENGTH];


EXPORT const Frac16 exp_acorr_out2[AUTO_CORR_NZ];
EXPORT const Frac16 exp_acorr_out3[AUTO_CORR_NZ];

EXPORT const Frac16 exp_out_opt1[CORR_NX+CORR_NY-1]; 
EXPORT const Frac16 exp_out_opt2[CORR_NX+CORR_NY-1]; 
EXPORT const Frac16 exp_out_opt3[CORR_NX+CORR_NY-1];
											 

EXPORT const char MSG_TESTDFR16[];
EXPORT const char MSG_C_VERSION_FIR_FAILED[];
EXPORT const char MSG_TEST_FIR_IN_C[];
EXPORT const char MSG_FIR_MODULE_ADDRESS[];
EXPORT const char MSG_FIR_MODULE_ADDRESS_FAILED[];

EXPORT const char MSG_FIR_ASM_FAILED[];
EXPORT const char MSG_DFR16FIR_NOT_EQUAL_ONE_SAMPLE[];
EXPORT const char MSG_ASM_FIR_LINEAR_ADDRESSING[];
EXPORT const char MSG_ASM_VERSION_FAILED[];
EXPORT const char MSG_TEST_FIRDEC_ODD_NUMBERS[];
EXPORT const char MSG_FIRDEC_DID_NOT_RETURN_CORRECT_SAMPLES[];
EXPORT const char MSG_FIRDEC_FAILED_ODD_NUMBERS[];

EXPORT const char MSG_FIRDEC_TEST_FIR_DEC_BY_2[];
EXPORT const char MSG_FIRDEC_FAILED_CORRECT_SAMPLED[];
EXPORT const char MSG_FIRDEC_FAILED_DECIMATION_BY_2[];
EXPORT const char MSG_FIRINTC_TEST[];
EXPORT const char MSG_FIRINT_TEST[];

EXPORT const char MSG_FIRINT_FACTOR_3[];
EXPORT const char MSG_FIRINT_FACTOR_3_FAILED[];

EXPORT const char MSG_FIRINT_FACTOR_3_MODULO_ADDRESSING_INTERNAL[];
EXPORT const char MSG_FIRINT_DID_NOT_ALLOCATE_MEMORY[];
EXPORT const char MSG_FIRINT_DID_NOT_ALLOCATE_ALIGNED_MEMORY[];
EXPORT const char MSG_FIRINT_DID_NOT_RETURN_CORRECT_SAMPLES_FACTOR3[];
EXPORT const char MSG_FIRINT_BY_FACTOR_3_LINEAR_ADDRESSING_INTERNAL[];

EXPORT const char MSG_FIRINT_FACTOR_4[];

EXPORT const char MSG_FIRINT_DID_NOT_RETURN_CORRECT_SAMPLES[];
EXPORT const char MSG_FIRDEC_FAILED_INTERPOLATION_FACTOR_2[];
EXPORT const char MSG_CORR_RAW_TEST[];
EXPORT const char MSG_CORR_RAW_TEST_FAILED[];
EXPORT const char MSG_CORR_RAW_ASM_VERSION_TEST[];
EXPORT const char MSG_CORR_ASM_FAILED[];
EXPORT const char MSG_CORR_BIAS_TEST[];
EXPORT const char MSG_CORR_C_VERSION_FAILED[];
EXPORT const char MSG_ASM_CODE_WITH_CORR_BIAS[];
EXPORT const char MSG_CORR_ASM_WITH_BIAS_FAILED[];
EXPORT const char MSG_CORR_C_VERSION_UNBIAS[];
EXPORT const char MSG_CORR_FAILED_C_UNBIAS[];
EXPORT const char MSG_CORR_ASM_UNBIAS[];
EXPORT const char MSG_CORR_FAILED_ASM_UNBIAS[];
EXPORT const char MSG_CROSS_CORR_TESTING[];
EXPORT const char MSG_CROSS_CORR_FAILED[];
EXPORT const char MSG_CROSS_CORR_ASM_FAILED[];
EXPORT const char MSG_CROSS_CORR_C_VERSION_FAILED[];
EXPORT const char MSG_CROSS_CORR_ASM_WITH_BIAS_FAILED[];
EXPORT const char MSG_CROSS_CORR_C_UNBIAS_FAILED[];
EXPORT const char MSG_CORSS_CORR_ASM_UNBIAS_FAILED[];

EXPORT const char MSG_TEST_IIR_C_CODE[];
EXPORT const char MSG_TEST_IIR_DOES_RETURN_PASS[];
EXPORT const char MSG_TEST_IIR_WRONG_RESULTS[];
EXPORT const char MSG_TEST_IIR_ASM_MODULE_ADDRESSING[];
EXPORT const char MSG_TEST_IIR_INIT_INTERNAL[];
EXPORT const char MSG_TEST_IIR_ASM_WITH_LINEAR_ADDRESSING_INTERNAL_MEMORY[];


#endif /* __APPCONST_H */