#include <stdio.h>

#include "port.h"
#include "arch.h"
#include "prototype.h"
#include "mfr32.h"
#include "test.h"
#include "testdata32.h"

EXPORT Frac16 mfr32SqrtC (Frac32 x);
EXPORT Result testmfr32(void);

/*-----------------------------------------------------------------------*

    testmfr32.c
	
*------------------------------------------------------------------------*/

/* Data organized by input for operation, then resulting output */

 
Result testmfr32(void)
{
	Frac16         x16, y16, z16;
	Frac32         x32, y32, z32;
   UInt16         i;
	char           s[256];
	test_sRec      testRec;

	/* DSP Function Library initialization must have been performed */
		
	testStart (&testRec, "testmfr32");

	/******************/
   /* Test L_abs     */
	/******************/
	testComment (&testRec, "Testing L_abs");
	for(i=0;i<len_l_abs_data;i++)
	{
		z32 = L_abs(l_abs_data[i*L_ABS_SPAN]);

		if (z32 != l_abs_data[i*L_ABS_SPAN+L_ABS_SPAN-1])
		{
			sprintf(s, "L_abs expected = %lx, actual = %lx", l_abs_data[i*L_ABS_SPAN+L_ABS_SPAN-1], z32);
			testFailed(&testRec, s);
		}
	}		
		
	/******************/
   /* Test L_add     */
	/******************/
	testComment (&testRec, "Testing L_add");
	for(i=0;i<len_l_add_data;i++)
	{
		z32 = L_add(l_add_data[i*L_ADD_SPAN], l_add_data[i*L_ADD_SPAN+1]); 

		if (z32 != l_add_data[i*L_ADD_SPAN+L_ADD_SPAN-1])
		{
			sprintf(s, "L_add expected = %lx, actual = %lx", l_add_data[i*L_ADD_SPAN+L_ADD_SPAN-1], z32);
			testFailed(&testRec, s);
		}
	}		

	/******************/
   /* Test L_sub     */
	/******************/
	testComment (&testRec, "Testing L_sub");
	for(i=0;i<len_l_sub_data;i++)
	{
		z32 = L_sub(l_sub_data[i*L_SUB_SPAN], l_sub_data[i*L_SUB_SPAN+1]); 

		if (z32 != l_sub_data[i*L_SUB_SPAN+L_SUB_SPAN-1])
		{
			sprintf(s, "L_sub expected = %lx, actual = %lx", l_sub_data[i*L_SUB_SPAN+L_SUB_SPAN-1], z32);
			testFailed(&testRec, s);
		}
	}		
	
	/******************/
   /* Test L_mult    */
	/******************/
	testComment (&testRec, "Testing L_mult");
	for(i=0;i<len_l_mult_data;i++)
	{
		z32 = L_mult(extract_h(l_mult_data[i*L_MULT_SPAN]),
						extract_h(l_mult_data[i*L_MULT_SPAN+1])); 

		if (z32 != l_mult_data[i*L_MULT_SPAN+L_MULT_SPAN-1])
		{
			sprintf(s, "L_mult %d expected = %lx, actual = %lx", i, l_mult_data[i*L_MULT_SPAN+L_MULT_SPAN-1], z32);
			testFailed(&testRec, s);
		}
	}

	/******************/
   /* Test L_mult_ls */
	/******************/
	testComment (&testRec, "Testing L_mult_ls");
	for(i=0;i<len_l_mult_ls_data;i++)
	{
		z32 = L_mult_ls(l_mult_ls_data[i*L_MULT_LS_SPAN],
						extract_h(l_mult_ls_data[i*L_MULT_LS_SPAN+1])); 

		if (z32 != l_mult_ls_data[i*L_MULT_LS_SPAN+L_MULT_LS_SPAN-1])
		{
			sprintf(s, "L_mult_ls %d expected = %lx, actual = %lx", i, l_mult_ls_data[i*L_MULT_LS_SPAN+L_MULT_LS_SPAN-1], z32);
			testFailed(&testRec, s);
		}
	}
		
	/******************/
   /* Test L_negate  */
	/******************/
	testComment (&testRec, "Testing L_negate");
	for(i=0;i<len_l_negate_data;i++)
	{
		z32 = L_negate(l_negate_data[i*L_NEGATE_SPAN]);

		if (z32 != l_negate_data[i*L_NEGATE_SPAN+L_NEGATE_SPAN-1])
		{
			sprintf(s, "L_negate expected = %lx, actual = %lx", l_negate_data[i*L_NEGATE_SPAN+L_NEGATE_SPAN-1], z32);
			testFailed(&testRec, s);
		}
	}		
	

	/******************/
   /* Test L_shr     */
	/******************/
	testComment (&testRec, "Testing L_shr");
	for(i=0;i<len_l_shr_data;i++)
	{
		z32 = L_shr(l_shr_data[i*L_SHR_SPAN], 
						extract_l(l_shr_data[i*L_SHR_SPAN+1])); 

		if (z32 != l_shr_data[i*L_SHR_SPAN+L_SHR_SPAN-1])
		{
			sprintf(s, "L_shr %d expected = %lx, actual = %lx", i, l_shr_data[i*L_SHR_SPAN+L_SHR_SPAN-1], z32);
			testFailed(&testRec, s);
		}
	}
	
	
	/******************/
   /* Test L_shr_r   */
	/******************/
	testComment (&testRec, "Testing L_shr_r");
	for(i=0;i<len_l_shr_r_data;i++)
	{
		z32 = L_shr_r(l_shr_r_data[i*L_SHR_R_SPAN], 
						extract_l(l_shr_r_data[i*L_SHR_R_SPAN+1])); 

		if (z32 != l_shr_r_data[i*L_SHR_R_SPAN+L_SHR_R_SPAN-1])
		{
			sprintf(s, "L_shr_r %d expected = %lx, actual = %lx", i, l_shr_r_data[i*L_SHR_R_SPAN+L_SHR_R_SPAN-1], z32);
			testFailed(&testRec, s);
		}
	}		


	/******************/
   /* Test L_shl     */
	/******************/
	testComment (&testRec, "Testing L_shl");
	for(i=0;i<len_l_shl_data;i++)
	{
		z32 = L_shl(l_shl_data[i*L_SHL_SPAN], l_shl_data[i*L_SHL_SPAN+1]); 

		if (z32 != l_shl_data[i*L_SHL_SPAN+L_SHL_SPAN-1])
		{
			sprintf(s, "L_shl %d expected = %lx, actual = %lx", i, l_shl_data[i*L_SHL_SPAN+L_SHL_SPAN-1], z32);
			testFailed(&testRec, s);
		}
	}		

	
	/******************/
   /* Test L_mac     */
	/******************/
	testComment (&testRec, "Testing L_mac");
	for(i=0;i<len_l_mac_data;i++)
	{
		z32 = L_mac(l_mac_data[i*L_MAC_SPAN], 
						extract_h(l_mac_data[i*L_MAC_SPAN+1]),
						extract_h(l_mac_data[i*L_MAC_SPAN+2])); 

		if (z32 != l_mac_data[i*L_MAC_SPAN+L_MAC_SPAN-1])
		{
			sprintf(s, "L_mac %d expected = %lx, actual = %lx", i, 
						l_mac_data[i*L_MAC_SPAN+L_MAC_SPAN-1], z32);
			testFailed(&testRec, s);
		}
	}		

	/******************/
   /* Test mac_r     */
	/******************/
	testComment (&testRec, "Testing mac_r");
	for(i=0;i<len_mac_r_data;i++)
	{
		z16 = mac_r(mac_r_data[i*MAC_R_SPAN], 
						extract_h(mac_r_data[i*MAC_R_SPAN+1]),
						extract_h(mac_r_data[i*MAC_R_SPAN+2])); 

		if (z16 != extract_h(mac_r_data[i*MAC_R_SPAN+MAC_R_SPAN-1]))
		{
			sprintf(s, "mac_r %d expected = %x, actual = %x", i, 
						extract_h(mac_r_data[i*MAC_R_SPAN+MAC_R_SPAN-1]), z16);
			testFailed(&testRec, s);
		}
	}		

	/******************/
   /* Test msu_r     */
	/******************/
	testComment (&testRec, "Testing msu_r");
	for(i=0;i<len_msu_r_data;i++)
	{
		z16 = msu_r(msu_r_data[i*MSU_R_SPAN], 
						extract_h(msu_r_data[i*MSU_R_SPAN+1]),
						extract_h(msu_r_data[i*MSU_R_SPAN+2])); 

		if (z16 != extract_h(msu_r_data[i*MSU_R_SPAN+MSU_R_SPAN-1]))
		{
			sprintf(s, "msu_r %d expected = %x, actual = %x", i, 
						extract_h(msu_r_data[i*MSU_R_SPAN+MSU_R_SPAN-1]), z16);
			testFailed(&testRec, s);
		}
	}		

	/******************/
   /* Test L_msu     */
	/******************/
	testComment (&testRec, "Testing L_msu");
	for(i=0;i<len_l_msu_data;i++)
	{
		z32 = L_msu(l_msu_data[i*L_MSU_SPAN], 
						extract_h(l_msu_data[i*L_MSU_SPAN+1]),
						extract_h(l_msu_data[i*L_MSU_SPAN+2])); 

		if (z32 != l_msu_data[i*L_MSU_SPAN+L_MSU_SPAN-1])
		{
			sprintf(s, "L_msu %d expected = %lx, actual = %lx", i, 
						l_msu_data[i*L_MSU_SPAN+L_MSU_SPAN-1], z32);
			testFailed(&testRec, s);
		}
	}		

	/******************/
   /* Test div_ls     */
	/******************/
	testComment (&testRec, "Testing div_ls");
	for(i=0;i<len_div_ls_data;i++)
	{
		z16 = div_ls(div_ls_data[i*DIV_LS_SPAN], extract_h(div_ls_data[i*DIV_LS_SPAN+1])); 

		if (z16 != extract_h(div_ls_data[i*DIV_LS_SPAN+DIV_LS_SPAN-1]))
		{
			sprintf(s, "div_ls expected = %x, actual = %x", 
						extract_h(div_ls_data[i*DIV_LS_SPAN+DIV_LS_SPAN-1]), z16);
			testFailed(&testRec, s);
		}
	}		

	/********************************/
   /* Test norm_l                  */
	/********************************/
	testComment (&testRec, "Testing norm_l");
	for(i=0;i<len_norm_l_data;i++)
	{
		z16 = norm_l(norm_l_data[i*NORM_L_SPAN]);
		if (z16 != extract_h(norm_l_data[i*NORM_L_SPAN+NORM_L_SPAN-1]))
		{
			sprintf(s, "norm_l expected = %x, actual = %x", 
						extract_h(norm_l_data[i*NORM_L_SPAN+NORM_L_SPAN-1]), 
						z16);
			testFailed(&testRec, s);
		}
	}
	
			
	/********************************/
   /* Test round and L_deposit_h   */
	/********************************/
	testComment (&testRec, "Testing round");
	for(i=0;i<len_round_data;i++)
	{
		Frac32 z32;
		
		z16 = round(round_data[i*ROUND_SPAN]);
		z32 = L_deposit_h(z16);
		if (z32 != round_data[i*ROUND_SPAN+ROUND_SPAN-1])
		{
			sprintf(s, "round expected = %lx, actual = %lx", 
						round_data[i*ROUND_SPAN+ROUND_SPAN-1], 
						z32);
			testFailed(&testRec, s);
		}
	}		
	
	
	/******************/
   /* Test sqrt      */
	/******************/
	testComment (&testRec, "Testing sqrt");
	for(i=0;i<len_l_sqrt_data;i++)
	{
		z16 = mfr32Sqrt(l_sqrt_data[i*L_SQRT_SPAN]);
		
		x16 = mfr32SqrtC(l_sqrt_data[i*L_SQRT_SPAN]);
		if (x16 != z16)
		{
			sprintf(s, "sqrt C version (%x) != assembler version (%x)", x16, z16);
			testFailed(&testRec, s);
		}

		if (z16 != extract_h(l_sqrt_data[i*L_SQRT_SPAN+L_SQRT_SPAN-1]))
		{
			sprintf(s, "sqrt expected = %x, actual = %x", 
							extract_h(l_sqrt_data[i*L_SQRT_SPAN+L_SQRT_SPAN-1]), z16);
			testFailed(&testRec, s);
		}
	}		
		
	

	testEnd(&testRec);

   return PASS;
}





