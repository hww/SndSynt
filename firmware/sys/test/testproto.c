#include "port.h"
#include "arch.h"
#include "test.h"
#include "prototype.h"
#include "appconst.h"

/*-----------------------------------------------------------------------*

    testproto.c  -  test Prototype.h file
	
*------------------------------------------------------------------------*/

Result testproto(test_sRec *);

Result testproto(test_sRec *pTestRec)
{
	Frac16 x16, y16, z16;
	Frac32 x32, y32, z32;
	short  i16;

	testStart (pTestRec, ProtoTestStartMsg);

	/**********************/
   /* Test add intrinsic */
	/**********************/

	x16 = 0x2000;
	y16 = 0x2000;

	z16 = add (x16, y16);

	if (z16 != 0x4000) 
	{
		testFailed(pTestRec, ProtoAddFailed);
	}

	/**********************/
   /* Test sub intrinsic */
	/**********************/

	x16 = 0x4000;
	y16 = 0x2000;

	z16 = sub (x16, y16);

	if (z16 != 0x2000) 
	{
		testFailed(pTestRec, ProtoSubFailed);
	}

	/**********************/
   /* Test abs_s intrinsic */
	/**********************/

	x16 = 0xC000;

	z16 = abs_s (x16);

	if (z16 != 0x4000) 
	{
		testFailed(pTestRec, ProtoAbsFailed);
	}
	
	/**********************/
   /* Test shl intrinsic */
	/**********************/

	x16 = 0x0400;

	z16 = shl (x16, 4);

	if (z16 != 0x4000) 
	{
		testFailed(pTestRec, ProtoShlFailed);
	}

	/**********************/
   /* Test shr intrinsic */
	/**********************/

	x16 = 0x4000;

	z16 = shr (x16, 4);

	if (z16 != 0x0400) 
	{
		testFailed(pTestRec, ProtoShrFailed);
	}

	/**********************/
   /* Test mult intrinsic */
	/**********************/

	x16 = 0x2000;
	y16 = 0x2000;

	z16 = mult (x16, y16);

	if (z16 != 0x0800) 
	{
		testFailed(pTestRec, ProtoMultFailed);
	}

	/**********************/
   /* Test mult_r intrinsic */
	/**********************/

	x16 = 0x2006;
	y16 = 0x2000;

	z16 = mult_r (x16, y16);

	if (z16 != 0x0802) 
	{
		testFailed(pTestRec, ProtoMultRFailed);
	}

	/**********************/
   /* Test negate intrinsic */
	/**********************/

	x16 = 0xC000;

	z16 = negate (x16);

	if (z16 != 0x4000) 
	{
		testFailed(pTestRec, ProtoNegateFailed);
	}

	/**********************/
   /* Test extract_h intrinsic */
	/**********************/

	x32 = 0x12345678;

	z16 = extract_h (x32);

	if (z16 != 0x1234) 
	{
		testFailed(pTestRec, ProtoExtractHFailed);
	}

	/**********************/
   /* Test extract_l intrinsic */
	/**********************/

	x32 = 0x12345678;

	z16 = extract_l (x32);

	if (z16 != 0x5678) 
	{
		testFailed(pTestRec, ProtoExtractLFailed);
	}

	/**********************/
   /* Test round intrinsic */
	/**********************/

	x32 = 0x48018888;

	z16 = round (x32);

	if (z16 != 0x4802) 
	{
		testFailed(pTestRec, ProtoRoundFailed);
	}

	/**********************/
   /* Test div_s intrinsic */
	/**********************/

	x16 = 0x2000;
	y16 = 0x4000;

	z16 = div_s (x16, y16);

	if (z16 != 0x4000) 
	{
		testFailed(pTestRec, ProtoDivsFailed);
	}

	/**********************/
   /* Test L_add intrinsic */
	/**********************/

	x32 = 0x2000A000;
	y32 = 0x2000A000;

	z32 = L_add (x32, y32);

	if (z32 != 0x40014000) 
	{
		testFailed(pTestRec, ProtoLAddFailed);
	}

	/**********************/
   /* Test L_sub intrinsic */
	/**********************/

	x32 = 0x40010000;
	y32 = 0x20004000;

	z32 = L_sub (x32, y32);

	if (z32 != 0x2000C000) 
	{
		testFailed(pTestRec, ProtoLSubFailed);
	}

	/**********************/
   /* Test L_abs intrinsic */
	/**********************/

	x32 = 0xC00FF000;

	z32 = L_abs (x32);

	/* if (z32 != 0x400FF000) */
	if (z32 != 0x3FF01000) 
	{
		testFailed(pTestRec, ProtoLabsFailed);
	}

	/**********************/
   /* Test L_shl intrinsic */
	/**********************/

	x32 = 0x0400C001;

	z32 = L_shl (x32, 1);

	if (z32 != 0x08018002) 
	{
		testFailed(pTestRec, ProtoLshlFailed);
	}

	/**********************/
   /* Test L_shr intrinsic */
	/**********************/

	x32 = 0x41111112;

	z32 = L_shr (x32, 1);

	if (z32 != 0x20888889) 
	{
		testFailed(pTestRec, ProtoLshrFailed);
	}

	/**********************/
   /* Test L_mult intrinsic */
	/**********************/

	x16 = 0x2002;
	y16 = 0x2000;

	z32 = L_mult (x16, y16);

	if (z32 != 0x08008000) 
	{
		testFailed(pTestRec, ProtoLmultFailed);
	}

	/**********************/
   /* Test L_mult_ls intrinsic */
	/**********************/

	x32 = 0x20022000;
	y16 = 0x2000;

	z32 = L_mult_ls (x32, y16);

	if (z32 != 0x08008800) 
	{
		testFailed(pTestRec, ProtoLmultlsFailed);
	}

	/**********************/
   /* Test L_negate intrinsic */
	/**********************/

	x32 = 0xC0001234;

	z32 = L_negate (x32);

	/* if (z32 != 0x40001234) */
	if (z32 != 0x3fffedcc) 
	{
		testFailed(pTestRec, ProtoLnegateFailed);
	}

	/**********************/
   /* Test div_ls intrinsic */
	/**********************/

	x32 = 0x20000000;
	y16 = 0x4000;

	z16 = div_ls (x32, y16);

	if (z16 != 0x4000) 
	{
		testFailed(pTestRec, ProtoDivlsFailed);
	}

	/**********************/
   /* Test mac_r intrinsic */
	/**********************/

	x32 = 0x20000000;
	x16 = 0x2006;
	y16 = 0x2000;

	z16 = mac_r (x32, x16, y16);

	if (z16 != 0x2802) 
	{
		testFailed(pTestRec, ProtoMacrFailed);
	}

	/**********************/
   /* Test msu_r intrinsic */
	/**********************/

	x32 = 0x09040000;
	x16 = 0x2006;
	y16 = 0x2000;

	z16 = msu_r (x32, x16, y16);

	if (z16 != 0x0103) 
	{
		testFailed(pTestRec, ProtoMsurFailed);
	}

	/**********************/
   /* Test L_mac intrinsic */
	/**********************/

	x32 = 0x20000000;
	x16 = 0x2006;
	y16 = 0x2000;

	z32 = L_mac (x32, x16, y16);

	if (z32 != 0x28018000) 
	{
		testFailed(pTestRec, ProtoLmacFailed);
	}

	/**********************/
   /* Test L_msu intrinsic */
	/**********************/

	x32 = 0x0904A123;
	x16 = 0x2006;
	y16 = 0x2000;

	z32 = L_msu (x32, x16, y16);

	/* if (z32 != 0x0103800) */
	if (z32 != 0x01032123) 
	{
		testFailed(pTestRec, ProtoLmsuFailed);
	}

	/**********************/
   /* Test L_deposit_h intrinsic */
	/**********************/

	x16 = 0x1234;

	z32 = L_deposit_h (x16);

	if (z32 != 0x12340000) 
	{
		testFailed(pTestRec, ProtoLdeposithFailed);
	}

	/**********************/
   /* Test L_deposit_l intrinsic */
	/**********************/

	x16 = 0x9234;

	z32 = L_deposit_l (x16);

	if (z32 != 0xFFFF9234) 
	{
		testFailed(pTestRec, ProtoLdepositlFailed);
	}

	/**********************/
   /* Test norm_s intrinsic */
	/**********************/

	x16 = 0x0234;

	i16 = norm_s(x16);
	
	if (i16 != 5) 
	{
		testFailed(pTestRec, ProtoNormsFailed);
	}


	/**********************/
   /* Test norm_l intrinsic */
	/**********************/

	x32 = 0x00000234;

	i16 = norm_l(x32);
	
	if (i16 != 21) 
	{
		testFailed(pTestRec, ProtoNormlFailed);
	}

	testEnd (pTestRec);
	
   return PASS;
}





