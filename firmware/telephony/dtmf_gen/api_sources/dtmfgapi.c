/***********************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
************************************************************************
*
* File Name: dtmfgAPI.c
*
* Description: This module is an API for DTMF Generation and to be
*              used by the user Application routines
*
* Modules Included:
*                   dtmfCreate ()
*                   dtmfInit ()
*                   dtmfSetKey ()
*                   dtmfGenerate ()
*                   dtmfDestroy ()
*
* Author : Meera S. P.
*
* Date   : 30 May 2000
*
* Modified By : Sudarshan & Mahesh
*
* Date of Modification: 11 July 2001
*
***********************************************************************/

#include "dtmf.h"
#include "mem.h"

void  dtmfg_in (UWord16, UWord16 *);
Int16 dtmf_gen (Word16 *);

typedef struct 
{
	UInt16    OnDuration;   /* Number of samples */
	UInt16    OffDuration;  /* Number of samples */
	UInt16    tempOnDuration;   /* Number of samples */
	UInt16    tempOffDuration;  /* Number of samples */
	UWord16   SampleRate;   /* Frequency of Samples */
	Word16    CoefBuf[8];
	Word16    KeyGenerated;  /* true - once the key is generated */
	Word16    amp;
	Word16    hi_buf[2];
	Word16    lo_buf[2];
	Word16    al_2;
	Word16    ah_2;
	UWord16   rindx;
	UWord16   cindx;
} sDTMF;

#define  sl1 lo_buf[0]
#define  sl2 lo_buf[1]

#define  sh1 hi_buf[0]
#define  sh2 hi_buf[1]

/***********************************************************************
*
* Module: dtmfCreate ()
*
* Description: This function is used to create an instance of DTMF. 
*
* Returns: pDTMF - pointer to the dtmf_sHandle structure which is
*                  an instnce of DTMF generation function.
*                  23 words get allocated per instance
*
* Arguments: pConfig - pointer to the dtmf_sConfigure structure used 
*                      to configure DTMF Generation operation.
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through dtmf_gen_test.mcp and demodtmf_gen.mcp
*
***************************** Change History ***************************
*
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    30/05/2000     0.0.1        Created          Meera S. P.
*    01/06/2000     1.0.0        Reviewed and     Meera S. P.
*                                Baselined
*
***********************************************************************/

dtmf_sHandle *dtmfCreate (dtmf_sConfigure *pConfig)
{
    dtmf_sHandle *pDTMF;
	
    pDTMF = (dtmf_sHandle *)memMallocEM (sizeof(dtmf_sHandle));
    
    if (pDTMF != NULL)
    {
        dtmfInit (pDTMF, pConfig);
    }    
    
    return (pDTMF);
}


/***********************************************************************
*
* Module: dtmfInit ()
*
* Description: The dtmfInit function will initialize the DTMF Generation
*              algorithm. During the initialization, all resources will 
*              be set to their initial values in preparation for DTMF 
*              Generation operation. 
*
* Returns: PASS or FAIL
*
* Arguments: pDTMF   - Handle to an instance of DTMF
*            pConfig - pointer to the dtmf_sConfigure structure used 
*                      to configure DTMF Generation operation.
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through dtmf_gen_test.mcp and demodtmf_gen.mcp
*
***************************** Change History ***************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    30/05/2000     0.0.1        Created          Meera S. P.
*    01/06/2000     1.0.0        Reviewed and     Meera S. P.
*                                Baselined
*
***********************************************************************/

Result dtmfInit (dtmf_sHandle *pDTMF, dtmf_sConfigure *pConfig)
{
	   
    if (pConfig->SampleRate == 7200)
    {
        ((sDTMF *)pDTMF)->CoefBuf[0] = 0x690b;
        ((sDTMF *)pDTMF)->CoefBuf[1] = 0x642d;
        ((sDTMF *)pDTMF)->CoefBuf[2] = 0x5e38;
        ((sDTMF *)pDTMF)->CoefBuf[3] = 0x5737;
        ((sDTMF *)pDTMF)->CoefBuf[4] = 0x3f21;
        ((sDTMF *)pDTMF)->CoefBuf[5] = 0x326d;
        ((sDTMF *)pDTMF)->CoefBuf[6] = 0x239b;
        ((sDTMF *)pDTMF)->CoefBuf[7] = 0x1297;
    }
    
    if (pConfig->SampleRate == 8000)
    {
        ((sDTMF *)pDTMF)->CoefBuf[0] = 0x6d4c;
        ((sDTMF *)pDTMF)->CoefBuf[1] = 0x694c;
        ((sDTMF *)pDTMF)->CoefBuf[2] = 0x6465;
        ((sDTMF *)pDTMF)->CoefBuf[3] = 0x5e9b;
        ((sDTMF *)pDTMF)->CoefBuf[4] = 0x4a81;
        ((sDTMF *)pDTMF)->CoefBuf[5] = 0x3fc5;
        ((sDTMF *)pDTMF)->CoefBuf[6] = 0x331d;
        ((sDTMF *)pDTMF)->CoefBuf[7] = 0x2463;
    }
    
    ((sDTMF *)pDTMF)->OnDuration  = pConfig->OnDuration;
    ((sDTMF *)pDTMF)->OffDuration = pConfig->OffDuration;
    ((sDTMF *)pDTMF)->SampleRate  = pConfig->SampleRate;
    ((sDTMF *)pDTMF)->amp         = pConfig->amp;

    ((sDTMF *)pDTMF)->KeyGenerated = false;
	
	return (PASS);
}


/***********************************************************************
*
* Module: dtmfSetKey ()
*
* Description: Establishes the current key for DTMF tone generation 
*
* Returns: PASS or FAIL
*
* Arguments:  pDTMF   - Handle to an instance of DTMF
*             Key     - Key for which DTMF samples are to be generated.
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through dtmf_gen_test.mcp and demodtmf_gen.mcp
*
***************************** Change History ***************************
* 
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    30/05/2000     0.0.1        Created          Meera S. P.
*    01/06/2000     1.0.0        Reviewed and     Meera S. P.
*                                Baselined
*    11/07/2001     2.0.0        Changed for      Sudarshan & Mahesh
*                                Multi Channel
*
***********************************************************************/

Result dtmfSetKey (dtmf_sHandle *pDTMF, char Key)
{   
    Result result  = PASS;
    int    akey    = Key;
    
    long    temp1,temp2 = 0;
    long    temp3;

	if (Key > '0' && Key <= '9')
	{
		if (Key >= '4' && Key <= '6')
			akey = Key + 1;
		else if (Key >= '7' && Key <= '9')
			akey = Key + 2;
			
		akey  = akey - '1';
		((sDTMF *)pDTMF)->rindx = akey >> 2; 
		((sDTMF *)pDTMF)->cindx = akey & 0x3;
	}
	else if(Key >= 'A' && Key <= 'D')
	{
		((sDTMF *)pDTMF)->rindx   = Key - 'A';
		((sDTMF *)pDTMF)->cindx   = 3;
	}
	else
	{
		((sDTMF *)pDTMF)->rindx   = 3;
		if( Key == '*')
			((sDTMF *)pDTMF)->cindx   = 0;
		else if( Key == '0')
			((sDTMF *)pDTMF)->cindx   = 1;
		else if( Key == '#') 
			((sDTMF *)pDTMF)->cindx   = 2;
		else
			result = FAIL;
	} 
	
    if(result == PASS)
    {
    	((sDTMF *)pDTMF)->tempOnDuration  = ((sDTMF *)pDTMF)->OnDuration;
    	((sDTMF *)pDTMF)->tempOffDuration = ((sDTMF *)pDTMF)->OffDuration;
    	((sDTMF *)pDTMF)->KeyGenerated    = false;
    
        ((sDTMF *)pDTMF)->al_2 = ((sDTMF *)pDTMF)->CoefBuf[((sDTMF *)pDTMF)->rindx];
        
        ((sDTMF *)pDTMF)->ah_2 = ((sDTMF *)pDTMF)->CoefBuf[(((sDTMF *)pDTMF)->cindx) + 4];
        
        temp1 = ((sDTMF *)pDTMF)->amp;

        ((sDTMF *)pDTMF)->sl2 = temp1;
        ((sDTMF *)pDTMF)->sh2 = temp1;
        
 
        temp2 = ((sDTMF *)pDTMF)->al_2;
        temp3 = temp1 * temp2;
        temp3 = (((temp3 << 1) + 0x8000) >> 16);
        
        ((sDTMF *)pDTMF)->sl1 = temp3;
         
        temp2 = ((sDTMF *)pDTMF)->ah_2;
        temp3 = temp1 * temp2;
        temp3 = (((temp3 << 1) + 0x8000) >> 16);
        
        ((sDTMF *)pDTMF)->sh1 = temp3;
 
    }
    
    return (result);
}


/***********************************************************************
*
* Module: dtmfGenerate ()
*
* Description: Generates the DTMF samples for the current key. 
*
* Returns: PASS or FAIL
*
* Arguments:  pDTMF      - Handle to an instance of DTMF
*             pData      - Pointer to output buffer
*             NumSamples - Number of samples to be generated per call.
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through dtmf_gen_test.mcp and demodtmf_gen.mcp
*
***************************** Change History ***************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    30/05/2000     0.0.1        Created          Meera S. P.
*    01/06/2000     1.0.0        Reviewed and     Meera S. P.
*                                Baselined
*
***********************************************************************/

Result dtmfGenerate (dtmf_sHandle *pDTMF, Int16 *pData, UWord16 NumSamples)
{
    UWord16 i;
    Int16   *tempData;
    
    tempData = pData;    
    for (i = 0; i < NumSamples; i++)
    {
        if ((((sDTMF *)pDTMF)->tempOnDuration) > 0)
        {
            *pData++ = dtmf_gen ((Word16 *)pDTMF);
            ((sDTMF *)pDTMF)->tempOnDuration--;
        }
        else   
        {
            if ((((sDTMF *)pDTMF)->KeyGenerated) == false)
            {
                ((sDTMF *)pDTMF)->tempOffDuration--;
                if ((((sDTMF *)pDTMF)->tempOffDuration) == 0)
                {
                    ((sDTMF *)pDTMF)->KeyGenerated = true;
                }
            }
            
            *pData++ = 0;
        }
        
    }
    
    pData = tempData;
    return ((((sDTMF *)pDTMF)->KeyGenerated) ? FAIL : PASS);
}


/***********************************************************************
*
* Module: dtmfDestroy ()
*
* Description: Frees the instance of DTMF pointed to by dtmf_sHandle 
*              structure 
*
* Returns: None
*
* Arguments:  pDTMF - Handle to an instance of DTMF
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through dtmf_gen_test.mcp and demodtmf_gen.mcp
*
***************************** Change History ***************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    30/05/2000     0.0.1        Created          Meera S. P.
*    01/06/2000     1.0.0        Reviewed and     Meera S. P.
*                                Baselined
*
***********************************************************************/

void dtmfDestroy (dtmf_sHandle *pDTMF)
{
    if (pDTMF != NULL)
    {
        memFreeEM (pDTMF);
    }
}