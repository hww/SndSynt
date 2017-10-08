#ifndef _INPUT_CFFTH_
#define _INPUT_CFFTH_

/*-------------*/
/* CFFT Tables */
/*-------------*/
/* Test case covering N = 8, 16, 32, 64, 128, 256, 1024,
   and 2048 */ 
   
   
#define MIN_CFFT_LEN 8         /* Minimum value of CFFT length */
#define MAX_CFFT_LEN 2048      /* Maximum value of CFFT length */

#define MIN_CIFFT_LEN MIN_CFFT_LEN    /* Minimum value of CIFFT length */
#define MAX_CIFFT_LEN MAX_CFFT_LEN    /* Maximum value of CIFFT length */



EXPORT const CFrac16 pX_input[];
    
    
/*-----------------------------------------------------*/
/* Expected output for CFFT */
EXPORT const CFrac16 Expected_Out_cfft_8[];     /* N = 8 */
EXPORT const CFrac16 Expected_Out_cfft_16[];    /* N = 16 */
EXPORT const CFrac16 Expected_Out_cfft_32[];    /* N = 32 */
EXPORT const CFrac16 Expected_Out_cfft_64[];    /* N = 64 */
EXPORT const CFrac16 Expected_Out_cfft_128[];   /* N = 128 */
EXPORT const CFrac16 Expected_Out_cfft_256[];   /* N = 256 */
EXPORT const CFrac16 Expected_Out_cfft_512[];   /* N = 512 */
EXPORT const CFrac16 Expected_Out_cfft_1024[];  /* N = 1024 */
EXPORT const CFrac16 Expected_Out_cfft_2048[];  /* N = 2048 */

/*-----------------------------------------------------------------*/
/* Test vector to test all the options for N = 32 CFFT and CIFFT   */
/*-----------------------------------------------------------------*/

EXPORT const CFrac16 pX_input32[];
EXPORT const CFrac16 Exp_Out_OPT_0[];
EXPORT const CFrac16 Exp_Out_OPT_1[];
EXPORT const CFrac16 Exp_Out_OPT_2[];
EXPORT const CFrac16 Exp_Out_OPT_5[];
EXPORT const CFrac16 Exp_Out_OPT_6[];
EXPORT const CFrac16 Exp_Out_OPT_9[];
EXPORT const CFrac16 Exp_Out_OPT_10[];
EXPORT const CFrac16 Exp_Out_OPT_13[];
EXPORT const CFrac16 Exp_Out_OPT_14[];


#endif
    