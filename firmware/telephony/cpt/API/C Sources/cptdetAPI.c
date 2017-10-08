/***********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
************************************************************************
*
* File Name: vad_create.c
*
* Description: Includes API routines for CPT detection and to be
*                 used by the user Application routines                  
*
* Modules Included:
*                   CPTDetCreate ()
*                   CPTDetInit ()
*                   CPTDetection ()
*                   CPTDetDestroy ()
*                
* Author : Manohar Babu
*
* Date   : 25 Sept 2000
*
***********************************************************************/

#include "cptdet.h"
#include "stdlib.h"
#include "arch.h"
#include "mem.h" 
#include "port.h"

/*  Function prototypes */

extern UWord16 PROCESS_CPT (Word16 );    
extern void    CALLPROGRESS_DETECT_INIT(void);


/***********************************************************************
*
* Module: CPTDetCreate ()
*
* Description: To create an instance of the CPT configuration 
*              and context parameters. The memory allocation is as
*              follows:
*              Extenal memory : 4 words
*              Internal memory: 0 words
*              CPTdetCreate function does all the initializations 
*              for the CPT Detection by internally calling CPTDetInit
*              fuction. CPT Detection code is not re-entrant.
*
* Returns: pointer to CPTDet_sHandle structure containing the instance
*          to CPT
*
* Arguments: pConfig - a pointer to CPTDet_sConfigure structure
*                      containing the CPT configuration
* 
* Range Issues: None
*
* Special Issues: Should be called before calling any of the API modules
*
* Test Method: test_cpt.mcp for testing and demo_cpt.mcp for the demo
*
**************************** Change History ****************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    25/09/2000     0.0.1        Created          Manohar Babu
*    11/10/2000     1.0.0        Reviewed and     Manohar Babu
*                                Baselined
*
*****************************************************************************/

CPTDet_sHandle * CPTDetCreate (CPTDet_sConfigure *pConfig)
{
     
    CPTDet_sHandle *pCPTDet;
     
    pCPTDet = (CPTDet_sHandle *) memMallocEM (sizeof (CPTDet_sHandle));
     
    pCPTDet->pCallback = (CPTDet_sCallback *) memMallocEM (sizeof (CPTDet_sCallback));
    
    if ((pCPTDet ||  pCPTDet->pCallback) == NULL)
    
         return (NULL);
     
    CPTDetInit (pCPTDet, pConfig); 
     
    return (pCPTDet);
}


/***********************************************************************
*
* Module: CPTDetInit ()
*
* Description: The CPTDetInit function will initialize the CPT Detection
*              algorithm. During the initialization, all resources will
*              be set to their initial values in preparation for CPT 
*              Detection operation. This function is called internally
*              by CPTDetCreate. This function initializes all the 
*              static variables in preparation for the CPT detection
*              algorithm. No configuration is needed for this algorithm.
*
* Returns: None
*
* Arguments: pCPTDet - Handle to an instance of CPT detection
*            pConfig - pointer to the CPTDet_sConfigure structure used 
*                      to configure CPT Detection operation.
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method: test_cpt.mcp for testing and demo_cpt.mcp for the demo
*
**************************** Change History ****************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    25/09/2000     0.0.1        Created          Manohar Babu
*    11/10/2000     1.0.0        Reviewed and     Manohar Babu
*                                Baselined
*
***********************************************************************/

void  CPTDetInit (CPTDet_sHandle *pCPTDet, CPTDet_sConfigure *pConfig)
{

    pCPTDet->pCallback->pCallback = pConfig->CPTDetCallback.pCallback; 
    pCPTDet->pCallback->pCallbackArg = pConfig->CPTDetCallback.pCallbackArg;
    
    CALLPROGRESS_DETECT_INIT();
    
}



/***********************************************************************
*
* Module: CPTDetection ()
*
* Description: The CPTDetection function will process the samples
*              supplied. These are linear PCM samples and are in 1.15
*              format. After processing, if any valid tone is detected
*              the result is given back to the user by calling the 
*              CPTDetCallback procedure. 
*
* Returns: PASS or FAIL
*
* Arguments: pCPTDet - Handle to an instance of CPT detection
*            pSamples  - Pointer to the input data buffer .
*            NumberSamples - Number of samples to be processed. 
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method: test_cpt.mcp for testing and demo_cpt.mcp for the demo
*
**************************** Change History ****************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    25/09/2000     0.0.1        Created          Manohar Babu
*    11/10/2000     1.0.0        Reviewed and     Manohar Babu
*                                Baselined
*
*****************************************************************************/

Result  CPTDetection (CPTDet_sHandle *pCPTDet, Word16 *pSamples,
                      UWord16 NumberSamples)
{
  
    Result   result = FAIL;
    UWord16  i, j, return_value = 0x00ff;
    
    /* Decimate the samples by 2 to work at 4 KHz sampling */
    for ( i=0; i < NumberSamples; i++)
    {
        return_value = PROCESS_CPT (*(pSamples+i));
        if ( (return_value != 0xFF) && (return_value != 0x17))
        {
            pCPTDet->pCallback->pCallback(pCPTDet->pCallback->pCallbackArg,
                                          return_value);
                     
            result= PASS;                       
            break;
        }
        
   }
  
   return (result);   

} 



/***********************************************************************
*
* Module: CPTDetDestroy ()
*
* Description: The CPTDetDestroy function will free all the allocated 
*              memory 
*
* Returns: None
*
* Arguments: pCPTDet - Handle to an instance of CPT detection
* 
* Range Issues: None
*
* Special Issues: None
*
* Test Method: test_cpt.mcp for testing and demo_cpt.mcp for the demo
*
**************************** Change History ****************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    25/09/2000     0.0.1        Created          Manohar Babu
*    11/10/2000     1.0.0        Reviewed and     Manohar Babu
*                                Baselined
*
*****************************************************************************/

void CPTDetDestroy (CPTDet_sHandle * pCPTDet)

{   
    memFreeEM (pCPTDet->pCallback);
    memFreeEM (pCPTDet);
    return ;
}     

