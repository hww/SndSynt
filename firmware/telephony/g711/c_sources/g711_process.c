/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: g711_process.c
*
* Description: This module is an API for G711 A-law / U-law 
*              encode / decode 
*
* Modules Included:
*                   search ()
*                   g711_linear2alaw ()
*                   g711_alaw2linear ()
*                   g711_linear2ulaw ()
*                   g711_ulaw2linear ()
*                   g711_alaw2ulaw ()
*                   g711_ulaw2alawv ()                  
*
* Author : Sandeep Sehgal
*
* Date   : 28 July 2000
*
*****************************************************************************/

#include "g711.h"

#define	SIGN_BIT	(0x80)		/* Sign bit for a A-law byte. */
#define	QUANT_MASK	(0xf)		/* Quantization field mask. */
#define	NSEGS		(8)		    /* Number of A-law segments. */
#define	SEG_SHIFT	(4)		    /* Left shift for segment number. */
#define	SEG_MASK	(0x70)		/* Segment field mask. */
#define	BIAS		(0x84)		/* Bias for linear code. */

Int16 search(	Int16	val, Int16 *table, Int16 size);	

static short seg_end[8] = {0xFF, 0x1FF, 0x3FF, 0x7FF,
			    0xFFF, 0x1FFF, 0x3FFF, 0x7FFF};

/* copy from CCITT G.711 specifications */
	/* u- to A-law conversions */
static unsigned char _u2a[128] = {
	1,	1,	2,	2,	3,	3,	4,	4,
	5,	5,	6,	6,	7,	7,	8,	8,
	9,	10,	11,	12,	13,	14,	15,	16,
	17,	18,	19,	20,	21,	22,	23,	24,
	25,	27,	29,	31,	33,	34,	35,	36,
	37,	38,	39,	40,	41,	42,	43,	44,
	46,	48,	49,	50,	51,	52,	53,	54,
	55,	56,	57,	58,	59,	60,	61,	62,
	64,	65,	66,	67,	68,	69,	70,	71,
	72,	73,	74,	75,	76,	77,	78,	79,
	81,	82,	83,	84,	85,	86,	87,	88,
	89,	90,	91,	92,	93,	94,	95,	96,
	97,	98,	99,	100,101,102,103,104,
	105,106,107,108,109,110,111,112,
	113,114,115,116,117,118,119,120,
	121,122,123,124,125,126,127,128};

			/* A- to u-law conversions */
static unsigned char _a2u[128] = {
	1,	3,	5,	7,	9,	11,	13,	15,
	16,	17,	18,	19,	20,	21,	22,	23,
	24,	25,	26,	27,	28,	29,	30,	31,
	32,	32,	33,	33,	34,	34,	35,	35,
	36,	37,	38,	39,	40,	41,	42,	43,
	44,	45,	46,	47,	48,	48,	49,	49,
	50,	51,	52,	53,	54,	55,	56,	57,
	58,	59,	60,	61,	62,	63,	64,	64,
	65,	66,	67,	68,	69,	70,	71,	72,
	73,	74,	75,	76,	77,	78,	79,	79,
	80,	81,	82,	83,	84,	85,	86,	87,
	88,	89,	90,	91,	92,	93,	94,	95,
	96,	97,	98,	99,	100,101,102,103,
	104,105,106,107,108,109,110,111,
	112,113,114,115,116,117,118,119,
	120,121,122,123,124,125,126,127};

Int16 search( Int16	val, Int16 *table, Int16 size)
{
	Int16 i;
	
	for (i = 0; i < size; i++)
	{
		if (val <= *table++)
			return (i);
	}

	return (size);

}


/*****************************************************************************
*
* Module: g711_linear2alaw ()
*
* Description: accepts an 16-bit integer and encodes it as A-law data. 
*
*	Linear Input Code	        Compressed Code
*	------------------------	---------------
*	0000000wxyza			    000wxyz
*	0000001wxyza			    001wxyz
*	000001wxyzab			    010wxyz
*	00001wxyzabc			    011wxyz
*	0001wxyzabcd			    100wxyz
*	001wxyzabcde			    101wxyz
*	01wxyzabcdef			    110wxyz
*	1wxyzabcdefg			    111wxyz
*
* Returns: PASS or FAIL
*
* Arguments:   pPCM_values -> Pointer to a Input Buffer containing 16-bit 
*                             linear samples
*              pA_values -> Ouput Buffer pointer
*              NumSamples - Size of the Input Buffer
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through test_g711.mcp and demo_g711.mcp
*
***************************** Change History ********************************
*
*    DD/MM/YYYY     Code Ver     Description              Author
*    ----------     --------     -----------              ------
*    28/07/2000     0.0.1        Function created         Sandeep Sehgal
*    05/08/2000     1.0.0        Modified per review      Sandeep Sehgal
*                                comments and baselined
*
****************************************************************************/

Result g711_linear2alaw( Int16 *pPCM_values, unsigned char *pA_values, 
                         UInt16 NumSamples)	
                         /* 2's complement (16-bit range) */
{
	Int16 mask;
	Int16 seg, samples;
	unsigned char aval;

    for (samples = 0; samples < NumSamples; samples++)
    {
        if (pPCM_values[samples] > 0) 
        {
	        mask = 0xD5;		/* sign (7th) bit = 1 */
	        pA_values[samples] = pPCM_values[samples];
        }
        else
        {
	        mask = 0x55;		/* sign bit = 0 */
	        pA_values[samples] = (-pPCM_values[samples]);
	        if (pA_values[samples] == 0x8000)
	        {
	            pA_values[samples] = 0x7fff;
	        }    
        }

        /* Convert the scaled magnitude to segment number. */
        seg = search(pA_values[samples], (Int16 *)seg_end, (Int16)8);

        /* Combine the sign, segment, and quantization bits. */
        if (seg >= 8)		/* out of range, return maximum value. */
	    {
	        pA_values[samples] = (0x7F ^ mask);
	    }
        else
        {
	        aval = seg << SEG_SHIFT;
	        if (seg < 2)
		        aval |= (pA_values[samples] >> 4) & QUANT_MASK;
	        else
		        aval |= (pA_values[samples] >> (seg + 3)) & QUANT_MASK;
	        pA_values[samples] = (aval ^ mask);
        }
    }
	    
    return (PASS);   
	
}


/*****************************************************************************
*
* Module: g711_alaw2linear ()
*
* Description: Convert an A-law value to 16-bit linear PCM 
*
* Returns: PASS or FAIL
*
* Arguments:   pA_values -> Pointer to a Input Buffer containing 8-bit 
*                           A-law samples
*              pPCM_values -> Ouput Buffer pointer
*              NumSamples  - Size of the Input Buffer
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through test_g711.mcp and demo_g711.mcp
*
***************************** Change History ********************************
*
*    DD/MM/YYYY     Code Ver     Description              Author
*    ----------     --------     -----------              ------
*    28/07/2000     0.0.1        Function created         Sandeep Sehgal
*    05/08/2000     1.0.0        Modified per review      Sandeep Sehgal
*                                comments and baselined
*
****************************************************************************/

Result g711_alaw2linear( unsigned char *pA_values, Int16 *pPCM_values, 
                         UInt16 NumSamples)
{
	Int16 t;
	Int16 seg, samples;
	unsigned char aval;

   	for (samples = 0; samples < NumSamples; samples++)
    {
        aval = pA_values[samples] ^ 0x55;

        t = ( aval & QUANT_MASK) << 4;
        seg = ((unsigned) aval & SEG_MASK) >> SEG_SHIFT;

        switch (seg) 
        {
            case 0:
	            t += 8;
	            break;
            case 1:
	            t += 0x108;
	            break;
            default:
	            t += 0x108;
	            t <<= seg - 1;
        }

        pPCM_values[samples] = (( aval & SIGN_BIT) ? t : -t);
    }

    return (PASS);   

}


/*****************************************************************************
*
* Module: g711_linear2ulaw ()
*
* Description: Convert a linear PCM value to u-law
*
* In order to simplify the encoding process, the original linear magnitude
* is biased by adding 33 which shifts the encoding range from (0 - 8158) to
* (33 - 8191). The result can be seen in the following encoding table:
*
*	Biased Linear Input Code	Compressed Code
*	------------------------	---------------
*	00000001wxyza			    000wxyz
*	0000001wxyzab			    001wxyz
*	000001wxyzabc			    010wxyz
*	00001wxyzabcd			    011wxyz
*	0001wxyzabcde			    100wxyz
*	001wxyzabcdef			    101wxyz
*	01wxyzabcdefg			    110wxyz
*	1wxyzabcdefgh			    111wxyz
*
* Each biased linear code has a leading 1 which identifies the segment
* number. The value of the segment number is equal to 7 minus the number
* of leading 0's. The quantization interval is directly available as the
* four bits wxyz.  * The trailing bits (a - h) are ignored.
*
* Ordinarily the complement of the resulting code word is used for
* transmission, and so the code word is complemented before it is returned.
*
* Returns: PASS or FAIL
*
* Arguments:   pPCM_values -> Pointer to a Input Buffer containing 16-bit 
*                             linear samples
*              pU_values -> Ouput Buffer pointer
*              NumSamples - Size of the Input Buffer
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through test_g711.mcp and demo_g711.mcp
*
***************************** Change History ********************************
*
*    DD/MM/YYYY     Code Ver     Description              Author
*    ----------     --------     -----------              ------
*    28/07/2000     0.0.1        Function created         Sandeep Sehgal
*    05/08/2000     1.0.0        Modified per review      Sandeep Sehgal
*                                comments and baselined
*
****************************************************************************/

Result g711_linear2ulaw( Int16 *pPCM_values, unsigned char *pU_values,
                         UInt16 NumSamples)	
                         /* 2's complement (16-bit range) */
{
	Int16 mask;
	Int16 seg , samples;
	unsigned char uval;

	for (samples = 0; samples < NumSamples; samples++)
	{

	    /* Get the sign and the magnitude of the value. */
	    if (pPCM_values[samples] < 0) 
	    {
		    pU_values[samples] = BIAS - pPCM_values[samples];
		    mask = 0x7F;
	    } 
	    else 
	    {
		    pU_values[samples] = pPCM_values[samples] + BIAS;
		    mask = 0xFF;
	    }

        /* If the value overflows, saturate it to positive max */
        if ((signed char) pU_values[samples] < 0)
        {
           pU_values[samples] = 0x7fff;
        }   

	    /* Convert the scaled magnitude to segment number. */
	    seg = search(pU_values[samples], (Int16 *)seg_end, (Int16)8);

	/*
	 * Combine the sign, segment, quantization bits;
	 * and complement the code word.
	 */

	    if (seg >= 8)		/* out of range, return maximum value. */
		    pU_values[samples] = (0x7F ^ mask);
	    else 
	    {
		    uval = (seg << 4) | ((pU_values[samples] >> (seg + 3)) & 0xF);
		    pU_values[samples] = (uval ^ mask);
	    }
    }

    return (PASS);

}


/*****************************************************************************
*
* Module: g711_ulaw2linear ()
*
* Description: Convert an U-law value to 16-bit linear PCM 
*              First, a biased linear code is derived from the code word. An
*              unbiased output can then be obtained by subtracting 33 from the
*              biased code.
*
*             Note : This function expects to be passed the complement of the
*                    original code word. This is in keeping with ISDN
*                    conventions.
*
* Returns: PASS or FAIL
*
* Arguments:   pU_values -> Pointer to a Input Buffer containing 8-bit 
*                           U-law samples
*              pPCM_values -> Ouput Buffer pointer
*              NumSamples  - Size of the Input Buffer
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through test_g711.mcp and demo_g711.mcp
*
***************************** Change History ********************************
*
*    DD/MM/YYYY     Code Ver     Description              Author
*    ----------     --------     -----------              ------
*    28/07/2000     0.0.1        Function created         Sandeep Sehgal
*    05/08/2000     1.0.0        Modified per review      Sandeep Sehgal
*                                comments and baselined
*
****************************************************************************/

Result g711_ulaw2linear( unsigned char *pU_values, Int16 *pPCM_values, 
                         UInt16 NumSamples)
{
	Int16 t, samples;
	unsigned char uval;

    for (samples = 0; samples < NumSamples; samples++)
    {
	    /* Complement to obtain normal u-law value. */
	    uval = ~pU_values[samples];
	    
	    /*
	     * Extract and bias the quantization bits. Then
	     * shift up by the segment number and subtract out the bias.
	     */
	     
	    t = ((uval & QUANT_MASK) << 3) + BIAS;
	    t <<= ((unsigned) uval & SEG_MASK) >> SEG_SHIFT;

	    pPCM_values[samples] = ((uval & SIGN_BIT) ? (BIAS - t) : (t - BIAS));
	} 

	return (PASS);   

}


/*****************************************************************************
*
* Module: g711_alaw2ulaw ()
*
* Description: Convert a A-law value to U-law value
*
* Returns: PASS or FAIL
*
* Arguments:   pAval -> Pointer to a input buffer containing 8-bit 
*                       A-law samples
*              pUval -> Pointer to a output buffer to contain 8-bit
*                       U-law samples
*              NumSamples - Size of the Input Buffer
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through test_g711.mcp and demo_g711.mcp
*
***************************** Change History ********************************
*
*    DD/MM/YYYY     Code Ver     Description              Author
*    ----------     --------     -----------              ------
*    28/07/2000     0.0.1        Function created         Sandeep Sehgal
*    05/08/2000     1.0.0        Modified per review      Sandeep Sehgal
*                                comments and baselined
*
****************************************************************************/

Result g711_alaw2ulaw( unsigned char *pAval, unsigned char *pUval,
                       UInt16 NumSamples)
{
	Int16 samples;

	for (samples = 0; samples < NumSamples; samples++)
	{
	
	    pUval[samples] = pAval[samples] & 0xff;
	    pUval[samples] = ((pUval[samples] & 0x80) ? (0xFF ^ _a2u[pUval[samples] ^ 0xD5]) :
	                        (0x7F ^ _a2u[pUval[samples] ^ 0x55]));
    }

    return (PASS);	                        
}


/*****************************************************************************
*
* Module: g711_ulaw2alaw ()
*
* Description: Convert a U-law value to A-law value
*
* Returns: PASS or FAIL
*
* Arguments:   pUval -> Pointer to a input buffer containing 8-bit 
*                       U-law samples
*              pAval -> Pointer to a output buffer to contain 8-bit
*                       A-law samples
*              NumSamples - Size of the Input Buffer
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through test_g711.mcp and demo_g711.mcp
*
***************************** Change History ********************************
*
*    DD/MM/YYYY     Code Ver     Description              Author
*    ----------     --------     -----------              ------
*    28/07/2000     0.0.1        Function created         Sandeep Sehgal
*    05/08/2000     1.0.0        Modified per review      Sandeep Sehgal
*                                comments and baselined
*
****************************************************************************/

Result g711_ulaw2alaw( unsigned char *pUval, unsigned char *pAval, 
                       UInt16 NumSamples)
{
	Int16 samples;

	for (samples = 0; samples < NumSamples; samples++)
	{
    	pAval[samples] = pUval[samples] & 0xff;
	    pAval[samples] = ((pAval[samples] & 0x80) ? (0xD5 ^ (_u2a[0xFF ^ pAval[samples]] - 1)) :
	                        (0x55 ^ (_u2a[0x7F ^ pAval[samples]] - 1)));
    }

    return (PASS);
}