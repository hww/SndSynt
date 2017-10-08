/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         appconst.c
*
* Description:       Description of Application constant. 
*
* Modules Included:  
*                    
* 
*****************************************************************************/

#include "port.h"
#include "arch.h"
#include "prototype.h"
#include "appconst.h"

const Frac16 FirCoefs[] = {
	88,22,-100,-106,81,183,-18,-255,-121,279,
	316,-184,-533,-52,670,466,-640,-1003,284,1607,
	567,-2146,-2455,2531,10065,13718,10065,2531,-2455,-2146,
	567,1607,284,-1003,-640,466,670,-52,-533,-184,
	316,279,-121,-255,-18,183,81,-106,-100,22,88	
};


const Frac16 sinWave[] =
{
	0,
	12539,
	23170,
	30273,
	32767,
	30273,
	23170,
	12539,
	0,
	-12539,
	-23170,
	-30273,
	-32767,
	-30273,
	-23170,
	-12539,
	0	
};




const Frac16 IirCoefs[] = {
-21623,
4020,
3791,
7582,
-24503,
8919,
4287,
8592,
4304,
-31851,
21421,
5595,
11168,
5573
};

const Frac16 EXP_IIR_OUT[] = {0,32,178,476,860,1214,1436,1467,1286,918,
                              410,-155,-702,-1133,-1404,-1444};                              
                              

const Frac16 FirResults[] = { -30192, -31192, -30250, -23152, -12530, 0, 12530, 23152, 30192,
					31192, 30250, 23152, 12530, 0, -12530, -23152 };
const Frac16 FirDecResults[] = { -31192, -23152, 0, 23152, 31192, 23152, 0, -23152};

const Frac16 FirIntResults[] = { 13656, 11584, 9124, 6269, 3204, 0, -3204,
										 -6269, -9124, -11584, -13656, -15135,
										 -16108, -16382, -16108, -15135, -13656,
										 -11584, -9124, -6269, -3204, 0, 3204,
										 6269, 9124, 11584, 13656, 15135, 16108,
										 16382, 16108, 15135};
										 
const Frac16 FirInt3Results[] = { -7700, -6628, -5476, -4167, -2805, -1446, 0,
										 1446, 2805, 4167, 5476, 6628,
										 7700, 8673, 9443, 10060, 10549,
										 10819, 10889, 10819, 10549, 10060, 9443,
										 8673, 7700, 6628, 5476, 4167, 2805,
										 1446, 0, -1446};
										 
const Frac16 px[AUTO_CORR_NX] = { 0x4000, 0x4200, 0x6100, 0x1400, 0x3241};
	

const Frac16 exp_acorr_out2[AUTO_CORR_NZ] = {0x506,0x72f,0x1361,0x1534,0x1999,0x1534,0x1361,0x72f,0x506};
const Frac16 exp_acorr_out3[AUTO_CORR_NZ] = {0x506,0x5fc,0xdd7,0xd41,0x0e38,0xd41,0xdd7,0x5fc,0x506};
										 


const Frac16 exp_out_opt1[CORR_NX+CORR_NY-1] = {0x0500, 0x1ea0, 0x4634, 0x7ffe, 0x790d, 0x4cd9, 0x3911};
const Frac16 exp_out_opt2[CORR_NX+CORR_NY-1] = {0xb7, 0x460, 0xa07, 0x1249, 0x114b, 0xafa, 0x827};
const Frac16 exp_out_opt3[CORR_NX+CORR_NY-1] = {0x1ab, 0x7a8, 0xe0a, 0x1555, 0x114b, 0xccf, 0xb6a};
											 


const char MSG_TESTDFR16[]="testdfr16";
const char MSG_C_VERSION_FIR_FAILED[] = "C version of FIR failed";
const char MSG_TEST_FIR_IN_C[] = "Test FIR in C";
const char MSG_FIR_MODULE_ADDRESS[] = "Test FIR with modulo addressing in internal memory";
const char MSG_FIR_MODULE_ADDRESS_FAILED[] = "Failed modulo addressing";
const char MSG_FIR_ASM_FAILED[]= "ASM version of FIR failed in Case 1";
const char MSG_DFR16FIR_NOT_EQUAL_ONE_SAMPLE[] ="dfr16FIRs did not equal dfr16FIRC for one sample";


const char MSG_ASM_VERSION_FAILED[]="ASM version of FIR failed in case 3";

const char MSG_ASM_FIR_LINEAR_ADDRESSING[]="Test FIR with linear addressing";
const char MSG_TEST_FIRDEC_ODD_NUMBERS[]="Test FIRDEC with odd number samples";
const char MSG_FIRDEC_DID_NOT_RETURN_CORRECT_SAMPLES[]="FIRDec did not return correct number of samples";
const char MSG_FIRDEC_FAILED_ODD_NUMBERS[]="FIRDec failed using odd number of samples";

const char MSG_FIRDEC_TEST_FIR_DEC_BY_2[]="Test FIRDEC by factor of 2";
const char MSG_FIRDEC_FAILED_CORRECT_SAMPLED[]= "FIRDec did not return correct number of samples";
const char MSG_FIRDEC_FAILED_DECIMATION_BY_2[]="FIRDec failed with decimation factor 2";
const char MSG_FIRDEC_FAILED_INTERPOLATION_FACTOR_2[]="FIRInt failed with interpolation factor 2";
const char MSG_FIRINTC_TEST[]="Test FIRIntC by factor of 2";
const char MSG_FIRINT_TEST[]="Test FIRInt by factor of 2";
const char MSG_FIRINT_DID_NOT_RETURN_CORRECT_SAMPLES[]="FIRIntC did not return correct number of samples";

const char MSG_FIRINT_FACTOR_3[]= "Test FIRIntC by factor of 3";
const char MSG_FIRINT_FACTOR_3_FAILED[]="FIRInt failed with interpolation factor 3";
const char MSG_FIRINT_FACTOR_3_MODULO_ADDRESSING_INTERNAL[]="Test FIRInt by factor of 3 with modulo addressing in internal memory";
const char MSG_FIRINT_DID_NOT_ALLOCATE_MEMORY[]="FIRInt did not allocate internal memory";
const char MSG_FIRINT_DID_NOT_ALLOCATE_ALIGNED_MEMORY[]="FIRInt did not allocate aligned memory";
const char MSG_FIRINT_DID_NOT_RETURN_CORRECT_SAMPLES_FACTOR3[]="FIRIntC did not return correct number of samples by factor 3";
const char MSG_FIRINT_BY_FACTOR_3_LINEAR_ADDRESSING_INTERNAL[]="Test FIRInt by factor of 3 with linear addressing in internal memory";
const char MSG_FIRINT_FACTOR_4[]="Test FIRInt by factor of 4";

/* Correlation constants */
const char MSG_CORR_RAW_TEST[]="Testing C code for option CORR_RAW";
const char MSG_CORR_RAW_TEST_FAILED[]= "corr failed in C version with option CORR_RAW";
const char MSG_CORR_RAW_ASM_VERSION_TEST[]="Testing ASM code for option CORR_RAW";
const char MSG_CORR_ASM_FAILED[]="corr failed in ASM version";
const char MSG_CORR_BIAS_TEST[]="Testing C code for option CORR_BIAS";
const char MSG_CORR_C_VERSION_FAILED[]="corr failed in C version with option CORR_BIAS";
const char MSG_ASM_CODE_WITH_CORR_BIAS[]="Testing ASM code for option CORR_BIAS";
const char MSG_CORR_ASM_WITH_BIAS_FAILED[]="corr failed in ASM version with option CORR_BIAS";
const char MSG_CORR_C_VERSION_UNBIAS[]="Testing C code for option CORR_UNBIAS";
const char MSG_CORR_FAILED_C_UNBIAS[]="corr failed in C version with option CORR_UNBIAS";
const char MSG_CORR_ASM_UNBIAS[]="Testing ASM code for option CORR_UNBIAS";
const char MSG_CORR_FAILED_ASM_UNBIAS[]="corr failed in ASM version with option CORR_UNBIAS";
const char MSG_CROSS_CORR_TESTING[]="Testing Cross Correlation";
const char MSG_CROSS_CORR_FAILED[]="autocorr failed in C version with option CORR_RAW";
const char MSG_CROSS_CORR_ASM_FAILED[]="autocorr failed in ASM version";
const char MSG_CROSS_CORR_C_VERSION_FAILED[]="autocorr failed in C version with option CORR_BIAS";
const char MSG_CROSS_CORR_ASM_WITH_BIAS_FAILED[]="autocorr failed in ASM version with option CORR_BIAS";
const char MSG_CROSS_CORR_C_UNBIAS_FAILED[]="autocorr failed in C version with option CORR_UNBIAS";
const char MSG_CORSS_CORR_ASM_UNBIAS_FAILED[]="autocorr failed in ASM version with option CORR_UNBIAS";

/*********************************************************************************************************/
/* IIR constants */
const char MSG_TEST_IIR_C_CODE[]="Test IIR C Code";
const char MSG_TEST_IIR_DOES_RETURN_PASS[]="dfr16IIR did not return PASS";
const char MSG_TEST_IIR_WRONG_RESULTS[]="wrong results of dfr16IIR";
const char MSG_TEST_IIR_ASM_MODULE_ADDRESSING[]="Test IIR ASM code with modulo addressing in internal memory";
const char MSG_TEST_IIR_INIT_INTERNAL[]="IirInit for internal memory failed";
const char MSG_TEST_IIR_ASM_WITH_LINEAR_ADDRESSING_INTERNAL_MEMORY[]="Test IIR ASM code with linear addressing in internal memory";

