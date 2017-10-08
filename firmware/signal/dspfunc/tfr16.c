/* File: tfr16.c */
/*--------------------------------------------------------------
*
*        (C) 2000 MOTOROLA INDIA ELECTRONICS LTD.
*-------------------------------------------------------------*/
/*--------------------------------------------------------------
* Revision History:
*
* VERSION    CREATED BY    MODIFIED BY      DATE       COMMENTS  
* -------    ----------    -----------      -----      --------
*   1.0      Meera S. P.        -          17-02-2000   Reviewed.
* 
*-------------------------------------------------------------*/

/*---------------------------------------------------------------
* 16 bit Fractional Trignometric Functions 
*----------------------------------------------------------------*/

#include "port.h"
#include "tfr16.h"
#include "stdio.h"
#include "math.h"
#include "mfr16.h"
#include "prototype.h"
#include "mem.h"

#define SWG_90_DEGREES     8192
#define SWG_180_DEGREES    16384
#define SWG_270_DEGREES    24576
#define SWG_360_DEGREES    32767
#define SWG_SIGN_POSITIVE  1
#define SWG_SIGN_NEGATIVE -1
#define SWG_ONEHALF        16384
#define PI_PLUS            32768
#define PI_MINUS          -32767
#define SWG_NEG_MAX       -32768
#define PI_HALF_PLUS       16384
#define PI_HALF_MINUS     -16384


void   tfr16SineWaveGenIDTLC  (tfr16_tSineWaveGenIDTL   *, Frac16 *, UInt16);
void   tfr16SineWaveGenRDTLC  (tfr16_tSineWaveGenRDTL   *, Frac16 *, UInt16);
void   tfr16SineWaveGenRDITLC (tfr16_tSineWaveGenRDITL  *, Frac16 *, UInt16);
void   tfr16SineWaveGenRDITLQC(tfr16_tSineWaveGenRDITLQ *, Frac16 *, UInt16);
void   tfr16SineWaveGenPAMC   (tfr16_tSineWaveGenPAM    *, Frac16 *, UInt16);
void   tfr16SineWaveGenDOMC   (tfr16_tSineWaveGenDOM    *, Frac16 *, UInt16);
Frac16 tfr16WaveGenRDITLQC    (tfr16_tWaveGenRDITLQ     *, Frac16);
Frac16 tfr16SinPIxLUTC        (tfr16_tSinPIxLUT         *, Frac16);
Frac16 tfr16CosPIxLUTC        (tfr16_tCosPIxLUT         *, Frac16);

/***************************************************************************************
* The Scale Factor is calculated using matlab.                                         *
*                                                                                      *
* ex :                                                                                 *
* For Sine Coefs.                                                                      *
* c = [pi -pi^3/3! pi^5/5! -pi^7/7! pi^9/9! -pi^11/11! pi^13/13! -pi^15/15! pi^17/17!] *
* cmax = max(abs(c))                                                                   *
* m = ceil(log2(cmax))                                                                 *
* SCALE_FACT = 2^m                                                                     *
*                                                                                      *
* SineCoefs(I) = c(I)/8                                                                *
***************************************************************************************/
#define SCALE_FACT      8

const Frac16 SineCoefs[] =  {
                             FRAC16(0.39269908169872),
                             FRAC16(-0.64596409750625),
                             FRAC16(0.31877050498467),
                             FRAC16(-0.07446482317004),
                             FRAC16(0.01026823582639),
                             FRAC16(-0.00092130386821),
                             FRAC16(0.00005828785072)
                            };
const Frac16 AsineCoefs[] = {
                             FRAC16(0.31830988618379),
                             FRAC16(0.05305164769730),
                             FRAC16(0.02387324146378),
                             FRAC16(0.01421026277606),
									  FRAC16(0.00967087327815),
									  FRAC16(0.00712127941391),
									  FRAC16(0.00552355646848),
									  FRAC16(0.00444514782464)
									 };
									 
const Frac16 Inv_Threshold = FRAC16(0.70710678118655);

/*******************************************************
* Trigonometric Functions for 16-bit Fractional
*******************************************************/

/********************************************************************************
* File Name : tfr16.c                                                           *
*                                                                               *
* Function : Frac16 tfr16SinPIx      (Frac16 x)                                 *
*                                                                               *
* Description:                                                                  *
* This routine computes sine(pi*x)                                              *
*                                                                               *
* Inputs :                                                                      *
*          1) x - input data value                                              *
*                                                                               *
* Outputs :                                                                     *
*          1) z - sine(pi*x)                                                    *
*                                                                               *
* Algorithm :                                                                   *
* if(x > 0.5)                                                                   *
*    sin(pi*x) = sin(pi*(1-x))                                                  *
*                                                                               *
*                                                                               *
* z = x(SineCoefs(0)+x^2(SineCoefs(1)+x^2(SineCoefs(2)+x^2(SineCoefs(3)+        *
*     x^2(SineCoefs(4)+x^2(SineCoefs(5)+SineCoefs(6)x^2))))))                   *
********************************************************************************/


Frac16 tfr16SinPIx      (Frac16 x)
{
    Frac16 z, temp16, sign_flag = 0, i;
    Frac32 Acc = 0,temp32;
  
    if(x < 0)
    {
        sign_flag = 1;
        x = negate(x);
    }
   
    if(x > FRAC16(0.5))
    {
       /* sin(pi*x) = sin(pi*(1-x)) */
        x = sub(FRAC16(1),x);
    }
    
    z = mult_r(x,x); /* z = x^2 */

    Acc = L_deposit_h(SineCoefs[5]);
    temp16 = mac_r(Acc,z,SineCoefs[6]); /* temp16 = c5 +c6*x^2 */

    /* temp16 = (c0+z(c1+z(c2+z(c3+z(c4+z(c5+c6z)))))) */
    for(i = 4; i >= 0; i--)
    {
   	  Acc = L_deposit_h(SineCoefs[i]);
   	  temp16 = mac_r(Acc,temp16,z);
    }


    temp32 = L_mult(temp16,x); /* z = x * temp16 */
    /* z = z*8 (as the coefs are scaled down by 8, 
                           the o/p is scaled up by 8) */
                           
    temp32 = L_shl(temp32,(Frac16)3);
    
    z = round(temp32);

    if (sign_flag == 1)
    {
        z = negate(z);
    }
     
	 return z;
}

/********************************************************************************
* File Name : tfr16.c                                                           *
*                                                                               *
* Function : Frac16 tfr16CosPIx      (Frac16 x)                                 *
*                                                                               *
* Description:                                                                  *
* This routine computes cosine(pi*x)                                            *
*                                                                               *
* Inputs :                                                                      *
*          1) x - input data value                                              *
*                                                                               *
* Outputs :                                                                     *
*          1) z - cosine(pi*x)                                                  *
*                                                                               *
* Algorithm :                                                                   *
* if(x > 0.5)                                                                   *
*    cos(pi*x) = -cos(pi*(1-x))                                                 *
*                                                                               *
* cos(pi*x) = sin(pi*(0.5-x))                                                   *
*                                                                               *
********************************************************************************/

Frac16 tfr16CosPIx      (Frac16 x)
{
    Frac16 z, temp16, sign_flag = 0, i,temp1,temp2;
    Frac32 Acc = 0,temp32;

    if(x < 0)
    {
   	  x = negate(x); //cos(x) = cos(-x)
    }
   
    if(x > FRAC16(0.5))
    {
        x = sub(FRAC16(1),x);
        sign_flag = 1;
    }
    
    x = sub(FRAC16(0.5),x);
    if(sign_flag ==1)
        x = add(x,1);               /* To gain the precision */
    z = tfr16SinPIx(x);
    
    if(sign_flag == 1)
    {
        z = negate(z);
    }
   
	 return z;
}
    

/********************************************************************************
* File Name : tfr16.c                                                           *
*                                                                               *
* Function : Frac16 tfr16ASinOverPI     (Frac16 x)                              *
*                                                                               *
* Description:                                                                  *
* This routine computes the Arcsin function of fractional input value x, and    *
* divides that result by pi i.e. Arcsin(x)/pi.                                  *
*                                                                               *
* Inputs :                                                                      *
*          1) x - input data value                                              *
*                                                                               *
* Outputs :                                                                     *
*          1) z - Arcsin(x)/pi                                                  *
*                                                                               *
* Algorithm:                                                                    *
*           if(x >= 0.70710678118655)                                           *
*              z = 0.5 - ASinOverPI(sqrt(1-x^2))                                *
*           else                                                                *
*              z = ASinOverPI(x)                                                *
*                                                                               *
* Where :                                                                       *
* ASinOverPI(x) = x(AsineCoefs(0)+x^2(AsineCoefs(1)+x^2(AsineCoefs(2)+          *
*                 x^2(AsineCoefs(3)+x^2(AsineCoefs(4)+x^2(AsineCoefs(5)+        *
*                 x^2(AsineCoefs(6)+AsineCoefs(7)x^2)))))))                     *
*                                                                               *
********************************************************************************/

Frac16 tfr16AsinOverPI  (Frac16 x)
{
    Frac16   z, temp16, sign_flag = 0, i, thres_flag = 0;
    Frac32   Acc = 0;
   
    if (x < 0)
    {
        sign_flag = 1;
        x = negate(x);
    }
    
	 z = mult_r(x,x);
    if (x > Inv_Threshold)
    {
        thres_flag = 1;
        x = mfr16Sqrt(sub(FRAC16(1),add(z,1)));
        z = mult_r(x,x);
    }
   
	 temp16 = AsineCoefs[7];   
   	 
    for(i = 6; i >= 0; i--)
    {
        Acc = L_deposit_h(AsineCoefs[i]);
   	  temp16 =  mac_r(Acc,temp16,z);
    }

    z = mult_r(temp16,x);
    
    if (thres_flag == 1)
    {
        z = sub(FRAC16(0.5),z);
    }
    
    if (sign_flag == 1)
    {
        z = negate(z);
    }

	 return z;
}   	
      	
/********************************************************************************
* File Name : tfr16.c                                                           *
*                                                                               *
* Function : Frac16 tfr16ACosOverPI     (Frac16 x)                              *
*                                                                               *
* Description:                                                                  *
* This routine computes the Arccos function of fractional input value x, and    *
* divides that result by pi i.e. Arccos(x)/pi.                                  *
*                                                                               *
* Inputs :                                                                      *
*          1) x - input data value                                              *
*                                                                               *
* Outputs :                                                                     *
*          1) z - Arccos(x)/pi                                                  *
*                                                                               *
* Algorithm:                                                                    *
* AtanOverPI(x) = 0.5 - AsinOverPI(x)                                           *
********************************************************************************/

Frac16 tfr16AcosOverPI  (Frac16 x)
{
	 Frac16 z, sign_flag = 0;
   
    if(x < 0)
    {
        sign_flag = 1;
        x = negate(x);
    }
    
    z = tfr16AsinOverPI (x);

    if (sign_flag == 1)
    {
        z = negate(z);
    }
   
    z = sub(FRAC16(0.50000000000),z); /*acos(x) = 0.5 - AsinOverPI(x) */
   
    return z;
}

/********************************************************************************
* File Name : tfr16.c                                                           *
*                                                                               *
* Function : Frac16 tfr16AtanOverPI     (Frac16 x)                              *
*                                                                               *
* Description:                                                                  *
* This routine computes the Arctan function of fractional input value x, and    *
* divides that result by pi i.e. Arctan(x)/pi.                                  *
*                                                                               *
* Inputs :                                                                      *
*          1) x - input data value                                              *
*                                                                               *
* Outputs :                                                                     *
*          1) z - Arctan(x)/pi                                                  *
*                                                                               *
* Algorithm:                                                                    *
* AtanOverPI(x) = 0.5 - AsinOverPI(sqrt(1-x^2)/sqrt(1-x^4))                     *
********************************************************************************/

Frac16 tfr16AtanOverPI  (Frac16 x)
{
    Frac16 z, z1, z2, sign_flag = 0;

   
	 if(x < 0)
    {
        sign_flag = 1;
        x = negate(x);
    }

    if ( x == FRAC16(1))
    {
        z = FRAC16(0.25000000000000);
    }
    else
    {
        z1 = mult_r(x,x);   /* z1 = x^2 */
 	  if (z1 > 0)
  	      z1 = add(z1,1); /* To compensate the precision lost while calculating square */

        z2 = mult_r(z1,z1);   /* z2 = x^4 */
        if (z2 > 0)
    	      z2 = add(z2,1); /* To compensate the precision lost while calculating square */

    
        z1 = mfr16Sqrt(sub(FRAC16(1),z1));  /* z1 = sqrt(1-x^2) */
        z2 = mfr16Sqrt(sub(FRAC16(1),z2));  /* z2 = sqrt(1-x^4) */
        x = div_s(z1,z2);                /* x = (sqrt(1-x^2)/sqrt(1-x^4)) */
        
        /* AtanOverPI(x) = 0.5 - AsinOverPI(sqrt(1-x^2)/sqrt(1-x^4)) */    
        z = sub(FRAC16(0.5),tfr16AsinOverPI(x)); 
    }

 	 if (sign_flag == 1)
    {
        z = negate(z);
    }
	 return z;
}

/********************************************************************************
* File Name : tfr16.c                                                           *
*                                                                               *
* Function : Frac16 tfr16Atan2OverPI (Frac16 y,Frac16 x)                        *
*                                                                               *
* Description:                                                                  *
* This routine computes the Arctan(y/x), and divides that result by pi i.e.     *
* Arctan(y/x)/pi.                                                               *
*                                                                               *
* Inputs :                                                                      *
*          1) y - first input data value                                        *
*          2) x - second input data value                                       *
*                                                                               *
* Outputs :                                                                     *
*          1) z - Arctan(y/x)/pi                                                *
*                                                                               *
* Algorithm :                                                                   *
*          if(y/x < 1)                                                          *
*             z = AtanOverPI(y/x);                                              *
*          else                                                                 *
*             z = (0.5 - AtanOverPI(x/y))                                       *
*********************************************************************************/

Frac16 tfr16Atan2OverPI (Frac16 y, Frac16 x)
{  
    Frac16 temp16, div_flag = 0, z, sign_flag = 0;
    Frac16 ax, ay;  /* for CW bug workaround */

    if(y == 0 && x == 0)
    {	
   	  temp16 = 0;          /* temp = y/x */
    }
    else
    {
        ax = abs_s(x);
        ay = abs_s(y);    
        if (ax >= ay)
        {
            temp16 = div_s(y,x);
        }
        else
        {
 	         temp16 = div_s(x,y);        /* temp = x/y i.e. 1/(y/x)   */
            div_flag = 1; 
        }
    }
   
    if (temp16 < 0)
  	 {
 		  temp16 = negate(temp16);
  		  sign_flag = 1;
  	 }
   
       
    z = tfr16AtanOverPI(temp16);
   
    if (div_flag == 1)               /* atan(x)/pi = (0.5-(atan(1/x))/pi) */
    {
        z = sub(FRAC16(0.5),z);
    }
      
    if (sign_flag ==1)
    {
   	  z = negate(z);
    }
      
	 return z;
}


typedef struct{
	Frac16 PreviousAlpha;
	Frac16 Delta;
	Frac16 NextAlpha;
	Frac16 Amplitude;
}sSineGenPAM;

/*******************************************************************************/
tfr16_tSineWaveGenPAM * tfr16SineWaveGenPAMCreate(UInt16   SineFreq,
												  UInt16   SampleFreq,
												  Frac16   InitialPhasePIx,
												  Frac16   Amplitude)
{
	tfr16_tSineWaveGenPAM * pPrivateData = memMallocEM(sizeof(tfr16_tSineWaveGenPAM));
	
	tfr16SineWaveGenPAMInit(pPrivateData, SineFreq, SampleFreq, InitialPhasePIx, Amplitude); 
	
	return(pPrivateData);
}

/*******************************************************************************/
void tfr16SineWaveGenPAMDestroy(tfr16_tSineWaveGenPAM * pSWG)
{
	if (pSWG != NULL) 
	{
		memFreeEM(pSWG);
	} 	
}

/*******************************************************************************/
void tfr16SineWaveGenPAMInit(tfr16_tSineWaveGenPAM * pSWG,
									  UInt16                  SineFreq,
									  UInt16                  SampleFreq,
									  Frac16                  InitialPhasePIx,
									  Frac16                  Amplitude)
{
	sSineGenPAM * pState = (sSineGenPAM *) pSWG;

	pState -> PreviousAlpha = InitialPhasePIx;
	pState -> Delta         = div_s((Frac16)(2 * SineFreq),(Frac16)SampleFreq);
	pState -> Amplitude     = Amplitude;
}

/*******************************************************************************/
void tfr16SineWaveGenPAMC(tfr16_tSineWaveGenPAM * pSWG, Frac16 * pValues, UInt16 Nsamples)
{
	sSineGenPAM * pState = (sSineGenPAM *) pSWG;
	Frac16 NextAlpha;
	UInt16 I;

	for(I = 0; I < Nsamples; I++)
	{
		NextAlpha = add(pState -> PreviousAlpha, pState -> Delta);
	
		if(NextAlpha >= MAX_16)
		{
			NextAlpha = sub(pState -> PreviousAlpha, MAX_16);
			NextAlpha = add(NextAlpha, pState -> Delta);
			NextAlpha = add(NextAlpha, MIN_16);			
		}

		* pValues  = mult(pState -> Amplitude,tfr16SinPIx(pState -> PreviousAlpha));
		pValues   += 1;
		
		pState -> PreviousAlpha = NextAlpha;
	}
}

typedef struct{
	bool     bAligned;
	UInt16 * pIndex;
	UInt16   Delta;
	Frac16 * pEndTable;
	UInt16   SineTableLength;
}sSineGenIDTL;

/*******************************************************************************/
tfr16_tSineWaveGenIDTL * tfr16SineWaveGenIDTLCreate(Frac16 * pSineTable,
							 						UInt16   SineTableLength,
											 		UInt16   SineFreq,
											 		UInt16   SampleFreq,
											 		Frac16   InitialPhasePIx)
{
	tfr16_tSineWaveGenIDTL * pPrivateData = memMallocEM(sizeof(tfr16_tSineWaveGenIDTL));

	tfr16SineWaveGenIDTLInit(pPrivateData, pSineTable, SineTableLength, SineFreq, SampleFreq, InitialPhasePIx); 
	
	return(pPrivateData);
}

/*******************************************************************************/
void tfr16SineWaveGenIDTLDestroy(tfr16_tSineWaveGenIDTL * pSWG)
{
	if (pSWG != NULL) 
	{
		memFreeEM(pSWG);
	} 	
}

/*******************************************************************************/
void tfr16SineWaveGenIDTLInit(tfr16_tSineWaveGenIDTL * pSWG,
										Frac16                 * pSineTable,
										UInt16                   SineTableLength,
										UInt16                   SineFreq,
										UInt16                   SampleFreq,
										Frac16                   InitialPhasePIx)
{
	sSineGenIDTL * pState        = (sSineGenIDTL *) pSWG;
	Frac16         NormFreq      = div_s((Frac16)SineFreq,(Frac16)SampleFreq);
/*	Frac16         NormFreq      = add(div_s((Frac16)SineFreq,(Frac16)SampleFreq), FRAC16(.001)); */
	Frac16         InitialPhase;
	UInt16         FirstIndex;

	pState -> bAligned = memIsAligned (pSineTable, SineTableLength);  
    
	pState -> SineTableLength = SineTableLength;
 	pState -> Delta           = mult((Frac16)SineTableLength, NormFreq);
	
	InitialPhase = mult(InitialPhasePIx, 0x4000);

	if(InitialPhasePIx < 0)
	{
		InitialPhasePIx  = add(InitialPhasePIx, MAX_16);
		InitialPhase     = add(-InitialPhase, InitialPhasePIx);
	}

	FirstIndex   = mult((Frac16)SineTableLength, InitialPhase);
	
	pState -> pEndTable = pSineTable + SineTableLength;
	pState -> pIndex    = (UInt16 *)pSineTable + FirstIndex;
}

/*******************************************************************************/
void tfr16SineWaveGenIDTLC(tfr16_tSineWaveGenIDTL * pSWG, Frac16 * pValues, UInt16 Nsamples)
{
	sSineGenIDTL * pState = (sSineGenIDTL *) pSWG;
	UInt16         I;
			
	for(I = 0; I < Nsamples; I++)
	{
		* pValues = *(pState -> pIndex);
		pValues  += 1;
		
		pState -> pIndex = (pState -> pIndex + pState -> Delta);

		if((pState -> pIndex) >= (UInt16 *)(pState -> pEndTable))
		{
			pState -> pIndex -= pState -> SineTableLength;
		}
	}
}


typedef struct{
	Frac16   Phase;
	Frac16   Delta;
	Frac16 * pSineTable;
	UInt16   SineTableLength;
}sSineGenRDTL;

/*******************************************************************************/
tfr16_tSineWaveGenRDTL * tfr16SineWaveGenRDTLCreate(Frac16 * pSineTable,
											 		UInt16   SineTableLength,
											 		UInt16   SineFreq,
											 		UInt16   SampleFreq,
											 		Frac16   InitialPhasePIx)
{
	tfr16_tSineWaveGenRDTL * pPrivateData = memMallocEM(sizeof(tfr16_tSineWaveGenRDTL));

	tfr16SineWaveGenRDTLInit(pPrivateData, pSineTable, SineTableLength, SineFreq, SampleFreq, InitialPhasePIx);
	
	return(pPrivateData);
}

/*******************************************************************************/
void tfr16SineWaveGenRDTLDestroy(tfr16_tSineWaveGenRDTL * pSWG)
{
	if (pSWG != NULL) 
	{
		memFreeEM(pSWG);
	} 	
}

/*******************************************************************************/
void tfr16SineWaveGenRDTLInit(tfr16_tSineWaveGenRDTL * pSWG,
										Frac16                 * pSineTable,
										UInt16                   SineTableLength,
										UInt16                   SineFreq,
										UInt16                   SampleFreq,
										Frac16                   InitialPhasePIx)
{
	sSineGenRDTL * pState     = (sSineGenRDTL *) pSWG;
	Frac16         InitialPhase;

	pState -> pSineTable      = pSineTable;
	pState -> SineTableLength = SineTableLength;
 	pState -> Delta           = div_s((Frac16)SineFreq,(Frac16)SampleFreq);
	
	InitialPhase = mult(InitialPhasePIx, SWG_ONEHALF);

	if(InitialPhasePIx < 0)
	{
		InitialPhasePIx = add(InitialPhasePIx, MAX_16);
		InitialPhase    = add(-InitialPhase, InitialPhasePIx);
	}

	pState -> Phase = InitialPhase; 
}

/*******************************************************************************/
void tfr16SineWaveGenRDTLC(tfr16_tSineWaveGenRDTL * pSWG, Frac16 * pValues, UInt16 Nsamples)
{
	sSineGenRDTL * pState = (sSineGenRDTL *) pSWG;
	UInt16         Index;
	UInt16         I;

	for(I = 0; I < Nsamples; I++)
	{
		Index      = mult((Frac16)(pState -> SineTableLength), pState -> Phase);	
		* pValues  = *(pState -> pSineTable + Index);
		pValues   += 1;

		if((pState -> Phase + pState -> Delta) >= MAX_16)
		{
			pState -> Phase = sub(MAX_16, pState -> Phase);
			pState -> Phase = sub(pState -> Delta, pState -> Phase);
		}
	
		else
		{
			pState -> Phase = (pState -> Phase + pState -> Delta);
		}
	}
}

typedef struct{
	Frac16   Phase;
	Frac16   Delta;
	Frac16 * pSineTable;
	UInt16   SineTableLength;
	UInt16   Shift;	
}sSineGenRDITL;

/*******************************************************************************/
tfr16_tSineWaveGenRDITL * tfr16SineWaveGenRDITLCreate(Frac16 * pSineTable,
											 		  UInt16   SineTableLength,
											 		  UInt16   SineFreq,
											 		  UInt16   SampleFreq,
											 		  Frac16   InitialPhasePIx)
{
	tfr16_tSineWaveGenRDITL * pPrivateData = memMallocEM(sizeof(tfr16_tSineWaveGenRDITL));
	
	tfr16SineWaveGenRDITLInit(pPrivateData, pSineTable, SineTableLength, SineFreq, SampleFreq, InitialPhasePIx); 
	
	return(pPrivateData);
}

/*******************************************************************************/
void tfr16SineWaveGenRDITLDestroy(tfr16_tSineWaveGenRDITL * pSWG)
{
	if (pSWG != NULL) 
	{
		memFreeEM(pSWG);
	} 	
}

/*******************************************************************************/
void tfr16SineWaveGenRDITLInit(tfr16_tSineWaveGenRDITL * pSWG,
										Frac16                   * pSineTable,
										UInt16                     SineTableLength,
										UInt16                     SineFreq,
										UInt16                     SampleFreq,
										Frac16                     InitialPhasePIx)
{
	sSineGenRDITL * pState = (sSineGenRDITL *) pSWG;

	pState -> pSineTable      = pSineTable;
	pState -> SineTableLength = SineTableLength;
 	pState -> Delta           = div_s((Frac16)SineFreq,(Frac16)SampleFreq);
	pState -> Phase           = InitialPhasePIx;

	pState -> Shift = 2 * div_s((Frac16)SineTableLength,(Frac16)SWG_180_DEGREES); 
	pState -> Shift = pState -> Shift / 4;
/*	pState -> Shift = (norm_s(pState -> Shift)) + 1; */
	pState -> Shift = norm_s(pState -> Shift);
	pState -> Shift = (pState -> Shift) + 1; 
}

/*******************************************************************************/
void tfr16SineWaveGenRDITLC(tfr16_tSineWaveGenRDITL * pSWG, Frac16 * pValues, UInt16 Nsamples)
{
	sSineGenRDITL * pState = (sSineGenRDITL *) pSWG;
	Frac16       SineAngle;
	Frac16       SineValue1;
	Frac16       SineValue2;
	Frac16       SineDelta;
	Frac16       Sign;
	UInt16       I;
	UInt16       Samples = Nsamples;

	for(I = 0; I < Samples; I++)
	{
		if((pState -> Phase) >= 0)
		{
			if((pState -> Phase) < PI_HALF_PLUS)  /* 0 <= Angle < PI/2 */
			{
				SineAngle = shr_r((pState -> Phase), pState -> Shift); 
				SineDelta = ((pState -> Phase) & 0x003F);
				Sign      = SWG_SIGN_POSITIVE;
			}
    
			else  /* PI/2 <= Angle < PI */
			{
				SineAngle = shr_r((PI_PLUS - (pState -> Phase)), pState -> Shift);
				SineDelta = ((PI_PLUS - (pState -> Phase)) & 0x003F); 
				Sign      = SWG_SIGN_POSITIVE;
			}
		}
	
		else  /* (*Angle) < 0 */
		{
			if((pState -> Phase) < PI_HALF_MINUS)  /* -PI <= Angle < -PI/2 */
			{
				SineAngle = shr_r((PI_PLUS + (pState -> Phase)), pState -> Shift);
				SineDelta = ((PI_PLUS + (pState -> Phase)) & 0x003F); 
				Sign      = SWG_SIGN_NEGATIVE;
			}
			else  /* -PI/2 <= Angle < 0 */                                           
			{
				SineAngle = shr_r((abs_s((pState -> Phase))), pState -> Shift);
				SineDelta = (abs_s((pState -> Phase)) & 0x003F);
				Sign      = SWG_SIGN_NEGATIVE;
			}
		}
  
		SineValue1 = pState -> pSineTable[SineAngle];
		SineValue2 = pState -> pSineTable[SineAngle + 1];
  
		* pValues = Sign * ((((SineValue2 - SineValue1) * SineDelta) >> pState -> Shift) + SineValue1); 
		pValues += 1;
	
		if((pState -> Phase + pState -> Delta) >= MAX_16)
		{
			pState -> Phase = sub(MAX_16, pState -> Phase);
			pState -> Phase = sub(pState -> Delta, pState -> Phase); 
			pState -> Phase = add(pState -> Phase, SWG_NEG_MAX);
		}
	
		else
		{
			pState -> Phase = (pState -> Phase + pState -> Delta);
		}
	}
}

typedef struct{
	Frac16   Phase;
	Frac16   Delta;
	Frac16 * pSineTable;
	UInt16   SineTableLength;
	UInt16   Shift;
}sSineGenRDITLQ;
/*******************************************************************************/
tfr16_tSineWaveGenRDITLQ * tfr16SineWaveGenRDITLQCreate(Frac16 * pSineTable,
											 		  UInt16   SineTableLength,
											 		  UInt16   SineFreq,
											 		  UInt16   SampleFreq,
											 		  Frac16   InitialPhasePIx)
{
	tfr16_tSineWaveGenRDITLQ * pPrivateData = memMallocEM(sizeof(tfr16_tSineWaveGenRDITLQ));
	
	tfr16SineWaveGenRDITLQInit(pPrivateData, pSineTable, SineTableLength, SineFreq, SampleFreq, InitialPhasePIx); 
	
	return(pPrivateData);
}

/*******************************************************************************/
void tfr16SineWaveGenRDITLQDestroy(tfr16_tSineWaveGenRDITLQ * pSWG)
{
	if (pSWG != NULL) 
	{
		memFreeEM(pSWG);
	} 	
}

/*******************************************************************************/
void tfr16SineWaveGenRDITLQInit(tfr16_tSineWaveGenRDITLQ * pSWG,
										Frac16                   * pSineTable,
										UInt16                     SineTableLength,
										UInt16                     SineFreq,
										UInt16                     SampleFreq,
										Frac16                     InitialPhasePIx)
{
	sSineGenRDITLQ * pState = (sSineGenRDITLQ *) pSWG;

	pState -> pSineTable      = pSineTable;
	pState -> SineTableLength = SineTableLength;
 	pState -> Delta           = 2 * div_s((Frac16)SineFreq,(Frac16)SampleFreq);
	pState -> Phase           = InitialPhasePIx;

	pState -> Shift = div_s((Frac16)SineTableLength,(Frac16)SWG_180_DEGREES); 
/*	pState -> Shift = (norm_s(pState -> Shift)) + 1; */
	pState -> Shift = norm_s(pState -> Shift);
	pState -> Shift = (pState -> Shift) + 1; 

}

/*******************************************************************************/
void tfr16SineWaveGenRDITLQC(tfr16_tSineWaveGenRDITLQ * pSWG, Frac16 * pValues, UInt16 Nsamples)
{
	sSineGenRDITLQ * pState = (sSineGenRDITLQ *) pSWG;
	Frac16       SineAngle;
	Frac16       SineValue1;
	Frac16       SineValue2;
	Frac16       SineDelta;
	Frac16       Sign;
	UInt16       I;
	UInt16       Samples = Nsamples;

	for(I = 0; I < Samples; I++)
	{
		if((pState -> Phase) >= 0)
		{
			if((pState -> Phase) < PI_HALF_PLUS)  /* 0 <= Angle < PI/2 */
			{
				SineAngle = shr((pState -> Phase),(pState -> Shift)); 
				SineDelta = ((pState -> Phase) & 0x003F);
				Sign      = SWG_SIGN_POSITIVE;
			}
    
			else  /* PI/2 <= Angle < PI */
			{
				SineAngle = shr((PI_PLUS - (pState -> Phase)),(pState -> Shift)); 
				SineDelta = ((PI_PLUS - (pState -> Phase)) & 0x003F);
				Sign      = SWG_SIGN_POSITIVE;
			}
		}
	
		else  /* (*Angle) < 0 */
		{
			if((pState -> Phase) < PI_HALF_MINUS)  /* -PI <= Angle < -PI/2 */
			{
				SineAngle = shr((PI_PLUS + (pState -> Phase)),(pState -> Shift)); 
				SineDelta = ((PI_PLUS + (pState -> Phase)) & 0x003F);
				Sign      = SWG_SIGN_NEGATIVE;
			}
			else  /* -PI/2 <= Angle < 0 */                                           
			{
				SineAngle = (abs_s(shr((pState -> Phase),(pState -> Shift)))); 
				SineDelta = (abs_s((pState -> Phase)) & 0x003F);
				Sign      = SWG_SIGN_NEGATIVE;
			}
		}
  
		SineValue1 = pState -> pSineTable[SineAngle];
		SineValue2 = pState -> pSineTable[SineAngle + 1];
  
 		* pValues = Sign * (shr(((SineValue2 - SineValue1) * SineDelta),(pState -> Shift)) + SineValue1);
		pValues += 1;
	
		if((pState -> Phase + pState -> Delta) >= MAX_16)
		{
			pState -> Phase = sub(MAX_16, pState -> Phase);
			pState -> Phase = sub(pState -> Delta, pState -> Phase); 
			pState -> Phase = add(pState -> Phase, SWG_NEG_MAX);
		}
	
		else
		{
			pState -> Phase = (pState -> Phase + pState -> Delta);
		}
	}
}

typedef struct{
	Frac16 FilterState1;
	Frac16 FilterState2;
	Frac16 FilterCoefs;
}sSineGenDOM;

/*******************************************************************************/
tfr16_tSineWaveGenDOM * tfr16SineWaveGenDOMCreate(UInt16   SineFreq,
											      UInt16   SampleFreq,
												  Frac16   InitialPhasePIx,
												  Frac16   Amplitude)
{
	tfr16_tSineWaveGenDOM * pPrivateData = memMallocEM(sizeof(tfr16_tSineWaveGenDOM));
	
	tfr16SineWaveGenDOMInit(pPrivateData, SineFreq, SampleFreq, InitialPhasePIx, Amplitude); 
	
	return(pPrivateData);
}

/*******************************************************************************/
void tfr16SineWaveGenDOMDestroy(tfr16_tSineWaveGenDOM * pSWG)
{
	if (pSWG != NULL) 
	{
		memFreeEM(pSWG);
	} 	
}

/*******************************************************************************/
void tfr16SineWaveGenDOMInit(tfr16_tSineWaveGenDOM * pSWG,
									  UInt16                  SineFreq,
									  UInt16                  SampleFreq,
									  Frac16                  InitialPhasePIx,
									  Frac16                  Amplitude)
{
	sSineGenDOM * pState = (sSineGenDOM *) pSWG;
	Frac16        Phi;
	Frac16        InitialPhase1;
	Frac16        InitialPhase2;

 	Phi = div_s((Frac16)(2 * SineFreq),(Frac16)SampleFreq);
	
	InitialPhase1 = sub(InitialPhasePIx, Phi);

	if(InitialPhase1 <= MIN_16)
	{
		InitialPhase1 = sub(MIN_16, InitialPhasePIx);
		InitialPhase1 = add(Phi, InitialPhase1);
		Phi = -Phi;
	}
	
	InitialPhase2 = sub(InitialPhase1, Phi);

	if(InitialPhase2 <= MIN_16)
	{
		InitialPhase2 = sub(MIN_16, InitialPhase1);
		InitialPhase2 = add(Phi, InitialPhase2);
	}

	pState -> FilterState1 = mult(Amplitude, tfr16SinPIx(InitialPhase1));
	pState -> FilterState2 = mult(Amplitude, tfr16SinPIx(InitialPhase2));
	pState -> FilterCoefs  = tfr16CosPIx(Phi);
}

/*******************************************************************************/
void tfr16SineWaveGenDOMC(tfr16_tSineWaveGenDOM * pSWG, Frac16 * pValues, UInt16 Nsamples)
{
	sSineGenDOM * pState = (sSineGenDOM *) pSWG;
	UInt16 I;
	
	for(I = 0; I < Nsamples; I++)
	{
		* pValues = mult(pState->FilterCoefs, pState -> FilterState1);
		
		pState -> FilterState2 = mult(SWG_ONEHALF, pState -> FilterState2);
	
		* pValues = sub(* pValues, pState -> FilterState2);
		* pValues = add(* pValues, * pValues);

		pState -> FilterState2 = pState -> FilterState1;
		pState -> FilterState1 = * pValues;

		pValues += 1;
	}
}

typedef struct{
	Frac16   Phase;
	Frac16 * pSineTable;
	UInt16   SineTableLength;
	UInt16   Shift;
}sWaveGenRDITLQ;

/*******************************************************************************/
tfr16_tWaveGenRDITLQ * tfr16WaveGenRDITLQCreate(Frac16 * pSineTable,
											 		  UInt16   SineTableLength,
											 		  Frac16   InitialPhasePIx)
{
	tfr16_tWaveGenRDITLQ * pPrivateData = memMallocEM(sizeof(tfr16_tWaveGenRDITLQ));
	
	tfr16WaveGenRDITLQInit(pPrivateData, pSineTable, SineTableLength, InitialPhasePIx); 
	
	return(pPrivateData);
}

/*******************************************************************************/
void tfr16WaveGenRDITLQDestroy(tfr16_tWaveGenRDITLQ * pSWG)
{
	if (pSWG != NULL) 
	{
		memFreeEM(pSWG);
	} 	
}

/*******************************************************************************/
void tfr16WaveGenRDITLQInit(tfr16_tWaveGenRDITLQ * pSWG,
										Frac16             * pSineTable,
										UInt16               SineTableLength,
										Frac16               InitialPhasePIx)
{
	sWaveGenRDITLQ * pState = (sWaveGenRDITLQ *) pSWG;

	pState -> pSineTable      = pSineTable;
	pState -> SineTableLength = SineTableLength;
	pState -> Phase           = InitialPhasePIx;

	pState -> Shift = div_s((Frac16)SineTableLength,(Frac16)SWG_180_DEGREES); 
/*	pState -> Shift = (norm_s(pState -> Shift)) + 1; */
	pState -> Shift = norm_s(pState -> Shift);
	pState -> Shift = (pState -> Shift) + 1; 
}

/*******************************************************************************/
Frac16 tfr16WaveGenRDITLQC(tfr16_tWaveGenRDITLQ * pSWG, Frac16 PhaseIncrement)
{
	sWaveGenRDITLQ * pState = (sWaveGenRDITLQ *) pSWG;
	Frac16       SineAngle;
	Frac16       SineValue1;
	Frac16       SineValue2;
	Frac16       SineDelta;
	Frac16       LocalPhaseIncrement = PhaseIncrement;
	Frac16       Sign;

	if((pState -> Phase) >= 0)
	{
		if((pState -> Phase) < PI_HALF_PLUS)  /* 0 <= Angle < PI/2 */
		{
			SineAngle = shr((pState -> Phase),(pState -> Shift)); 
			SineDelta = ((pState -> Phase) & 0x003F);
			Sign      = SWG_SIGN_POSITIVE;
		}
    
		else  /* PI/2 <= Angle < PI */
		{
			SineAngle = shr((PI_PLUS - (pState -> Phase)),(pState -> Shift)); 
			SineDelta = ((PI_PLUS - (pState -> Phase)) & 0x003F);
			Sign      = SWG_SIGN_POSITIVE;
		}
	}
	
	else  /* (*Angle) < 0 */
	{
		if((pState -> Phase) < PI_HALF_MINUS)  /* -PI <= Angle < -PI/2 */
		{
			SineAngle = shr((PI_PLUS + (pState -> Phase)),(pState -> Shift)); 
			SineDelta = ((PI_PLUS + (pState -> Phase)) & 0x003F);
			Sign      = SWG_SIGN_NEGATIVE;
		}
		else  /* -PI/2 <= Angle < 0 */                                           
		{
			SineAngle = (abs_s(shr((pState -> Phase),(pState -> Shift)))); 
			SineDelta = (abs_s((pState -> Phase)) & 0x003F);
			Sign      = SWG_SIGN_NEGATIVE;
		}
	}
  
	SineValue1 = pState -> pSineTable[SineAngle];
	SineValue2 = pState -> pSineTable[SineAngle + 1];
  
 	SineAngle = Sign * (shr(((SineValue2 - SineValue1) * SineDelta),pState -> Shift) + SineValue1);

	if((pState -> Phase + LocalPhaseIncrement) >= MAX_16)
	{
		pState -> Phase = sub(MAX_16, pState -> Phase);
		pState -> Phase = sub(LocalPhaseIncrement, pState -> Phase); 
		pState -> Phase = add(pState -> Phase, SWG_NEG_MAX);
	}
	
	else
	{
		pState -> Phase = (pState -> Phase + LocalPhaseIncrement);
	}

	return(SineAngle);
}

typedef struct{
	Frac16 * pSineTable;
	UInt16   SineTableLength;
	UInt16   Shift;
}sSinPIxLUT;
/*******************************************************************************/
tfr16_tSinPIxLUT * tfr16SinPIxLUTCreate(Frac16 * pSineTable,
														UInt16   SineTableLength)
{
	tfr16_tSinPIxLUT * pPrivateData = memMallocEM(sizeof(tfr16_tSinPIxLUT));
	
	tfr16SinPIxLUTInit(pPrivateData, pSineTable, SineTableLength); 
	
	return(pPrivateData);
}

/*******************************************************************************/
void tfr16SinPIxLUTDestroy(tfr16_tSinPIxLUT * pSWG)
{
	if (pSWG != NULL) 
	{
		memFreeEM(pSWG);
	} 	
}

/*******************************************************************************/
void tfr16SinPIxLUTInit(tfr16_tSinPIxLUT * pSWG,
										Frac16     * pSineTable,
										UInt16       SineTableLength)
{
	sSinPIxLUT * pState = (sSinPIxLUT *) pSWG;

	pState -> pSineTable      = pSineTable;
	pState -> SineTableLength = SineTableLength;

	pState -> Shift = div_s((Frac16)SineTableLength,(Frac16)SWG_180_DEGREES); 
/*	pState -> Shift = (norm_s(pState -> Shift)) + 1; */
	pState -> Shift = norm_s(pState -> Shift);
	pState -> Shift = (pState -> Shift) + 1; 
}

/*******************************************************************************/
Frac16 tfr16SinPIxLUTC(tfr16_tSinPIxLUT * pSWG, Frac16 PhasePIx)
{
 	sSinPIxLUT * pState = (sSinPIxLUT *) pSWG;
	Frac16       SineAngle;
	Frac16       SineValue1;
	Frac16       SineValue2;
	Frac16       SineDelta;
	Frac16       Sign;

	if(PhasePIx >= 0)
	{
		if(PhasePIx < PI_HALF_PLUS)  /* 0 <= Angle < PI/2 */
		{
			SineAngle = shr(PhasePIx,(pState -> Shift)); 
			SineDelta = (PhasePIx & 0x003F);
			Sign      = SWG_SIGN_POSITIVE;
		}
    
		else  /* PI/2 <= Angle < PI */
		{
			SineAngle = shr((PI_PLUS - PhasePIx),(pState -> Shift)); 
			SineDelta = ((PI_PLUS - PhasePIx) & 0x003F);
			Sign      = SWG_SIGN_POSITIVE;
		}
	}
	
	else  /* (*Angle) < 0 */
	{
		if(PhasePIx < PI_HALF_MINUS)  /* -PI <= Angle < -PI/2 */
		{
			SineAngle = shr((PI_PLUS + PhasePIx),(pState -> Shift)); 
			SineDelta = ((PI_PLUS + PhasePIx) & 0x003F);
			Sign      = SWG_SIGN_NEGATIVE;
		}
		else  /* -PI/2 <= Angle < 0 */                                           
		{
			SineAngle = (abs_s(shr(PhasePIx,(pState -> Shift)))); 
			SineDelta = (abs_s(PhasePIx) & 0x003F);
			Sign      = SWG_SIGN_NEGATIVE;
		}
	}
  
	SineValue1 = pState -> pSineTable[SineAngle];
	SineValue2 = pState -> pSineTable[SineAngle + 1];
  
 	SineAngle = Sign * (shr(((SineValue2 - SineValue1) * SineDelta),(pState -> Shift)) + SineValue1);

	return(SineAngle);
}

typedef struct{
	Frac16 * pSineTable;
	UInt16   SineTableLength;
	UInt16   Shift;
}sCosPIxLUT;
/*******************************************************************************/
tfr16_tCosPIxLUT * tfr16CosPIxLUTCreate(Frac16 * pSineTable,
														UInt16   SineTableLength)
{
	tfr16_tCosPIxLUT * pPrivateData = memMallocEM(sizeof(tfr16_tCosPIxLUT));
	
	tfr16CosPIxLUTInit(pPrivateData, pSineTable, SineTableLength); 
	
	return(pPrivateData);
}

/*******************************************************************************/
void tfr16CosPIxLUTDestroy(tfr16_tCosPIxLUT * pSWG)
{
	if (pSWG != NULL) 
	{
		memFreeEM(pSWG);
	} 	
}

/*******************************************************************************/
void tfr16CosPIxLUTInit(tfr16_tCosPIxLUT * pSWG,
										Frac16     * pSineTable,
										UInt16       SineTableLength)
{
	sCosPIxLUT * pState = (sCosPIxLUT *) pSWG;

	pState -> pSineTable      = pSineTable;
	pState -> SineTableLength = SineTableLength;

	pState -> Shift = div_s((Frac16)SineTableLength,(Frac16)SWG_180_DEGREES); 
/*	pState -> Shift = (norm_s(pState -> Shift)) + 1; */
	pState -> Shift = norm_s(pState -> Shift);
	pState -> Shift = (pState -> Shift) + 1; 
}

/*******************************************************************************/
Frac16 tfr16CosPIxLUTC(tfr16_tCosPIxLUT * pSWG, Frac16 PhasePIx)
{
 	sCosPIxLUT * pState = (sCosPIxLUT *) pSWG;
	Frac16       SineAngle;
	Frac16       SineValue1;
	Frac16       SineValue2;
	Frac16       SineDelta;
	Frac16       Sign;

	if(PhasePIx < 0)
	{
		PhasePIx = -PhasePIx;
	}

	PhasePIx -= PI_HALF_PLUS;

	if(PhasePIx >= 0)
	{
		SineAngle = shr(PhasePIx,(pState -> Shift)); 
		SineDelta = (PhasePIx & 0x003F);
		Sign      = SWG_SIGN_NEGATIVE;
	}
	
	else  /* (*Angle) < 0 */
	{
		SineAngle = (abs_s(shr(PhasePIx,(pState -> Shift)))); 
		SineDelta = (abs_s(PhasePIx) & 0x003F);
		Sign      = SWG_SIGN_POSITIVE;
	}
  
	SineValue1 = pState -> pSineTable[SineAngle];
	SineValue2 = pState -> pSineTable[SineAngle + 1];
  
 	SineAngle = Sign * (shr(((SineValue2 - SineValue1) * SineDelta),(pState -> Shift)) + SineValue1);

	return(SineAngle);
}
