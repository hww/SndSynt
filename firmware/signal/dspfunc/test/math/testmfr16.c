#include <stdio.h>

#include "port.h"
#include "arch.h"
#include "prototype.h"
#include "mfr16.h"
#include "test.h"
#include "testdata16.h"

/*-----------------------------------------------------------------------*

    testmfr16.c
	
*------------------------------------------------------------------------*/

EXPORT Result testmfr16(void);

Result testmfr16(void)
{
	Frac16         x16, y16, z16;
   UInt16         i;
	char           s[256];
	test_sRec      testRec;

	/* DSP Function Library initialization must have been performed */
	
	testStart (&testRec, "testmfr16");

	/******************/
   /* Test abs_s     */
	/******************/
	testComment (&testRec, "Testing abs_s");
	for(i=0;i<len_abs_s_data;i++)
	{
		z16 = abs_s(abs_s_data[i*ABS_S_SPAN]);

		if (z16 != abs_s_data[i*ABS_S_SPAN+ABS_S_SPAN-1])
		{
			sprintf(s, "abs_s expected = %x, actual = %x", abs_s_data[i*ABS_S_SPAN+ABS_S_SPAN-1], z16);
			testFailed(&testRec, s);
		}
	}		
		
	/******************/
   /* Test add       */
	/******************/
	testComment (&testRec, "Testing add");
	for(i=0;i<len_add_data;i++)
	{
		z16 = add(add_data[i*ADD_SPAN], add_data[i*ADD_SPAN+1]); 

		if (z16 != add_data[i*ADD_SPAN+ADD_SPAN-1])
		{
			sprintf(s, "add expected = %x, actual = %x", add_data[i*ADD_SPAN+ADD_SPAN-1], z16);
			testFailed(&testRec, s);
		}
	}		
	
	/******************/
   /* Test sub       */
	/******************/
	testComment (&testRec, "Testing sub");
	for(i=0;i<len_sub_data;i++)
	{
		z16 = sub(sub_data[i*SUB_SPAN], sub_data[i*SUB_SPAN+1]); 

		if (z16 != sub_data[i*SUB_SPAN+SUB_SPAN-1])
		{
			sprintf(s, "sub %d expected = %x, actual = %x", i, sub_data[i*SUB_SPAN+SUB_SPAN-1], z16);
			testFailed(&testRec, s);
		}
	}		
	
	/******************/
   /* Test shr       */
	/******************/
	testComment (&testRec, "Testing shr");
	for(i=0;i<len_shr_data;i++)
	{
		z16 = shr(shr_data[i*SHR_SPAN], shr_data[i*SHR_SPAN+1]); 

		if (z16 != shr_data[i*SHR_SPAN+SHR_SPAN-1])
		{
			sprintf(s, "shr %d expected = %x, actual = %x", i, shr_data[i*SHR_SPAN+SHR_SPAN-1], z16);
			testFailed(&testRec, s);
		}
	}		
	
	/******************/
   /* Test shr_r     */
	/******************/
	testComment (&testRec, "Testing shr_r");
	for(i=0;i<len_shr_r_data; i++)
	{
		z16 = shr_r(shr_r_data[i*SHR_R_SPAN], shr_r_data[i*SHR_R_SPAN+1]); 

		if (z16 != shr_r_data[i*SHR_R_SPAN+SHR_R_SPAN-1])
		{
			sprintf(s, "shr_r %d expected = %x, actual = %x", i, shr_r_data[i*SHR_R_SPAN+SHR_R_SPAN-1], z16);
			testFailed(&testRec, s);
		}
	}		
	
	/******************/
   /* Test shl       */
	/******************/
	testComment (&testRec, "Testing shl");
	for(i=0;i<len_shl_data;i++)
	{
		z16 = shl(shl_data[i*SHL_SPAN], shl_data[i*SHL_SPAN+1]); 

		if (z16 != shl_data[i*SHL_SPAN+SHL_SPAN-1])
		{
			sprintf(s, "shl %d expected = %x, actual = %x", i, shl_data[i*SHL_SPAN+SHL_SPAN-1], z16);
			testFailed(&testRec, s);
		}
	}		
	
	/******************/
   /* Test div_s     */
	/******************/
	testComment (&testRec, "Testing div_s");
	for(i=0;i<len_div_s_data;i++)
	{
		z16 = div_s(div_s_data[i*DIV_S_SPAN], div_s_data[i*DIV_S_SPAN+1]); 

		if (z16 != div_s_data[i*DIV_S_SPAN+DIV_S_SPAN-1])
		{
			sprintf(s, "div_s expected = %x, actual = %x", div_s_data[i*DIV_S_SPAN+DIV_S_SPAN-1], z16);
			testFailed(&testRec, s);
		}
	}		
	
	/******************/
   /* Test mult      */
	/******************/
	testComment (&testRec, "Testing mult");
	for(i=0;i<len_mult_data;i++)
	{
		z16 = mult( mult_data[i*MULT_SPAN], mult_data[i*MULT_SPAN+1]);

		if (z16 != mult_data[i*MULT_SPAN+MULT_SPAN-1])
		{
			sprintf(s, "mult expected = %x, actual = %x", 
						mult_data[i*MULT_SPAN+MULT_SPAN-1], z16);
			testFailed(&testRec, s);
		}
	}		
	
	/******************/
   /* Test mult_r    */
	/******************/
	testComment (&testRec, "Testing mult_r");
	for(i=0;i<len_mult_r_data;i++)
	{
		z16 = mult_r( mult_r_data[i*MULT_R_SPAN], mult_r_data[i*MULT_R_SPAN+1]);

		if (z16 != mult_r_data[i*MULT_R_SPAN+MULT_R_SPAN-1])
		{
			sprintf(s, "mult_r expected = %x, actual = %x", 
						mult_r_data[i*MULT_R_SPAN+MULT_R_SPAN-1], z16);
			testFailed(&testRec, s);
		}
	}		
	
	/******************/
   /* Test negate    */
	/******************/
	testComment (&testRec, "Testing negate");
	for(i=0;i<len_negate_data;i++)
	{
		z16 = negate(negate_data[i*NEGATE_SPAN]);

		if (z16 != negate_data[i*NEGATE_SPAN+NEGATE_SPAN-1])
		{
			sprintf(s, "negate expected = %x, actual = %x", negate_data[i*NEGATE_SPAN+NEGATE_SPAN-1], z16);
			testFailed(&testRec, s);
		}
	}		
	
	/********************************/
   /* Test extract_h and L_deposit_h */
	/********************************/
	testComment (&testRec, "Testing extract_h");
	for(i=0;i<len_extract_h_data;i++)
	{
		Frac32 z32;
		
		z16 = extract_h(extract_h_data[i*EXTRACT_H_SPAN]);
		z32 = L_deposit_h(z16);
		if (z32 != extract_h_data[i*EXTRACT_H_SPAN+EXTRACT_H_SPAN-1])
		{
			sprintf(s, "extract_h %d expected = %lx, actual = %lx",
						i, 
						extract_h_data[i*EXTRACT_H_SPAN+EXTRACT_H_SPAN-1], 
						z32);
			testFailed(&testRec, s);
		}
	}		
	
	/********************************/
   /* Test extract_l and L_deposit_l */
	/********************************/
	testComment (&testRec, "Testing extract_l");
	for(i=0;i<len_extract_l_data;i++)
	{
		Frac32 z32;
		
		z16 = extract_l(extract_l_data[i*EXTRACT_L_SPAN]);
		z32 = L_deposit_l(z16);
		if (z32 != extract_l_data[i*EXTRACT_L_SPAN+EXTRACT_L_SPAN-1])
		{
			sprintf(s, "extract_l expected = %lx, actual = %lx", 
						extract_l_data[i*EXTRACT_L_SPAN+EXTRACT_L_SPAN-1], 
						z32);
			testFailed(&testRec, s);
		}
	}		
	
	/********************************/
   /* Test norm_s                  */
	/********************************/
	testComment (&testRec, "Testing norm_s");
	for(i=0;i<len_norm_s_data;i++)
	{
		z16 = norm_s(norm_s_data[i*NORM_S_SPAN]);
		if (z16 != norm_s_data[i*NORM_S_SPAN+NORM_S_SPAN-1])
		{
			sprintf(s, "norm_s expected = %x, actual = %x", 
						norm_s_data[i*NORM_S_SPAN+NORM_S_SPAN-1], 
						z16);
			testFailed(&testRec, s);
		}
	}		

	/******************/
   /* Test rand      */
	/******************/
	testComment (&testRec, "Testing rand");
	
	mfr16SetRandSeed (0xA5A5);
	
	for(i=0;i<len_rand_data;i++)
	{
		z16 = mfr16Rand();

		if (z16 != rand_data[i*RAND_SPAN])
		{
			sprintf(s, "rand expected = %x, actual = %x", 
							rand_data[i*RAND_SPAN], z16);
			testFailed(&testRec, s);
		}
	}		
	
	/******************/
   /* Test sqrt      */
	/******************/
	testComment (&testRec, "Testing sqrt");
	for(i=0;i<len_sqrt_data;i++)
	{
		z16 = mfr16Sqrt(sqrt_data[i*SQRT_SPAN]);

		if (z16 != sqrt_data[i*SQRT_SPAN+SQRT_SPAN-1])
		{
			sprintf(s, "sqrt expected = %x, actual = %x", sqrt_data[i*SQRT_SPAN+SQRT_SPAN-1], z16);
			testFailed(&testRec, s);
		}
	}		
			
	testEnd(&testRec);

   return PASS;
}





