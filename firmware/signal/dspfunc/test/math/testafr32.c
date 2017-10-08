#include <stdio.h>

#include "port.h"
#include "arch.h"
#include "prototype.h"
#include "afr32.h"
#include "afr16.h"
#include "tfr16.h"
#include "test.h"
#include "testdata32.h"
#include "mem.h"


EXPORT void    afr32AbsC    (Frac32 *pX, Frac32 *pZ, UInt16 n);

EXPORT void    afr32AddC    (Frac32 *pX, Frac32 *pY, Frac32 *pZ, UInt16 n);

EXPORT void    afr32DivC    (Frac32 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT bool    afr32EqualC  (Frac32 *pX, Frac32 *pY, UInt16 n);

EXPORT void    afr32MacC    (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n);
EXPORT void    afr32Mac_rC  (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT Frac32  afr32MaxC    (Frac32 *pX, UInt16 n, UInt16 *pMaxIndex);

EXPORT Frac32  afr32MinC    (Frac32 *pX, UInt16 n, UInt16 *pMinIndex);

EXPORT void    afr32MsuC    (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n);
EXPORT void    afr32Msu_rC  (Frac32 *pW, Frac16 *pX, Frac16 *pY, Frac16 *pZ, UInt16 n);

EXPORT void    afr32MultC   (Frac16 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n);
EXPORT void    afr32Mult_lsC(Frac32 *pX, Frac16 *pY, Frac32 *pZ, UInt16 n);

EXPORT void    afr32NegateC (Frac32 *pX, Frac32 *pZ, UInt16 n);

EXPORT void    afr32RoundC  (Frac32 *pX, Frac16 *pZ, UInt16 n);

EXPORT void    afr32SqrtC   (Frac32 *pX, Frac16 *pZ, UInt16 n);

EXPORT void    afr32SubC    (Frac32 *pX, Frac32 *pY, Frac32 *pZ, UInt16 n);


EXPORT bool    afr16EqualC  (Frac16 *pX, Frac16 *pY, UInt16 n);


/*-----------------------------------------------------------------------*

    testafr16.c
	
*------------------------------------------------------------------------*/

/* Define some C prototypes so that return value is handled correctly */

EXPORT Frac32  afr32MaxC   (Frac32 *pX, UInt16 n, UInt16 *pMaxIndex);

EXPORT Frac32  afr32MinC   (Frac32 *pX, UInt16 n, UInt16 *pMinIndex);

EXPORT Result testafr32(void);

Result testafr32(void)
{
	Frac16         x16, y16, z16;
	Frac32         x32, y32, z32;
	Frac32       * pW;
	Frac32       * pX;
	Frac16       * pX16;
	Frac32       * pY;
	Frac16       * pY16;
	Frac32       * pZ;
	Frac16       * pZ16;
	Frac32       * pRes;
	Frac16       * pRes16;
   UInt16         i;
	char           s[256];
	test_sRec      testRec;

	/* DSP Function Library initialization must have been performed */
	
	testStart (&testRec, "testafr32");

	/******************/
   /* Test abs       */
	/******************/
	testComment (&testRec, "Testing abs");
	
	/* Test L_abs in external memory */
	
	pX   = (Frac32 *)memMallocEM (len_l_abs_data * sizeof(l_abs_data[0]));
	pZ   = (Frac32 *)memMallocEM (len_l_abs_data * sizeof(l_abs_data[0]));
	pRes = (Frac32 *)memMallocEM (len_l_abs_data * sizeof(l_abs_data[0]));
	
	for(i=0;i<len_l_abs_data;i++)
	{
		*(pX+i) = l_abs_data[i*L_ABS_SPAN];
		*(pRes+i) = l_abs_data[i*L_ABS_SPAN + L_ABS_SPAN-1];
	}

	afr32Abs (pX, pZ, len_l_abs_data);
	
	if (!afr32Equal(pZ, pRes, len_l_abs_data))
	{
			testFailed(&testRec, "afr32Abs error");
	}
	
	/* Test C version */
	
	afr32AbsC (pX, pZ, len_l_abs_data);
	
	if (!afr32EqualC(pZ, pRes, len_l_abs_data))
	{
			testFailed(&testRec, "afr32AbsC error");
	}
	
	/* Test operation in-place */
	
	afr32Abs (pX, pX, len_l_abs_data);
	
	if (!afr32Equal(pX, pRes, len_l_abs_data))
	{
			testFailed(&testRec, "afr32Abs in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test L_abs in internal memory */
	
	pX   = (Frac32 *)memMallocIM (len_l_abs_data * sizeof(l_abs_data[0]));
	pZ   = (Frac32 *)memMallocIM (len_l_abs_data * sizeof(l_abs_data[0]));
	pRes = (Frac32 *)memMallocIM (len_l_abs_data * sizeof(l_abs_data[0]));
	
	for(i=0;i<len_l_abs_data;i++)
	{
		*(pX+i) = l_abs_data[i*L_ABS_SPAN];
		*(pRes+i) = l_abs_data[i*L_ABS_SPAN + L_ABS_SPAN-1];
	}

	afr32Abs (pX, pZ, len_l_abs_data);
	
	if (!afr32Equal(pZ, pRes, len_l_abs_data))
	{
			testFailed(&testRec, "afr32Abs error");
	}
	
	/* Test operation in-place */
	
	afr32Abs (pX, pX, len_l_abs_data);
	
	if (!afr32Equal(pX, pRes, len_l_abs_data))
	{
			testFailed(&testRec, "afr32Abs in-place error");
	}
	
	memFreeIM(pX);
	memFreeIM(pZ);
	memFreeIM(pRes);		

	/******************/
   /* Test add       */
	/******************/
	testComment (&testRec, "Testing add");

	/* Test add in external memory */
	
	pX   = (Frac32 *)memMallocEM (len_l_add_data * sizeof(l_add_data[0]));
	pY   = (Frac32 *)memMallocEM (len_l_add_data * sizeof(l_add_data[0]));
	pZ   = (Frac32 *)memMallocEM (len_l_add_data * sizeof(l_add_data[0]));
	pRes = (Frac32 *)memMallocEM (len_l_add_data * sizeof(l_add_data[0]));
	
	for(i=0;i<len_l_add_data;i++)
	{
		*(pX+i)   = l_add_data[i*L_ADD_SPAN];
		*(pY+i)   = l_add_data[i*L_ADD_SPAN + 1];
		*(pRes+i) = l_add_data[i*L_ADD_SPAN + L_ADD_SPAN-1];
	}

	afr32Add (pX, pY, pZ, len_l_add_data);
	
	if (!afr32Equal(pZ, pRes, len_l_add_data))
	{
			testFailed(&testRec, "afr32Add error");
	}
	
	/* Test C version */
	
	afr32AddC (pX, pY, pZ, len_l_add_data);
	
	if (!afr32EqualC(pZ, pRes, len_l_add_data))
	{
			testFailed(&testRec, "afr32AddC error");
	}
	
	/* Test operation in-place */
	
	afr32Add (pX, pY, pX, len_l_add_data);
	
	if (!afr32Equal(pX, pRes, len_l_add_data))
	{
			testFailed(&testRec, "afr32Add in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pY);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test add in internal memory */
	
	pX   = (Frac32 *)memMallocIM (len_l_add_data * sizeof(l_add_data[0]));
	pY   = (Frac32 *)memMallocIM (len_l_add_data * sizeof(l_add_data[0]));
	pZ   = (Frac32 *)memMallocIM (len_l_add_data * sizeof(l_add_data[0]));
	pRes = (Frac32 *)memMallocIM (len_l_add_data * sizeof(l_add_data[0]));
	
	for(i=0;i<len_l_add_data;i++)
	{
		*(pX+i)   = l_add_data[i*L_ADD_SPAN];
		*(pY+i)   = l_add_data[i*L_ADD_SPAN + 1];
		*(pRes+i) = l_add_data[i*L_ADD_SPAN + L_ADD_SPAN-1];
	}

	afr32Add (pX, pY, pZ, len_l_add_data);
	
	if (!afr32Equal(pZ, pRes, len_l_add_data))
	{
			testFailed(&testRec, "afr32Add error");
	}
	
	/* Test operation in-place */
	
	afr32Add (pX, pY, pX, len_l_add_data);
	
	if (!afr32Equal(pX, pRes, len_l_add_data))
	{
			testFailed(&testRec, "afr32Add in-place error");
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
	
	pX   = (Frac32 *)memMallocEM (len_l_sub_data * sizeof(l_sub_data[0]));
	pY   = (Frac32 *)memMallocEM (len_l_sub_data * sizeof(l_sub_data[0]));
	pZ   = (Frac32 *)memMallocEM (len_l_sub_data * sizeof(l_sub_data[0]));
	pRes = (Frac32 *)memMallocEM (len_l_sub_data * sizeof(l_sub_data[0]));
	
	for(i=0;i<len_l_sub_data;i++)
	{
		*(pX+i)   = l_sub_data[i*L_SUB_SPAN];
		*(pY+i)   = l_sub_data[i*L_SUB_SPAN + 1];
		*(pRes+i) = l_sub_data[i*L_SUB_SPAN + L_SUB_SPAN-1];
	}

	afr32Sub (pX, pY, pZ, len_l_sub_data);
	
	if (!afr16Equal((Frac16 *)pZ, (Frac16 *)pRes, len_l_sub_data))
	{
			testFailed(&testRec, "afr32Sub error");
	}
	
	/* Test C version */
	
	afr32SubC (pX, pY, pZ, len_l_sub_data);
	
	if (!afr32EqualC(pZ, pRes, len_l_sub_data))
	{
			testFailed(&testRec, "afr32SubC error");
	}
	
	/* Test operation in-place */
	
	afr32Sub (pX, pY, pX, len_l_sub_data);
	
	if (!afr32Equal(pX, pRes, len_l_sub_data))
	{
			testFailed(&testRec, "afr32Sub in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pY);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test sub in internal memory */
	
	pX   = (Frac32 *)memMallocIM (len_l_sub_data * sizeof(l_sub_data[0]));
	pY   = (Frac32 *)memMallocIM (len_l_sub_data * sizeof(l_sub_data[0]));
	pZ   = (Frac32 *)memMallocIM (len_l_sub_data * sizeof(l_sub_data[0]));
	pRes = (Frac32 *)memMallocIM (len_l_sub_data * sizeof(l_sub_data[0]));
	
	for(i=0;i<len_l_sub_data;i++)
	{
		*(pX+i)   = l_sub_data[i*L_SUB_SPAN];
		*(pY+i)   = l_sub_data[i*L_SUB_SPAN + 1];
		*(pRes+i) = l_sub_data[i*L_SUB_SPAN + L_SUB_SPAN-1];
	}

	afr32Sub (pX, pY, pZ, len_l_sub_data);
	
	if (!afr32Equal(pZ, pRes, len_l_sub_data))
	{
			testFailed(&testRec, "afr32Sub error");
	}
	
	/* Test operation in-place */
	
	afr32Sub (pX, pY, pX, len_l_sub_data);
	
	if (!afr32Equal(pX, pRes, len_l_sub_data))
	{
			testFailed(&testRec, "afr32Sub in-place error");
	}
	
	memFreeIM(pX);
	memFreeIM(pY);
	memFreeIM(pZ);
	memFreeIM(pRes);		
	
	
	/******************/
   /* Test div       */
	/******************/
	testComment (&testRec, "Testing div");
	
	/* Test div_ls in external memory */
	
	pX     = (Frac32 *)memMallocEM (len_div_ls_data * sizeof(div_ls_data[0]));
	pY16   = (Frac16 *)memMallocEM (len_div_ls_data * sizeof(Frac16));
	pZ16   = (Frac16 *)memMallocEM (len_div_ls_data * sizeof(Frac16));
	pRes16 = (Frac16 *)memMallocEM (len_div_ls_data * sizeof(Frac16));
	
	for(i=0;i<len_div_ls_data;i++)
	{
		*(pX+i)     = div_ls_data[i*DIV_LS_SPAN];
		*(pY16+i)   = extract_h(div_ls_data[i*DIV_LS_SPAN + 1]);
		*(pRes16+i) = extract_h(div_ls_data[i*DIV_LS_SPAN + DIV_LS_SPAN-1]);
	}

	afr32Div (pX, pY16, pZ16, len_div_ls_data);
	
	if (!afr16Equal(pZ16, pRes16, len_div_ls_data))
	{
			testFailed(&testRec, "afr32Div error");
	}
	
	/* Test C version */
	
	afr32DivC (pX, pY16, pZ16, len_div_ls_data);
	
	if (!afr16EqualC(pZ16, pRes16, len_div_ls_data))
	{
			testFailed(&testRec, "afr32DivC error");
	}
	
	/* Test operation in-place */
	
	afr32Div (pX, pY16, pY16, len_div_ls_data);
	
	if (!afr16Equal(pY16, pRes16, len_div_ls_data))
	{
			testFailed(&testRec, "afr32Div in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pY16);
	memFreeEM(pZ16);
	memFreeEM(pRes16);		

	/* Test div in internal memory */

	pX     = (Frac32 *)memMallocIM (len_div_ls_data * sizeof(div_ls_data[0]));
	pY16   = (Frac16 *)memMallocIM (len_div_ls_data * sizeof(Frac16));
	pZ16   = (Frac16 *)memMallocIM (len_div_ls_data * sizeof(Frac16));
	pRes16 = (Frac16 *)memMallocIM (len_div_ls_data * sizeof(Frac16));
	
	for(i=0;i<len_div_ls_data;i++)
	{
		*(pX+i)     = div_ls_data[i*DIV_LS_SPAN];
		*(pY16+i)   = extract_h(div_ls_data[i*DIV_LS_SPAN + 1]);
		*(pRes16+i) = extract_h(div_ls_data[i*DIV_LS_SPAN + DIV_LS_SPAN-1]);
	}

	afr32Div (pX, pY16, pZ16, len_div_ls_data);
	
	if (!afr16Equal(pZ16, pRes16, len_div_ls_data))
	{
			testFailed(&testRec, "afr32Div error");
	}
	
	/* Test operation in-place */
	
	afr32Div (pX, pY16, pY16, len_div_ls_data);
	
	if (!afr16Equal(pY16, pRes16, len_div_ls_data))
	{
			testFailed(&testRec, "afr32Div in-place error");
	}
	
	memFreeIM(pX);
	memFreeIM(pY16);
	memFreeIM(pZ16);
	memFreeIM(pRes16);		
	

	/******************/
   /* Test max       */
	/******************/
	testComment (&testRec, "Testing max");

	/* Test max in external memory */
	
	pX   = (Frac32 *)memMallocEM (len_l_min_max_data * sizeof(l_min_max_data[0]));
	
	for(i=0;i<len_l_min_max_data;i++)
	{
		*(pX+i)   = l_min_max_data[i * L_MIN_MAX_SPAN ];
	}

	i = 0;
	x32 = afr32Max (pX, len_l_min_max_data, &i);
	
	if (i!=1 || x32!=0x7fffffff)
	{
			testFailed(&testRec, "afr32Max error");
	}
	
	/* Test C version */
	
	x32 = afr32MaxC (pX, len_l_min_max_data, &i);
	
	if (i!=1 || x32!=0x7fffffff)
	{
			testFailed(&testRec, "afr32MaxC error");
	}
	
	/* Test small arrays */
	
	x32 = afr32Max (pX, 1, &i);
	
	if (i!=0 || x32!=0x0000)
	{
			testFailed(&testRec, "afr32Max error");
	}
	
	x32 = afr32Max (pX, 2, &i);
	
	if (i!=1 || x32!=0x7fffffff)
	{
			testFailed(&testRec, "afr32Max error");
	}
	
	x32 = afr32Max (pX, len_l_min_max_data, NULL);
	
	if (x32!=0x7fffffff)
	{
			testFailed(&testRec, "afr32Max error");
	}
	
	memFreeEM (pX);

	/* Test max in internal memory */
	
	pX   = (Frac32 *)memMallocIM (len_l_min_max_data * sizeof(l_min_max_data[0]));
	
	for(i=0;i<len_l_min_max_data;i++)
	{
		*(pX+i)   = l_min_max_data[i * L_MIN_MAX_SPAN];
	}

	i = 0;
	x32 = afr32Max (pX, len_l_min_max_data, &i);
	
	if (i!=1 || x32!=0x7fffffff)
	{
			testFailed(&testRec, "afr32Max error");
	}
	
	x32 = afr32Max (pX, len_l_min_max_data, NULL);
	
	if (x32!=0x7fffffff)
	{
			testFailed(&testRec, "afr32Max error");
	}
	
	memFreeIM (pX);

	
	/******************/
   /* Test min       */
	/******************/
	testComment (&testRec, "Testing min");

	/* Test min in external memory */
	
	pX   = (Frac32 *)memMallocEM (len_l_min_max_data * sizeof(l_min_max_data[0]));
	
	for(i=0;i<len_l_min_max_data;i++)
	{
		*(pX+i)   = l_min_max_data[i*L_MIN_MAX_SPAN];
	}

	i = 0;
	x32 = afr32Min (pX, len_l_min_max_data, &i);
	
	if (i!=2 || x32!=0x80000000)
	{
			testFailed(&testRec, "afr32Min error");
	}
	
	/* Test C version */
	
	x32 = afr32MinC (pX, len_l_min_max_data, &i);
	
	if (i!=2 || x32!=0x80000000)
	{
			testFailed(&testRec, "afr32MinC error");
	}
	
	/* Test small arrays */
	
	x32 = afr32Min (pX, 1, &i);
	
	if (i!=0 || x32!=0x0000)
	{
			testFailed(&testRec, "afr326Min error");
	}
	
	x32 = afr32Min (pX, 2, &i);
	
	if (i!=0 || x32!=0x0000)
	{
			testFailed(&testRec, "afr32Min error");
	}
	
	x32 = afr32Min (pX, len_l_min_max_data, NULL);
	
	if (x32!=0x80000000)
	{
			testFailed(&testRec, "afr32Min error");
	}
	
	memFreeEM (pX);

	/* Test min in internal memory */
	
	pX   = (Frac32 *)memMallocIM (len_l_min_max_data * sizeof(l_min_max_data[0]));
	
	for(i=0;i<len_l_min_max_data;i++)
	{
		*(pX+i)   = l_min_max_data[i*L_MIN_MAX_SPAN];
	}

	i = 0;
	x32 = afr32Min (pX, len_l_min_max_data, &i);
	
	if (i!=2 || x32!=0x80000000)
	{
			testFailed(&testRec, "afr32Min error");
	}
	
	x32 = afr32Min (pX, len_l_min_max_data, NULL);
	
	if (x32!=0x80000000)
	{
			testFailed(&testRec, "afr32Min error");
	}
	
	memFreeIM (pX);


	/******************/
   /* Test mac       */
	/******************/
	testComment (&testRec, "Testing mac");
	
	/* Test mac in external memory */
	
	pW   = (Frac32 *)memMallocEM (len_l_mac_data * sizeof(l_mac_data[0]));
	pX16 = (Frac16 *)memMallocEM (len_l_mac_data * sizeof(Frac16));
	pY16 = (Frac16 *)memMallocEM (len_l_mac_data * sizeof(Frac16));
	pZ   = (Frac32 *)memMallocEM (len_l_mac_data * sizeof(l_mac_data[0]));
	pRes = (Frac32 *)memMallocEM (len_l_mac_data * sizeof(l_mac_data[0]));
	
	for(i=0;i<len_l_mac_data;i++)
	{
		*(pW+i)   = l_mac_data[i*L_MAC_SPAN];
		*(pX16+i) = extract_h(l_mac_data[i*L_MAC_SPAN + 1]);
		*(pY16+i) = extract_h(l_mac_data[i*L_MAC_SPAN + 2]);
		*(pRes+i) = l_mac_data[i*L_MAC_SPAN + L_MAC_SPAN-1];
	}

	afr32Mac (pW, pX16, pY16, pZ, len_l_mac_data);
	
	if (!afr32Equal(pZ, pRes, len_l_mac_data))
	{
			testFailed(&testRec, "afr32Mac error");
	}
	
#if 0
/* LS 000217 => commented out due to CW bugs which caus afr32MacC to fail */
	/* Test C version */
	
	afr32MacC (pW, pX16, pY16, pZ, len_l_mac_data);
	
	if (!afr32EqualC(pZ, pRes, len_l_mac_data))
	{
			testFailed(&testRec, "afr32MacC error");
	}
#endif

	/* Test operation in-place */
	
	afr32Mac (pW, pX16, pY16, pW, len_l_mac_data);
	
	if (!afr32Equal(pW, pRes, len_l_mac_data))
	{
			testFailed(&testRec, "afr32Mac in-place error");
	}
	
	memFreeEM(pW);
	memFreeEM(pX16);
	memFreeEM(pY16);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test mac in internal memory */
	
	pW   = (Frac32 *)memMallocIM (len_l_mac_data * sizeof(l_mac_data[0]));
	pX16 = (Frac16 *)memMallocIM (len_l_mac_data * sizeof(l_mac_data[0]));
	pY16 = (Frac16 *)memMallocIM (len_l_mac_data * sizeof(l_mac_data[0]));
	pZ   = (Frac32 *)memMallocIM (len_l_mac_data * sizeof(l_mac_data[0]));
	pRes = (Frac32 *)memMallocIM (len_l_mac_data * sizeof(l_mac_data[0]));
	
	for(i=0;i<len_l_mac_data;i++)
	{
		*(pW+i)   = l_mac_data[i*MAC_R_SPAN];
		*(pX16+i)   = extract_h(l_mac_data[i*L_MAC_SPAN + 1]);
		*(pY16+i)   = extract_h(l_mac_data[i*L_MAC_SPAN + 2]);
		*(pRes+i) = l_mac_data[i*L_MAC_SPAN + L_MAC_SPAN-1];
	}

	afr32Mac (pW, pX16, pY16, pZ, len_l_mac_data);
	
	if (!afr32Equal(pZ, pRes, len_l_mac_data))
	{
			testFailed(&testRec, "afr32Mac error");
	}
	
	/* Test operation in-place */
	
	afr32Mac (pW, pX16, pY16, pW, len_l_mac_data);
	
	if (!afr32Equal(pW, pRes, len_l_mac_data))
	{
			testFailed(&testRec, "afr32Mac in-place error");
	}
	
	memFreeIM(pW);
	memFreeIM(pX16);
	memFreeIM(pY16);
	memFreeIM(pZ);
	memFreeIM(pRes);		


	/******************/
   /* Test mac_r     */
	/******************/
	testComment (&testRec, "Testing mac_r");
	
	/* Test mac_r in external memory */
	
	pW   = (Frac32 *)memMallocEM (len_mac_r_data * sizeof(mac_r_data[0]));
	pX16 = (Frac16 *)memMallocEM (len_mac_r_data * sizeof(Frac16));
	pY16 = (Frac16 *)memMallocEM (len_mac_r_data * sizeof(Frac16));
	pZ16 = (Frac16 *)memMallocEM (len_mac_r_data * sizeof(Frac16));
	pRes16 = (Frac16 *)memMallocEM (len_mac_r_data * sizeof(Frac16));
	
	for(i=0;i<len_mac_r_data;i++)
	{
		*(pW+i)   = mac_r_data[i*MAC_R_SPAN];
		*(pX16+i) = extract_h(mac_r_data[i*MAC_R_SPAN + 1]);
		*(pY16+i) = extract_h(mac_r_data[i*MAC_R_SPAN + 2]);
		*(pRes16+i) = extract_h(mac_r_data[i*MAC_R_SPAN + MAC_R_SPAN-1]);
	}

	afr32Mac_r (pW, pX16, pY16, pZ16, len_mac_r_data);
	
	if (!afr16Equal(pZ16, pRes16, len_mac_r_data))
	{
			testFailed(&testRec, "afr32Mac_r error");
	}

#if 0
/* LS 000217 => commented out due to CW bugs which caus afr32Mac_rC to fail */

	/* Test C version */
	
	afr32Mac_rC (pW, pX16, pY16, pZ16, len_mac_r_data);
	
	if (!afr16EqualC(pZ16, pRes16, len_mac_r_data))
	{
			testFailed(&testRec, "afr32Mac_rC error");
	}

#endif

	/* Test operation in-place */
	
	afr32Mac_r (pW, pX16, pY16, pX16, len_mac_r_data);
	
	if (!afr16Equal(pX16, pRes16, len_mac_r_data))
	{
			testFailed(&testRec, "afr16Mac_r in-place error");
	}
	
	memFreeEM(pW);
	memFreeEM(pX16);
	memFreeEM(pY16);
	memFreeEM(pZ16);
	memFreeEM(pRes16);		

	/* Test mac_r in internal memory */
	
	pW   = (Frac32 *)memMallocIM (len_mac_r_data * sizeof(mac_r_data[0]));
	pX16 = (Frac16 *)memMallocIM (len_mac_r_data * sizeof(Frac16));
	pY16 = (Frac16 *)memMallocIM (len_mac_r_data * sizeof(Frac16));
	pZ16 = (Frac16 *)memMallocIM (len_mac_r_data * sizeof(Frac16));
	pRes16 = (Frac16 *)memMallocIM (len_mac_r_data * sizeof(Frac16));
	
	for(i=0;i<len_mac_r_data;i++)
	{
		*(pW+i)   = mac_r_data[i*MAC_R_SPAN];
		*(pX16+i)   = extract_h(mac_r_data[i*MAC_R_SPAN + 1]);
		*(pY16+i)   = extract_h(mac_r_data[i*MAC_R_SPAN + 2]);
		*(pRes16+i) = extract_h(mac_r_data[i*MAC_R_SPAN + MAC_R_SPAN-1]);
	}

	afr32Mac_r (pW, pX16, pY16, pZ16, len_mac_r_data);
	
	if (!afr16Equal(pZ16, pRes16, len_mac_r_data))
	{
			testFailed(&testRec, "afr32Mac_r error");
	}
	
	/* Test operation in-place */
	
	afr32Mac_r (pW, pX16, pY16, pY16, len_mac_r_data);
	
	if (!afr16Equal(pY16, pRes16, len_mac_r_data))
	{
			testFailed(&testRec, "afr32Mac_r in-place error");
	}
	
	memFreeIM(pW);
	memFreeIM(pX16);
	memFreeIM(pY16);
	memFreeIM(pZ16);
	memFreeIM(pRes16);		


	/******************/
   /* Test msu       */
	/******************/
	testComment (&testRec, "Testing msu");
	
	/* Test msu in external memory */
	
	pW   = (Frac32 *)memMallocEM (len_l_msu_data * sizeof(l_msu_data[0]));
	pX16 = (Frac16 *)memMallocEM (len_l_msu_data * sizeof(Frac16));
	pY16 = (Frac16 *)memMallocEM (len_l_msu_data * sizeof(Frac16));
	pZ   = (Frac32 *)memMallocEM (len_l_msu_data * sizeof(l_msu_data[0]));
	pRes = (Frac32 *)memMallocEM (len_l_msu_data * sizeof(l_msu_data[0]));
	
	for(i=0;i<len_l_msu_data;i++)
	{
		*(pW+i)   = l_msu_data[i*L_MSU_SPAN];
		*(pX16+i)   = extract_h(l_msu_data[i*L_MSU_SPAN + 1]);
		*(pY16+i)   = extract_h(l_msu_data[i*L_MSU_SPAN + 2]);
		*(pRes+i) = l_msu_data[i*L_MSU_SPAN + L_MSU_SPAN-1];
	}

	afr32Msu (pW, pX16, pY16, pZ, len_l_msu_data);
	
	if (!afr32Equal(pZ, pRes, len_l_msu_data))
	{
			testFailed(&testRec, "afr32Msu error");
	}

#if 0
/* LS 000217 => commented out due to CW bugs which caus afr32MsuC to fail */
	
	/* Test C version */
	
	afr32MsuC (pW, pX16, pY16, pZ, len_l_msu_data);
	
	if (!afr32EqualC(pZ, pRes, len_l_msu_data))
	{
			testFailed(&testRec, "afr32MsuC error");
	}

#endif
	
	/* Test operation in-place */
	
	afr32Msu (pW, pX16, pY16, pW, len_l_msu_data);
	
	if (!afr32Equal(pW, pRes, len_l_msu_data))
	{
			testFailed(&testRec, "afr32Msu in-place error");
	}
	
	memFreeEM(pW);
	memFreeEM(pX16);
	memFreeEM(pY16);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test msu in internal memory */
	
	pW   = (Frac32 *)memMallocIM (len_l_msu_data * sizeof(l_msu_data[0]));
	pX16 = (Frac16 *)memMallocIM (len_l_msu_data * sizeof(Frac16));
	pY16 = (Frac16 *)memMallocIM (len_l_msu_data * sizeof(Frac16));
	pZ   = (Frac32 *)memMallocIM (len_l_msu_data * sizeof(l_msu_data[0]));
	pRes = (Frac32 *)memMallocIM (len_l_msu_data * sizeof(l_msu_data[0]));
	
	for(i=0;i<len_l_msu_data;i++)
	{
		*(pW+i)   = l_msu_data[i*L_MSU_SPAN];
		*(pX16+i) = extract_h(l_msu_data[i*L_MSU_SPAN + 1]);
		*(pY16+i) = extract_h(l_msu_data[i*L_MSU_SPAN + 2]);
		*(pRes+i) = l_msu_data[i*L_MSU_SPAN + L_MSU_SPAN-1];
	}

	afr32Msu (pW, pX16, pY16, pZ, len_l_msu_data);
	
	if (!afr32Equal(pZ, pRes, len_l_msu_data))
	{
			testFailed(&testRec, "afr32Msu error");
	}
	
	/* Test operation in-place */
	
	afr32Msu (pW, pX16, pY16, pW, len_l_msu_data);
	
	if (!afr32Equal(pW, pRes, len_l_msu_data))
	{
			testFailed(&testRec, "afr32Msu in-place error");
	}
	
	memFreeIM(pW);
	memFreeIM(pX16);
	memFreeIM(pY16);
	memFreeIM(pZ);
	memFreeIM(pRes);		


	/******************/
   /* Test msu_r     */
	/******************/
	testComment (&testRec, "Testing msu_r");
	
	/* Test msu_r in external memory */
	
	pW   = (Frac32 *)memMallocEM (len_msu_r_data * sizeof(msu_r_data[0]));
	pX16 = (Frac16 *)memMallocEM (len_msu_r_data * sizeof(Frac16));
	pY16 = (Frac16 *)memMallocEM (len_msu_r_data * sizeof(Frac16));
	pZ16 = (Frac16 *)memMallocEM (len_msu_r_data * sizeof(Frac16));
	pRes16 = (Frac16 *)memMallocEM (len_msu_r_data * sizeof(Frac16));
	
	for(i=0;i<len_msu_r_data;i++)
	{
		*(pW+i)   = msu_r_data[i*MSU_R_SPAN];
		*(pX16+i)   = extract_h(msu_r_data[i*MSU_R_SPAN + 1]);
		*(pY16+i)   = extract_h(msu_r_data[i*MSU_R_SPAN + 2]);
		*(pRes16+i) = extract_h(msu_r_data[i*MSU_R_SPAN + MSU_R_SPAN-1]);
	}

	afr32Msu_r (pW, pX16, pY16, pZ16, len_msu_r_data);
	
	if (!afr16Equal(pZ16, pRes16, len_msu_r_data))
	{
			testFailed(&testRec, "afr32Msu_r error");
	}

#if 0
/* LS 000217 => commented out due to CW bugs which caus afr32Msu_rC to fail */
	
	/* Test C version */
	
	afr32Msu_rC (pW, pX16, pY16, pZ16, len_msu_r_data);
	
	if (!afr16EqualC(pZ16, pRes16, len_msu_r_data))
	{
			testFailed(&testRec, "afr32Msu_rC error");
	}

#endif
	
	/* Test operation in-place */
	
	afr32Msu_r (pW, pX16, pY16, pX16, len_msu_r_data);
	
	if (!afr16Equal(pX16, pRes16, len_msu_r_data))
	{
			testFailed(&testRec, "afr32Msu_r in-place error");
	}
	
	memFreeEM(pW);
	memFreeEM(pX16);
	memFreeEM(pY16);
	memFreeEM(pZ16);
	memFreeEM(pRes16);		

	/* Test msu_r in internal memory */
	
	pW   = (Frac32 *)memMallocIM (len_msu_r_data * sizeof(msu_r_data[0]));
	pX16 = (Frac16 *)memMallocIM (len_msu_r_data * sizeof(Frac16));
	pY16 = (Frac16 *)memMallocIM (len_msu_r_data * sizeof(Frac16));
	pZ16 = (Frac16 *)memMallocIM (len_msu_r_data * sizeof(Frac16));
	pRes16 = (Frac16 *)memMallocIM (len_msu_r_data * sizeof(Frac16));
	
	for(i=0;i<len_msu_r_data;i++)
	{
		*(pW+i)     = msu_r_data[i*MSU_R_SPAN];
		*(pX16+i)   = extract_h(msu_r_data[i*MSU_R_SPAN + 1]);
		*(pY16+i)   = extract_h(msu_r_data[i*MSU_R_SPAN + 2]);
		*(pRes16+i) = extract_h(msu_r_data[i*MSU_R_SPAN + MSU_R_SPAN-1]);
	}

	afr32Msu_r (pW, pX16, pY16, pZ16, len_msu_r_data);
	
	if (!afr16Equal(pZ16, pRes16, len_msu_r_data))
	{
			testFailed(&testRec, "afr32Msu_r error");
	}
	
	/* Test operation in-place */
	
	afr32Msu_r (pW, pX16, pY16, pY16, len_msu_r_data);
	
	if (!afr16Equal(pY16, pRes16, len_msu_r_data))
	{
			testFailed(&testRec, "afr32Msu_r in-place error");
	}
	
	memFreeIM(pW);
	memFreeIM(pX16);
	memFreeIM(pY16);
	memFreeIM(pZ16);
	memFreeIM(pRes16);		

	
	/******************/
   /* Test mult      */
	/******************/
	testComment (&testRec, "Testing mult");

	/* Test mult in external memory */
	
	pX16 = (Frac16 *)memMallocEM (len_l_mult_data * sizeof(Frac16));
	pY16 = (Frac16 *)memMallocEM (len_l_mult_data * sizeof(Frac16));
	pZ   = (Frac32 *)memMallocEM (len_l_mult_data * sizeof(l_mult_data[0]));
	pRes = (Frac32 *)memMallocEM (len_l_mult_data * sizeof(l_mult_data[0]));
	
	for(i=0;i<len_l_mult_data;i++)
	{
		*(pX16+i)   = extract_h(l_mult_data[i*L_MULT_SPAN]);
		*(pY16+i)   = extract_h(l_mult_data[i*L_MULT_SPAN + 1]);
		*(pRes+i) = l_mult_data[i*L_MULT_SPAN + L_MULT_SPAN-1];
	}

	afr32Mult (pX16, pY16, pZ, len_l_mult_data);
	
	if (!afr32Equal(pZ, pRes, len_l_mult_data))
	{
			testFailed(&testRec, "afr32Mult error");
	}

	/* Test C version */
	
	afr32MultC (pX16, pY16, pZ, len_l_mult_data);
	
	if (!afr32EqualC(pZ, pRes, len_l_mult_data))
	{
			testFailed(&testRec, "afr32MultC error");
	}
		
	memFreeEM(pX16);
	memFreeEM(pY16);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test mult in internal memory */
	
	pX16 = (Frac16 *)memMallocIM (len_l_mult_data * sizeof(Frac16));
	pY16 = (Frac16 *)memMallocIM (len_l_mult_data * sizeof(Frac16));
	pZ   = (Frac32 *)memMallocIM (len_l_mult_data * sizeof(l_mult_data[0]));
	pRes = (Frac32 *)memMallocIM (len_l_mult_data * sizeof(l_mult_data[0]));
	
	for(i=0;i<len_l_mult_data;i++)
	{
		*(pX16+i)   = extract_h(l_mult_data[i*L_MULT_SPAN]);
		*(pY16+i)   = extract_h(l_mult_data[i*L_MULT_SPAN + 1]);
		*(pRes+i) = l_mult_data[i*L_MULT_SPAN + L_MULT_SPAN-1];
	}

	afr32Mult (pX16, pY16, pZ, len_l_mult_data);
	
	if (!afr32Equal(pZ, pRes, len_l_mult_data))
	{
			testFailed(&testRec, "afr32Mult error");
	}
	
	memFreeIM(pX16);
	memFreeIM(pY16);
	memFreeIM(pZ);
	memFreeIM(pRes);		


	/******************/
   /* Test mult_ls   */
	/******************/
	testComment (&testRec, "Testing mult_ls");

	/* Test mult in external memory */
	
	pX   = (Frac32 *)memMallocEM (len_l_mult_ls_data * sizeof(l_mult_ls_data[0]));
	pY16 = (Frac16 *)memMallocEM (len_l_mult_ls_data * sizeof(Frac16));
	pZ   = (Frac32 *)memMallocEM (len_l_mult_ls_data * sizeof(l_mult_ls_data[0]));
	pRes = (Frac32 *)memMallocEM (len_l_mult_ls_data * sizeof(l_mult_ls_data[0]));
	
	for(i=0;i<len_l_mult_data;i++)
	{
		*(pX+i)   = l_mult_ls_data[i*L_MULT_LS_SPAN];
		*(pY16+i) = extract_h(l_mult_ls_data[i*L_MULT_LS_SPAN + 1]);
		*(pRes+i) = l_mult_ls_data[i*L_MULT_LS_SPAN + L_MULT_LS_SPAN-1];
	}

	afr32Mult_ls (pX, pY16, pZ, len_l_mult_ls_data);
	
	if (!afr32Equal(pZ, pRes, len_l_mult_ls_data))
	{
			testFailed(&testRec, "afr32Mult_ls error");
	}
	
	/* Test C version */
	
	afr32Mult_lsC (pX, pY16, pZ, len_l_mult_ls_data);
	
	if (!afr32EqualC(pZ, pRes, len_l_mult_ls_data))
	{
			testFailed(&testRec, "afr32Mult_lsC error");
	}
	
	
	/* Test operation in-place */
	
	afr32Mult_ls (pX, pY16, pX, len_l_mult_ls_data);
	
	if (!afr32Equal(pX, pRes, len_l_mult_ls_data))
	{
			testFailed(&testRec, "afr32Mult_ls in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pY16);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test mult in internal memory */
	
	pX   = (Frac32 *)memMallocIM (len_l_mult_ls_data * sizeof(l_mult_ls_data[0]));
	pY16 = (Frac16 *)memMallocIM (len_l_mult_ls_data * sizeof(Frac16));
	pZ   = (Frac32 *)memMallocIM (len_l_mult_ls_data * sizeof(l_mult_ls_data[0]));
	pRes = (Frac32 *)memMallocIM (len_l_mult_ls_data * sizeof(l_mult_ls_data[0]));
	
	for(i=0;i<len_l_mult_data;i++)
	{
		*(pX+i)   = l_mult_ls_data[i*L_MULT_LS_SPAN];
		*(pY16+i) = extract_h(l_mult_ls_data[i*L_MULT_LS_SPAN + 1]);
		*(pRes+i) = l_mult_ls_data[i*L_MULT_LS_SPAN + L_MULT_LS_SPAN-1];
	}

	afr32Mult_ls (pX, pY16, pZ, len_l_mult_ls_data);
	
	if (!afr32Equal(pZ, pRes, len_l_mult_ls_data))
	{
			testFailed(&testRec, "afr32Mult_ls error");
	}
	
	/* Test operation in-place */
	
	afr32Mult_ls (pX, pY16, pX, len_l_mult_ls_data);
	
	if (!afr32Equal(pX, pRes, len_l_mult_ls_data))
	{
			testFailed(&testRec, "afr32Mult_ls in-place error");
	}
	
	memFreeIM(pX);
	memFreeIM(pY16);
	memFreeIM(pZ);
	memFreeIM(pRes);		


	/******************/
   /* Test negate    */
	/******************/
	testComment (&testRec, "Testing negate");

	/* Test negate in external memory */
	
	pX   = (Frac32 *)memMallocEM (len_l_negate_data * sizeof(l_negate_data[0]));
	pZ   = (Frac32 *)memMallocEM (len_l_negate_data * sizeof(l_negate_data[0]));
	pRes = (Frac32 *)memMallocEM (len_l_negate_data * sizeof(l_negate_data[0]));
	
	for(i=0;i<len_l_negate_data;i++)
	{
		*(pX+i)   = l_negate_data[i*L_NEGATE_SPAN];
		*(pRes+i) = l_negate_data[i*L_NEGATE_SPAN + L_NEGATE_SPAN-1];
	}

	afr32Negate (pX, pZ, len_l_negate_data);
	
	if (!afr32Equal(pZ, pRes, len_l_negate_data))
	{
			testFailed(&testRec, "afr32Negate error");
	}
	
	/* Test C version */
	
	afr32NegateC (pX, pZ, len_l_negate_data);
	
	if (!afr32EqualC(pZ, pRes, len_l_negate_data))
	{
			testFailed(&testRec, "afr32NegateC error");
	}
	
	/* Test operation in-place */
	
	afr32Negate (pX, pX, len_l_negate_data);
	
	if (!afr32Equal(pX, pRes, len_l_negate_data))
	{
			testFailed(&testRec, "afr32Negate in-place error");
	}
	
	memFreeEM(pX);
	memFreeEM(pZ);
	memFreeEM(pRes);		

	/* Test negate in internal memory */
	
	pX   = (Frac32 *)memMallocIM (len_l_negate_data * sizeof(l_negate_data[0]));
	pZ   = (Frac32 *)memMallocIM (len_l_negate_data * sizeof(l_negate_data[0]));
	pRes = (Frac32 *)memMallocIM (len_l_negate_data * sizeof(l_negate_data[0]));
	
	for(i=0;i<len_l_negate_data;i++)
	{
		*(pX+i)   = l_negate_data[i*L_NEGATE_SPAN];
		*(pRes+i) = l_negate_data[i*L_NEGATE_SPAN + L_NEGATE_SPAN-1];
	}

	afr32Negate (pX, pZ, len_l_negate_data);
	
	if (!afr32Equal(pZ, pRes, len_l_negate_data))
	{
			testFailed(&testRec, "afr32Negate error");
	}
	
	/* Test operation in-place */
	
	afr32Negate (pX, pX, len_l_negate_data);
	
	if (!afr32Equal(pX, pRes, len_l_negate_data))
	{
			testFailed(&testRec, "afr32Negate in-place error");
	}
	
	memFreeIM(pX);
	memFreeIM(pZ);
	memFreeIM(pRes);		

	/******************/
   /* Test round     */
	/******************/
	testComment (&testRec, "Testing round");
	
	/* Test rand in external memory */

	pX     = (Frac32 *)memMallocEM (len_round_data * sizeof(round_data[0]));
	pZ16   = (Frac16 *)memMallocEM (len_round_data * sizeof(Frac16));
	pRes16 = (Frac16 *)memMallocEM (len_round_data * sizeof(Frac16));
	
	for(i=0;i<len_round_data;i++)
	{
		*(pX+i)     = round_data[i*ROUND_SPAN + ROUND_SPAN-1];
		*(pRes16+i) = extract_h(round_data[i*ROUND_SPAN + ROUND_SPAN-1]);
	}

	afr32Round (pX, pZ16, len_round_data);
	
	if (!afr16Equal(pZ16, pRes16, len_round_data))
	{
			testFailed(&testRec, "afr32Round error");
	}


#if 0
/* LS 000217 => commented out due to CW bugs which causes afr32Sqrt to fail */
	
	/* Test C version */
	
	afr32RoundC (pX, pZ16, len_round_data);
	
	if (!afr32EqualC(pZ16, pRes16, len_round_data))
	{
			testFailed(&testRec, "afr32RoundC error");
	}

#endif
	
	memFreeEM(pX);
	memFreeEM(pZ16);
	memFreeEM(pRes16);		

	/* Test round in internal memory */

	pX     = (Frac32 *)memMallocIM (len_round_data * sizeof(round_data[0]));
	pZ16   = (Frac16 *)memMallocIM (len_round_data * sizeof(Frac16));
	pRes16 = (Frac16 *)memMallocIM (len_round_data * sizeof(Frac16));
	
	for(i=0;i<len_round_data;i++)
	{
		*(pX+i)     = round_data[i*ROUND_SPAN + ROUND_SPAN-1];
		*(pRes16+i) = extract_h(round_data[i*ROUND_SPAN + ROUND_SPAN-1]);
	}
	
	afr32Round (pX, pZ16, len_round_data);

	if (!afr16Equal(pZ16, pRes16, len_round_data))
	{
			testFailed(&testRec, "afr16Round error");
	}
		
	memFreeIM(pX);
	memFreeIM(pZ16);
	memFreeIM(pRes16);		

	
	/******************/
   /* Test sqrt      */
	/******************/
	testComment (&testRec, "Testing sqrt");

	/* Test sqrt in external memory */
	
	pX     = (Frac32 *)memMallocEM (len_l_sqrt_data * sizeof(l_sqrt_data[0]));
	pZ16   = (Frac16 *)memMallocEM (len_l_sqrt_data * sizeof(Frac16));
	pRes16 = (Frac16 *)memMallocEM (len_l_sqrt_data * sizeof(Frac16));
	
	for(i=0;i<len_l_sqrt_data;i++)
	{
		*(pX+i)     = l_sqrt_data[i*L_SQRT_SPAN];
		*(pRes16+i) = extract_h(l_sqrt_data[i*L_SQRT_SPAN + L_SQRT_SPAN-1]);
	}

	afr32Sqrt (pX, pZ16, len_l_sqrt_data);
	
	if (!afr16Equal(pZ16, pRes16, len_l_sqrt_data))
	{
			testFailed(&testRec, "afr32Sqrt error");
	}

#if 0
/* LS 000217 => commented out due to CW bugs which causes afr32Sqrt to fail */
	
	/* Test C version */
	
	afr32SqrtC (pX, pZ16, len_l_sqrt_data);
	
	if (!afr16EqualC(pZ16, pRes16, len_l_sqrt_data))
	{
			testFailed(&testRec, "afr16SqrtC error");
	}
	
#endif

	memFreeEM(pX);
	memFreeEM(pZ16);
	memFreeEM(pRes16);		

	/* Test sqrt in internal memory */
	
	pX     = (Frac32 *)memMallocIM (len_l_sqrt_data * sizeof(l_sqrt_data[0]));
	pZ16   = (Frac16 *)memMallocIM (len_l_sqrt_data * sizeof(Frac16));
	pRes16 = (Frac16 *)memMallocIM (len_l_sqrt_data * sizeof(Frac16));
	
	for(i=0;i<len_l_sqrt_data;i++)
	{
		*(pX+i)     = l_sqrt_data[i*L_SQRT_SPAN];
		*(pRes16+i) = extract_h(l_sqrt_data[i*L_SQRT_SPAN + L_SQRT_SPAN-1]);
	}

	afr32Sqrt (pX, pZ16, len_l_sqrt_data);
	
	if (!afr16Equal(pZ16, pRes16, len_l_sqrt_data))
	{
			testFailed(&testRec, "afr32Sqrt error");
	}
	
	memFreeIM(pX);
	memFreeIM(pZ16);
	memFreeIM(pRes16);		

			
	testEnd(&testRec);

   return PASS;
}





