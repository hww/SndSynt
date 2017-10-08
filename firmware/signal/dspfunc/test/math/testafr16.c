#include <stdio.h>

#include "port.h"
#include "arch.h"
#include "prototype.h"
#include "afr16.h"
#include "mfr16.h"
#include "test.h"
#include "testdata16.h"
#include "testdata32.h"
#include "mem.h"


EXPORT void    afr16AbsC    (Frac16 *pX, Frac16 *pZ, UInt16 n);

EXPORT void    afr16AddC    (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT void    afr16DivC    (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT bool    afr16EqualC  (Frac16 *pX, Frac16 *pY, UInt16 n);

EXPORT void    afr16Mac_rC  (Frac16 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT Frac16  afr16MaxC    (Frac16 *pX, UInt16 n, UInt16 *pMaxIndex);

EXPORT Frac16  afr16MinC    (Frac16 *pX, UInt16 n, UInt16 *pMinIndex);

EXPORT void    afr16Msu_rC  (Frac16 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT void    afr16MultC   (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);
EXPORT void    afr16Mult_rC (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT void    afr16NegateC (Frac16 *pX, Frac16 *pZ, UInt16 n);

EXPORT void    afr16RandC   (Frac16 *pZ, UInt16 n);

EXPORT void    afr16SqrtC   (Frac16 *pX, Frac16 *pZ, UInt16 n);

EXPORT void    afr16SubC    (Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);


/*-----------------------------------------------------------------------*

    testafr16.c
	
*------------------------------------------------------------------------*/

EXPORT Result testafr16(void);

Result testafr16(void)
{
	Frac16         x16, y16, z16;
	Frac16       * pW;
	Frac16       * pX;
	Frac16       * pY;
	Frac16       * pZ;
	Frac16       * pRes;
   UInt16         i;
	char           s[256];
	test_sRec      testRec;

	/* DSP Function Library initialization must have been performed */
	
	testStart (&testRec, "testafr16");

	/******************/
   /* Test abs_s     */
	/******************/
	testComment (&testRec, "Testing abs_s");
	
	/* Test abs_s in external memory */
	
	pX   = (Frac16 *)memMallocEM (len_abs_s_data * sizeof(abs_s_data[0]));
	pZ   = (Frac16 *)memMallocEM (len_abs_s_data * sizeof(abs_s_data[0]));
	pRes = (Frac16 *)memMallocEM (len_abs_s_data * sizeof(abs_s_data[0]));
	
	for(i=0;i<len_abs_s_data;i++)
	{
		*(pX+i) = abs_s_data[i*ABS_S_SPAN];
		*(pRes+i) = abs_s_data[i*ABS_S_SPAN + ABS_S_SPAN-1];
	}

	afr16Abs (pX, pZ, len_abs_s_data);
	
	if (!afr16Equal(pZ, pRes, len_abs_s_data))
	{
			testFailed(&testRec, "afr16Abs_s error");
	}
	
	/* Test C version */
	
	afr16AbsC (pX, pZ, len_abs_s_data);
	
	if (!afr16EqualC(pZ, pRes, len_abs_s_data))
	{
			testFailed(&testRec, "afr16Abs_sC error");
	}
	
	/* Test operation in-place */
	
	afr16Abs (pX, pX, len_abs_s_data);
	
	if (!afr16Equal(pX, pRes, len_abs_s_data))
	{
			testFailed(&testRec, "afr16Abs_s in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test abs_s in internal memory */
	
	pX   = (Frac16 *)memMallocIM (len_abs_s_data * sizeof(abs_s_data[0]));
	pZ   = (Frac16 *)memMallocIM (len_abs_s_data * sizeof(abs_s_data[0]));
	pRes = (Frac16 *)memMallocIM (len_abs_s_data * sizeof(abs_s_data[0]));
	
	for(i=0;i<len_abs_s_data;i++)
	{
		*(pX+i) = abs_s_data[i*ABS_S_SPAN];
		*(pRes+i) = abs_s_data[i*ABS_S_SPAN + ABS_S_SPAN-1];
	}

	afr16Abs (pX, pZ, len_abs_s_data);
	
	if (!afr16Equal(pZ, pRes, len_abs_s_data))
	{
			testFailed(&testRec, "afr16Abs_s error");
	}
	
	/* Test operation in-place */
	
	afr16Abs (pX, pX, len_abs_s_data);
	
	if (!afr16Equal(pX, pRes, len_abs_s_data))
	{
			testFailed(&testRec, "afr16Abs_s in-place error");
	}
	
	memFreeIM(pX);
	memFreeIM(pZ);
	memFreeIM(pRes);		

	/******************/
   /* Test add       */
	/******************/
	testComment (&testRec, "Testing add");

	/* Test add in external memory */
	
	pX   = (Frac16 *)memMallocEM (len_add_data * sizeof(add_data[0]));
	pY   = (Frac16 *)memMallocEM (len_add_data * sizeof(add_data[0]));
	pZ   = (Frac16 *)memMallocEM (len_add_data * sizeof(add_data[0]));
	pRes = (Frac16 *)memMallocEM (len_add_data * sizeof(add_data[0]));
	
	for(i=0;i<len_add_data;i++)
	{
		*(pX+i)   = add_data[i*ADD_SPAN];
		*(pY+i)   = add_data[i*ADD_SPAN + 1];
		*(pRes+i) = add_data[i*ADD_SPAN + ADD_SPAN-1];
	}

	afr16Add (pX, pY, pZ, len_add_data);
	
	if (!afr16Equal(pZ, pRes, len_add_data))
	{
			testFailed(&testRec, "afr16Add error");
	}
	
	/* Test C version */
	
	afr16AddC (pX, pY, pZ, len_add_data);
	
	if (!afr16EqualC(pZ, pRes, len_add_data))
	{
			testFailed(&testRec, "afr16AddC error");
	}
	
	/* Test operation in-place */
	
	afr16Add (pX, pY, pX, len_add_data);
	
	if (!afr16Equal(pX, pRes, len_add_data))
	{
			testFailed(&testRec, "afr16Add in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pY);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test add in internal memory */
	
	pX   = (Frac16 *)memMallocIM (len_add_data * sizeof(add_data[0]));
	pY   = (Frac16 *)memMallocIM (len_add_data * sizeof(add_data[0]));
	pZ   = (Frac16 *)memMallocIM (len_add_data * sizeof(add_data[0]));
	pRes = (Frac16 *)memMallocIM (len_add_data * sizeof(add_data[0]));
	
	for(i=0;i<len_add_data;i++)
	{
		*(pX+i)   = add_data[i*ADD_SPAN];
		*(pY+i)   = add_data[i*ADD_SPAN + 1];
		*(pRes+i) = add_data[i*ADD_SPAN + ADD_SPAN-1];
	}

	afr16Add (pX, pY, pZ, len_add_data);
	
	if (!afr16Equal(pZ, pRes, len_add_data))
	{
			testFailed(&testRec, "afr16Add error");
	}
	
	/* Test operation in-place */
	
	afr16Add (pX, pY, pX, len_add_data);
	
	if (!afr16Equal(pX, pRes, len_add_data))
	{
			testFailed(&testRec, "afr16Add in-place error");
	}
	
	memFreeIM(pX);
	memFreeIM(pY);
	memFreeIM(pZ);
	memFreeIM(pRes);		
		
	
	/******************/
   /* Test sub       */
	/******************/
	testComment (&testRec, "Testing sub");

	/* Test sub in external memory */
	
	pX   = (Frac16 *)memMallocEM (len_sub_data * sizeof(sub_data[0]));
	pY   = (Frac16 *)memMallocEM (len_sub_data * sizeof(sub_data[0]));
	pZ   = (Frac16 *)memMallocEM (len_sub_data * sizeof(sub_data[0]));
	pRes = (Frac16 *)memMallocEM (len_sub_data * sizeof(sub_data[0]));
	
	for(i=0;i<len_sub_data;i++)
	{
		*(pX+i)   = sub_data[i*SUB_SPAN];
		*(pY+i)   = sub_data[i*SUB_SPAN + 1];
		*(pRes+i) = sub_data[i*SUB_SPAN + SUB_SPAN-1];
	}

	afr16Sub (pX, pY, pZ, len_sub_data);
	
	if (!afr16Equal(pZ, pRes, len_sub_data))
	{
			testFailed(&testRec, "afr16Sub error");
	}
	
	/* Test C version */
	
	afr16SubC (pX, pY, pZ, len_sub_data);
	
	if (!afr16EqualC(pZ, pRes, len_sub_data))
	{
			testFailed(&testRec, "afr16SubC error");
	}
	
	/* Test operation in-place */
	
	afr16Sub (pX, pY, pX, len_sub_data);
	
	if (!afr16Equal(pX, pRes, len_sub_data))
	{
			testFailed(&testRec, "afr16Sub in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pY);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test sub in internal memory */
	
	pX   = (Frac16 *)memMallocIM (len_sub_data * sizeof(sub_data[0]));
	pY   = (Frac16 *)memMallocIM (len_sub_data * sizeof(sub_data[0]));
	pZ   = (Frac16 *)memMallocIM (len_sub_data * sizeof(sub_data[0]));
	pRes = (Frac16 *)memMallocIM (len_sub_data * sizeof(sub_data[0]));
	
	for(i=0;i<len_sub_data;i++)
	{
		*(pX+i)   = sub_data[i*SUB_SPAN];
		*(pY+i)   = sub_data[i*SUB_SPAN + 1];
		*(pRes+i) = sub_data[i*SUB_SPAN + SUB_SPAN-1];
	}

	afr16Sub (pX, pY, pZ, len_sub_data);
	
	if (!afr16Equal(pZ, pRes, len_sub_data))
	{
			testFailed(&testRec, "afr16Sub error");
	}
	
	/* Test operation in-place */
	
	afr16Sub (pX, pY, pX, len_sub_data);
	
	if (!afr16Equal(pX, pRes, len_sub_data))
	{
			testFailed(&testRec, "afr16Sub in-place error");
	}
	
	memFreeIM(pX);
	memFreeIM(pY);
	memFreeIM(pZ);
	memFreeIM(pRes);		
	
	
	/******************/
   /* Test div       */
	/******************/
	testComment (&testRec, "Testing div");
	
	/* Test div_s in external memory */
	
	pX   = (Frac16 *)memMallocEM (len_div_s_data * sizeof(div_s_data[0]));
	pY   = (Frac16 *)memMallocEM (len_div_s_data * sizeof(div_s_data[0]));
	pZ   = (Frac16 *)memMallocEM (len_div_s_data * sizeof(div_s_data[0]));
	pRes = (Frac16 *)memMallocEM (len_div_s_data * sizeof(div_s_data[0]));
	
	for(i=0;i<len_div_s_data;i++)
	{
		*(pX+i)   = div_s_data[i*DIV_S_SPAN];
		*(pY+i)   = div_s_data[i*DIV_S_SPAN + 1];
		*(pRes+i) = div_s_data[i*DIV_S_SPAN + DIV_S_SPAN-1];
	}

	afr16Div (pX, pY, pZ, len_div_s_data);
	
	if (!afr16Equal(pZ, pRes, len_div_s_data))
	{
			testFailed(&testRec, "afr16Div error");
	}
	
	/* Test C version */
	
	afr16DivC (pX, pY, pZ, len_div_s_data);
	
	if (!afr16EqualC(pZ, pRes, len_div_s_data))
	{
			testFailed(&testRec, "afr16DivC error");
	}
	
	/* Test operation in-place */
	
	afr16Div (pX, pY, pX, len_div_s_data);
	
	if (!afr16Equal(pX, pRes, len_div_s_data))
	{
			testFailed(&testRec, "afr16Div in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pY);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test div in internal memory */

	pX   = (Frac16 *)memMallocIM (len_div_s_data * sizeof(div_s_data[0]));
	pY   = (Frac16 *)memMallocIM (len_div_s_data * sizeof(div_s_data[0]));
	pZ   = (Frac16 *)memMallocIM (len_div_s_data * sizeof(div_s_data[0]));
	pRes = (Frac16 *)memMallocIM (len_div_s_data * sizeof(div_s_data[0]));
	
	for(i=0;i<len_div_s_data;i++)
	{
		*(pX+i)   = div_s_data[i*DIV_S_SPAN];
		*(pY+i)   = div_s_data[i*DIV_S_SPAN + 1];
		*(pRes+i) = div_s_data[i*DIV_S_SPAN + DIV_S_SPAN-1];
	}

	afr16Div (pX, pY, pZ, len_div_s_data);
	
	if (!afr16Equal(pZ, pRes, len_div_s_data))
	{
			testFailed(&testRec, "afr16Div error");
	}
	
	/* Test operation in-place */
	
	afr16Div (pX, pY, pX, len_div_s_data);
	
	if (!afr16Equal(pX, pRes, len_div_s_data))
	{
			testFailed(&testRec, "afr16Div in-place error");
	}
	
	memFreeIM(pX);
	memFreeIM(pY);
	memFreeIM(pZ);
	memFreeIM(pRes);		
	

	/******************/
   /* Test max       */
	/******************/
	testComment (&testRec, "Testing max");

	/* Test max in external memory */
	
	pX   = (Frac16 *)memMallocEM (len_min_max_data * sizeof(min_max_data[0]));
	
	for(i=0;i<len_min_max_data;i++)
	{
		*(pX+i)   = min_max_data[i * MIN_MAX_SPAN ];
	}

	i = 0;
	x16 = afr16Max (pX, len_min_max_data, &i);
	
	if (i!=1 || x16!=0x7fff)
	{
			testFailed(&testRec, "afr16Max error");
	}
	
	/* Test C version */
	
	x16 = afr16MaxC (pX, len_min_max_data, &i);
	
	if (i!=1 || x16!=0x7fff)
	{
			testFailed(&testRec, "afr16MaxC error");
	}
	
	/* Test small arrays */
	
	x16 = afr16Max (pX, 1, &i);
	
	if (i!=0 || x16!=0x0000)
	{
			testFailed(&testRec, "afr16Max error");
	}
	
	x16 = afr16Max (pX, 2, &i);
	
	if (i!=1 || x16!=0x7fff)
	{
			testFailed(&testRec, "afr16Max error");
	}
	
	x16 = afr16Max (pX, len_min_max_data, NULL);
	
	if (x16!=0x7fff)
	{
			testFailed(&testRec, "afr16Max error");
	}
	
	memFreeEM (pX);

	/* Test max in internal memory */
	
	pX   = (Frac16 *)memMallocIM (len_min_max_data * sizeof(min_max_data[0]));
	
	for(i=0;i<len_min_max_data;i++)
	{
		*(pX+i)   = min_max_data[i * MIN_MAX_SPAN];
	}

	i = 0;
	x16 = afr16Max (pX, len_min_max_data, &i);
	
	if (i!=1 || x16!=0x7fff)
	{
			testFailed(&testRec, "afr16Max error");
	}
	
	x16 = afr16Max (pX, len_min_max_data, NULL);
	
	if (x16!=0x7fff)
	{
			testFailed(&testRec, "afr16Max error");
	}
	
	memFreeIM (pX);

	
	/******************/
   /* Test min       */
	/******************/
	testComment (&testRec, "Testing min");

	/* Test min in external memory */
	
	pX   = (Frac16 *)memMallocEM (len_min_max_data * sizeof(min_max_data[0]));
	
	for(i=0;i<len_min_max_data;i++)
	{
		*(pX+i)   = min_max_data[i*MIN_MAX_SPAN];
	}

	i = 0;
	x16 = afr16Min (pX, len_min_max_data, &i);
	
	if (i!=2 || x16!=0x8000)
	{
			testFailed(&testRec, "afr16Min error");
	}
	
	/* Test C version */
	
	x16 = afr16MinC (pX, len_min_max_data, &i);
	
	if (i!=2 || x16!=0x8000)
	{
			testFailed(&testRec, "afr16MinC error");
	}
	
	/* Test small arrays */
	
	x16 = afr16Min (pX, 1, &i);
	
	if (i!=0 || x16!=0x0000)
	{
			testFailed(&testRec, "afr16Min error");
	}
	
	x16 = afr16Min (pX, 2, &i);
	
	if (i!=0 || x16!=0x0000)
	{
			testFailed(&testRec, "afr16Min error");
	}
	
	x16 = afr16Min (pX, len_min_max_data, NULL);
	
	if (x16!=0x8000)
	{
			testFailed(&testRec, "afr16Min error");
	}
	
	memFreeEM (pX);

	/* Test min in internal memory */
	
	pX   = (Frac16 *)memMallocIM (len_min_max_data * sizeof(min_max_data[0]));
	
	for(i=0;i<len_min_max_data;i++)
	{
		*(pX+i)   = min_max_data[i*MIN_MAX_SPAN];
	}

	i = 0;
	x16 = afr16Min (pX, len_min_max_data, &i);
	
	if (i!=2 || x16!=0x8000)
	{
			testFailed(&testRec, "afr16Min error");
	}
	
	x16 = afr16Min (pX, len_min_max_data, NULL);
	
	if (x16!=0x8000)
	{
			testFailed(&testRec, "afr16Min error");
	}
	
	memFreeIM (pX);


	/******************/
   /* Test mac_r     */
	/******************/
	testComment (&testRec, "Testing mac_r");
	
	/* Test mac_r in external memory */
	
	pW   = (Frac16 *)memMallocEM (len_mac_r_data * sizeof(mac_r_data[0]));
	pX   = (Frac16 *)memMallocEM (len_mac_r_data * sizeof(mac_r_data[0]));
	pY   = (Frac16 *)memMallocEM (len_mac_r_data * sizeof(mac_r_data[0]));
	pZ   = (Frac16 *)memMallocEM (len_mac_r_data * sizeof(mac_r_data[0]));
	pRes = (Frac16 *)memMallocEM (len_mac_r_data * sizeof(mac_r_data[0]));
	
	for(i=0;i<len_mac_r_data;i++)
	{
		*(pW+i)   = extract_h(mac_r_data[i*MAC_R_SPAN]);
		*(pX+i)   = extract_h(mac_r_data[i*MAC_R_SPAN + 1]);
		*(pY+i)   = extract_h(mac_r_data[i*MAC_R_SPAN + 2]);
		*(pRes+i) = extract_h(mac_r_data[i*MAC_R_SPAN + MAC_R_SPAN-1]);
	}

	afr16Mac_r (pW, pX, pY, pZ, len_mac_r_data);
	
	if (!afr16Equal(pZ, pRes, len_mac_r_data))
	{
			testFailed(&testRec, "afr16Mac_r error");
	}
	
	/* Test C version */
	
	afr16Mac_rC (pW, pX, pY, pZ, len_mac_r_data);
	
	if (!afr16EqualC(pZ, pRes, len_mac_r_data))
	{
			testFailed(&testRec, "afr16Mac_rC error");
	}

	/* Test operation in-place */
	
	afr16Mac_r (pW, pX, pY, pW, len_mac_r_data);
	
	if (!afr16Equal(pW, pRes, len_mac_r_data))
	{
			testFailed(&testRec, "afr16Mac_r in-place error");
	}
	
	memFreeEM(pW);
	memFreeEM(pX);
	memFreeEM(pY);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test mac_r in internal memory */
	
	pW   = (Frac16 *)memMallocIM (len_mac_r_data * sizeof(mac_r_data[0]));
	pX   = (Frac16 *)memMallocIM (len_mac_r_data * sizeof(mac_r_data[0]));
	pY   = (Frac16 *)memMallocIM (len_mac_r_data * sizeof(mac_r_data[0]));
	pZ   = (Frac16 *)memMallocIM (len_mac_r_data * sizeof(mac_r_data[0]));
	pRes = (Frac16 *)memMallocIM (len_mac_r_data * sizeof(mac_r_data[0]));
	
	for(i=0;i<len_mac_r_data;i++)
	{
		*(pW+i)   = extract_h(mac_r_data[i*MAC_R_SPAN]);
		*(pX+i)   = extract_h(mac_r_data[i*MAC_R_SPAN + 1]);
		*(pY+i)   = extract_h(mac_r_data[i*MAC_R_SPAN + 2]);
		*(pRes+i) = extract_h(mac_r_data[i*MAC_R_SPAN + MAC_R_SPAN-1]);
	}

	afr16Mac_r (pW, pX, pY, pZ, len_mac_r_data);
	
	if (!afr16Equal(pZ, pRes, len_mac_r_data))
	{
			testFailed(&testRec, "afr16Mac_r error");
	}
	
	/* Test operation in-place */
	
	afr16Mac_r (pW, pX, pY, pW, len_mac_r_data);
	
	if (!afr16Equal(pW, pRes, len_mac_r_data))
	{
			testFailed(&testRec, "afr16Mac_r in-place error");
	}
	
	memFreeIM(pW);
	memFreeIM(pX);
	memFreeIM(pY);
	memFreeIM(pZ);
	memFreeIM(pRes);		


	/******************/
   /* Test msu_r     */
	/******************/
	testComment (&testRec, "Testing msu_r");
	
	/* Test msu_r in external memory */
	
	pW   = (Frac16 *)memMallocEM (len_msu_r_data * sizeof(msu_r_data[0]));
	pX   = (Frac16 *)memMallocEM (len_msu_r_data * sizeof(msu_r_data[0]));
	pY   = (Frac16 *)memMallocEM (len_msu_r_data * sizeof(msu_r_data[0]));
	pZ   = (Frac16 *)memMallocEM (len_msu_r_data * sizeof(msu_r_data[0]));
	pRes = (Frac16 *)memMallocEM (len_msu_r_data * sizeof(msu_r_data[0]));
	
	for(i=0;i<len_msu_r_data;i++)
	{
		*(pW+i)   = extract_h(msu_r_data[i*MSU_R_SPAN]);
		*(pX+i)   = extract_h(msu_r_data[i*MSU_R_SPAN + 1]);
		*(pY+i)   = extract_h(msu_r_data[i*MSU_R_SPAN + 2]);
		*(pRes+i) = extract_h(msu_r_data[i*MSU_R_SPAN + MSU_R_SPAN-1]);
	}

	afr16Msu_r (pW, pX, pY, pZ, len_msu_r_data);
	
	if (!afr16Equal(pZ, pRes, len_msu_r_data))
	{
			testFailed(&testRec, "afr16Msu_r error");
	}
	
	/* Test C version */
	
	afr16Msu_rC (pW, pX, pY, pZ, len_msu_r_data);
	
	if (!afr16EqualC(pZ, pRes, len_msu_r_data))
	{
			testFailed(&testRec, "afr16Msu_rC error");
	}
	
	/* Test operation in-place */
	
	afr16Msu_r (pW, pX, pY, pW, len_msu_r_data);
	
	if (!afr16Equal(pW, pRes, len_msu_r_data))
	{
			testFailed(&testRec, "afr16Msu_r in-place error");
	}
	
	memFreeEM(pW);
	memFreeEM(pX);
	memFreeEM(pY);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test msu_r in internal memory */
	
	pW   = (Frac16 *)memMallocIM (len_msu_r_data * sizeof(msu_r_data[0]));
	pX   = (Frac16 *)memMallocIM (len_msu_r_data * sizeof(msu_r_data[0]));
	pY   = (Frac16 *)memMallocIM (len_msu_r_data * sizeof(msu_r_data[0]));
	pZ   = (Frac16 *)memMallocIM (len_msu_r_data * sizeof(msu_r_data[0]));
	pRes = (Frac16 *)memMallocIM (len_msu_r_data * sizeof(msu_r_data[0]));
	
	for(i=0;i<len_msu_r_data;i++)
	{
		*(pW+i)   = extract_h(msu_r_data[i*MSU_R_SPAN]);
		*(pX+i)   = extract_h(msu_r_data[i*MSU_R_SPAN + 1]);
		*(pY+i)   = extract_h(msu_r_data[i*MSU_R_SPAN + 2]);
		*(pRes+i) = extract_h(msu_r_data[i*MSU_R_SPAN + MSU_R_SPAN-1]);
	}

	afr16Msu_r (pW, pX, pY, pZ, len_msu_r_data);
	
	if (!afr16Equal(pZ, pRes, len_msu_r_data))
	{
			testFailed(&testRec, "afr16Msu_r error");
	}
	
	/* Test operation in-place */
	
	afr16Msu_r (pW, pX, pY, pW, len_msu_r_data);
	
	if (!afr16Equal(pW, pRes, len_msu_r_data))
	{
			testFailed(&testRec, "afr16Msu_r in-place error");
	}
	
	memFreeIM(pW);
	memFreeIM(pX);
	memFreeIM(pY);
	memFreeIM(pZ);
	memFreeIM(pRes);		

	
	/******************/
   /* Test mult      */
	/******************/
	testComment (&testRec, "Testing mult");

	/* Test mult in external memory */
	
	pX   = (Frac16 *)memMallocEM (len_mult_data * sizeof(mult_data[0]));
	pY   = (Frac16 *)memMallocEM (len_mult_data * sizeof(mult_data[0]));
	pZ   = (Frac16 *)memMallocEM (len_mult_data * sizeof(mult_data[0]));
	pRes = (Frac16 *)memMallocEM (len_mult_data * sizeof(mult_data[0]));
	
	for(i=0;i<len_mult_data;i++)
	{
		*(pX+i)   = mult_data[i*MULT_SPAN];
		*(pY+i)   = mult_data[i*MULT_SPAN + 1];
		*(pRes+i) = mult_data[i*MULT_SPAN + MULT_SPAN-1];
	}

	afr16Mult (pX, pY, pZ, len_mult_data);
	
	if (!afr16Equal(pZ, pRes, len_mult_data))
	{
			testFailed(&testRec, "afr16Mult error");
	}

	/* Test C version */
	
	afr16MultC (pX, pY, pZ, len_mult_data);
	
	if (!afr16EqualC(pZ, pRes, len_mult_data))
	{
			testFailed(&testRec, "afr16MultC error");
	}
		
	/* Test operation in-place */
	
	afr16Mult (pX, pY, pX, len_mult_data);
	
	if (!afr16Equal(pX, pRes, len_mult_data))
	{
			testFailed(&testRec, "afr16Mult in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pY);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test mult in internal memory */
	
	pX   = (Frac16 *)memMallocIM (len_mult_data * sizeof(mult_data[0]));
	pY   = (Frac16 *)memMallocIM (len_mult_data * sizeof(mult_data[0]));
	pZ   = (Frac16 *)memMallocIM (len_mult_data * sizeof(mult_data[0]));
	pRes = (Frac16 *)memMallocIM (len_mult_data * sizeof(mult_data[0]));
	
	for(i=0;i<len_mult_data;i++)
	{
		*(pX+i)   = mult_data[i*MULT_SPAN];
		*(pY+i)   = mult_data[i*MULT_SPAN + 1];
		*(pRes+i) = mult_data[i*MULT_SPAN + MULT_SPAN-1];
	}

	afr16Mult (pX, pY, pZ, len_mult_data);
	
	if (!afr16Equal(pZ, pRes, len_mult_data))
	{
			testFailed(&testRec, "afr16Mult error");
	}
	
	/* Test operation in-place */
	
	afr16Mult (pX, pY, pX, len_mult_data);
	
	if (!afr16Equal(pX, pRes, len_mult_data))
	{
			testFailed(&testRec, "afr16Mult in-place error");
	}
	
	memFreeIM(pX);
	memFreeIM(pY);
	memFreeIM(pZ);
	memFreeIM(pRes);		


	/******************/
   /* Test mult_r    */
	/******************/
	testComment (&testRec, "Testing mult_r");

	/* Test mult in external memory */
	
	pX   = (Frac16 *)memMallocEM (len_mult_r_data * sizeof(mult_r_data[0]));
	pY   = (Frac16 *)memMallocEM (len_mult_r_data * sizeof(mult_r_data[0]));
	pZ   = (Frac16 *)memMallocEM (len_mult_r_data * sizeof(mult_r_data[0]));
	pRes = (Frac16 *)memMallocEM (len_mult_r_data * sizeof(mult_r_data[0]));
	
	for(i=0;i<len_mult_data;i++)
	{
		*(pX+i)   = mult_r_data[i*MULT_R_SPAN];
		*(pY+i)   = mult_r_data[i*MULT_R_SPAN + 1];
		*(pRes+i) = mult_r_data[i*MULT_R_SPAN + MULT_R_SPAN-1];
	}

	afr16Mult_r (pX, pY, pZ, len_mult_r_data);
	
	if (!afr16Equal(pZ, pRes, len_mult_r_data))
	{
			testFailed(&testRec, "afr16Mult_r error");
	}
	
	/* Test C version */
	
	afr16Mult_rC (pX, pY, pZ, len_mult_r_data);
	
	if (!afr16EqualC(pZ, pRes, len_mult_r_data))
	{
			testFailed(&testRec, "afr16Mult_rC error");
	}
	
	
	/* Test operation in-place */
	
	afr16Mult_r (pX, pY, pX, len_mult_r_data);
	
	if (!afr16Equal(pX, pRes, len_mult_r_data))
	{
			testFailed(&testRec, "afr16Mult_r in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pY);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test mult in internal memory */
	
	pX   = (Frac16 *)memMallocIM (len_mult_r_data * sizeof(mult_r_data[0]));
	pY   = (Frac16 *)memMallocIM (len_mult_r_data * sizeof(mult_r_data[0]));
	pZ   = (Frac16 *)memMallocIM (len_mult_r_data * sizeof(mult_r_data[0]));
	pRes = (Frac16 *)memMallocIM (len_mult_r_data * sizeof(mult_r_data[0]));
	
	for(i=0;i<len_mult_data;i++)
	{
		*(pX+i)   = mult_r_data[i*MULT_R_SPAN];
		*(pY+i)   = mult_r_data[i*MULT_R_SPAN + 1];
		*(pRes+i) = mult_r_data[i*MULT_R_SPAN + MULT_R_SPAN-1];
	}

	afr16Mult_r (pX, pY, pZ, len_mult_r_data);
	
	if (!afr16Equal(pZ, pRes, len_mult_r_data))
	{
			testFailed(&testRec, "afr16Mult_r error");
	}
	
	/* Test operation in-place */
	
	afr16Mult_r (pX, pY, pX, len_mult_r_data);
	
	if (!afr16Equal(pX, pRes, len_mult_r_data))
	{
			testFailed(&testRec, "afr16Mult_r in-place error");
	}
	
	memFreeIM(pX);
	memFreeIM(pY);
	memFreeIM(pZ);
	memFreeIM(pRes);		


	/******************/
   /* Test negate    */
	/******************/
	testComment (&testRec, "Testing negate");

	/* Test negate in external memory */
	
	pX   = (Frac16 *)memMallocEM (len_negate_data * sizeof(negate_data[0]));
	pZ   = (Frac16 *)memMallocEM (len_negate_data * sizeof(negate_data[0]));
	pRes = (Frac16 *)memMallocEM (len_negate_data * sizeof(negate_data[0]));
	
	for(i=0;i<len_negate_data;i++)
	{
		*(pX+i) = negate_data[i*NEGATE_SPAN];
		*(pRes+i) = negate_data[i*NEGATE_SPAN + NEGATE_SPAN-1];
	}

	afr16Negate (pX, pZ, len_negate_data);
	
	if (!afr16Equal(pZ, pRes, len_negate_data))
	{
			testFailed(&testRec, "afr16Negate error");
	}
	
	/* Test C version */
	
	afr16NegateC (pX, pZ, len_negate_data);
	
	if (!afr16EqualC(pZ, pRes, len_negate_data))
	{
			testFailed(&testRec, "afr16NegateC error");
	}
	
	/* Test operation in-place */
	
	afr16Negate (pX, pX, len_negate_data);
	
	if (!afr16Equal(pX, pRes, len_negate_data))
	{
			testFailed(&testRec, "afr16Negate in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test negate in internal memory */
	
	pX   = (Frac16 *)memMallocIM (len_negate_data * sizeof(negate_data[0]));
	pZ   = (Frac16 *)memMallocIM (len_negate_data * sizeof(negate_data[0]));
	pRes = (Frac16 *)memMallocIM (len_negate_data * sizeof(negate_data[0]));
	
	for(i=0;i<len_negate_data;i++)
	{
		*(pX+i) = negate_data[i*NEGATE_SPAN];
		*(pRes+i) = negate_data[i*NEGATE_SPAN + NEGATE_SPAN-1];
	}

	afr16Negate (pX, pZ, len_negate_data);
	
	if (!afr16Equal(pZ, pRes, len_negate_data))
	{
			testFailed(&testRec, "afr16Negate error");
	}
	
	/* Test operation in-place */
	
	afr16Negate (pX, pX, len_negate_data);
	
	if (!afr16Equal(pX, pRes, len_negate_data))
	{
			testFailed(&testRec, "afr16Negate in-place error");
	}
	
	memFreeIM(pX);
	memFreeIM(pZ);
	memFreeIM(pRes);		

	/******************/
   /* Test rand      */
	/******************/
	testComment (&testRec, "Testing rand");
	
	/* Test rand in external memory */

	mfr16SetRandSeed (0xA5A5);
		
	pZ   = (Frac16 *)memMallocEM (len_rand_data * sizeof(rand_data[0]));
	pRes = (Frac16 *)memMallocEM (len_rand_data * sizeof(rand_data[0]));
	
	for(i=0;i<len_rand_data;i++)
	{
		*(pRes+i) = rand_data[i*RAND_SPAN + RAND_SPAN-1];
	}

	afr16Rand (pZ, len_rand_data);
	
	if (!afr16Equal(pZ, pRes, len_rand_data))
	{
			testFailed(&testRec, "afr16Rand error");
	}

	/* Test C version */
	
	mfr16SetRandSeed (0xA5A5);
		
	afr16RandC (pZ, len_rand_data);
	
	if (!afr16EqualC(pZ, pRes, len_rand_data))
	{
			testFailed(&testRec, "afr16RandC error");
	}
		
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test rand in internal memory */

	mfr16SetRandSeed (0xA5A5);
		
	pZ   = (Frac16 *)memMallocIM (len_rand_data * sizeof(rand_data[0]));
	pRes = (Frac16 *)memMallocIM (len_rand_data * sizeof(rand_data[0]));
	
	for(i=0;i<len_rand_data;i++)
	{
		*(pRes+i) = rand_data[i*RAND_SPAN + RAND_SPAN-1];
	}

	afr16Rand (pZ, len_rand_data);
	
	if (!afr16Equal(pZ, pRes, len_rand_data))
	{
			testFailed(&testRec, "afr16Rand error");
	}
		
	memFreeIM(pZ);
	memFreeIM(pRes);		

	
	/******************/
   /* Test sqrt      */
	/******************/
	testComment (&testRec, "Testing sqrt");

	/* Test sqrt in external memory */
	
	pX   = (Frac16 *)memMallocEM (len_sqrt_data * sizeof(sqrt_data[0]));
	pZ   = (Frac16 *)memMallocEM (len_sqrt_data * sizeof(sqrt_data[0]));
	pRes = (Frac16 *)memMallocEM (len_sqrt_data * sizeof(sqrt_data[0]));
	
	for(i=0;i<len_sqrt_data;i++)
	{
		*(pX+i)   = sqrt_data[i*SQRT_SPAN];
		*(pRes+i) = sqrt_data[i*SQRT_SPAN + SQRT_SPAN-1];
	}

	afr16Sqrt (pX, pZ, len_sqrt_data);
	
	if (!afr16Equal(pZ, pRes, len_sqrt_data))
	{
			testFailed(&testRec, "afr16Sqrt error");
	}
	
	/* Test C version */
	
	afr16SqrtC (pX, pZ, len_sqrt_data);
	
	if (!afr16EqualC(pZ, pRes, len_sqrt_data))
	{
			testFailed(&testRec, "afr16SqrtC error");
	}
	
	/* Test operation in-place */
	
	afr16Sqrt (pX, pX, len_sqrt_data);
	
	if (!afr16Equal(pX, pRes, len_sqrt_data))
	{
			testFailed(&testRec, "afr16Sqrt in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test sqrt in internal memory */
	
	pX   = (Frac16 *)memMallocIM (len_sqrt_data * sizeof(sqrt_data[0]));
	pZ   = (Frac16 *)memMallocIM (len_sqrt_data * sizeof(sqrt_data[0]));
	pRes = (Frac16 *)memMallocIM (len_sqrt_data * sizeof(sqrt_data[0]));
	
	for(i=0;i<len_sqrt_data;i++)
	{
		*(pX+i)   = sqrt_data[i*SQRT_SPAN];
		*(pRes+i) = sqrt_data[i*SQRT_SPAN + SQRT_SPAN-1];
	}

	afr16Sqrt (pX, pZ, len_sqrt_data);
	
	if (!afr16Equal(pZ, pRes, len_sqrt_data))
	{
			testFailed(&testRec, "afr16Sqrt error");
	}
	
	/* Test operation in-place */
	
	afr16Sqrt (pX, pX, len_sqrt_data);
	
	if (!afr16Equal(pX, pRes, len_sqrt_data))
	{
			testFailed(&testRec, "afr16Sqrt in-place error");
	}
	
	memFreeIM(pX);
	memFreeIM(pZ);
	memFreeIM(pRes);		

			
	testEnd(&testRec);

   return PASS;
}





