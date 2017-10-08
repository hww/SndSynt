/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: calleridapi.c
*
* Description: This module is an API for Caller ID detection and to be
*              used by the user Application routines
*
* Modules Included:
*                   callerIDCreate () - C function
*                   callerIDInit ()  -  C function
*                   callerIDRX ()    -  C function
*                   callerIDControl () - C function
*                   callerIDDestroy () - C function
*                   callerIDGetSetConditionCode () -  Asm function
*
* Author : Meera S. P.
*
* Date   : 03 May 2000
*
*****************************************************************************/

#include "CallerID.h"
#include "stdlib.h"
#include "arch.h"
#include "mem.h"

/*  Function prototypes */
Result   CallerID_Init (UWord16);
Result   CallerID_Process (Word16);
UWord16  CID_DATA_BUFF[];
bool     callerIDGetSetConditionCode(bool);


callerID_sCallback callerIDCallback;

/****************************************************************************
* Function Name : callerIDCreate
*
* Description   : Creates an instance of Caller ID.
* 
* Arguments     : pConfig - pointer to the callerID_sConfigure structure used 
*                           to configure Caller ID Detection operation.
*
* Returns       : NULL
/*************************Change History*************************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    11/05/2000     0.0.1        Created          Meera S. P.
*    19/05/2000     1.0.0        Reviewed and     Meera S. P.
*                                Baselined
*
*****************************************************************************/


callerID_sHandle * callerIDCreate (callerID_sConfigure * pConfig)
{
     callerID_sHandle *pCallerID;
     Result  result;
     
     pCallerID = memMallocEM (sizeof(callerID_sHandle));
     if (pCallerID == NULL) return (NULL);
     
     return (pCallerID);
}



/****************************************************************************
*
* Module: callerIDInit ()
*
* Description: The callerIDInit function will initialize the Caller ID
*              Detection algorithm. During the initialization, all
*              resources will be set to their initial values in 
*              preparation for Caller ID Detection operation.
*
* Returns: PASS or FAIL
*
* Arguments: pConfig - pointer to the callerID_sConfigure structure used 
*                      to configure Caller ID Detection operation.
*
* Range Issues: None
*
* Special Issues: Should be called before calling any of the
*                 API modules
*
* Test Method: caller_id_test.mcp for testing
*
**************************** Change History ********************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    11/05/2000     0.0.1        Created          Meera S. P.
*    19/05/2000     1.0.0        Reviewed and     Meera S. P.
*                                Baselined
*    15/11/2000     1.0.1        Removed create   Sanjay Karpoor
*                                function
*
****************************************************************************/

Result callerIDInit (callerID_sHandle *pCallerID, callerID_sConfigure *pConfig)
{
    Result   result;
    UWord16  Flags;

    
    callerIDCallback = pConfig -> callerIDCallback;


    Flags    = pConfig -> Flags;
    
    result = CallerID_Init (Flags);

    return (result);
    
}


/****************************************************************************
*
* Module: callerIDRX ()
*
* Description: The callerIDRX function will process the samples supplied. 
*              Once the processing is done, the result is given back to 
*              the user by calling the Callback procedure. The user can 
*              call the callerIDRX function any number of times, as long 
*              as user has data.
*
* Returns: PASS or FAIL
*
* Arguments: pSamples - Pointer to the input data buffer for each frame
*            NumberSamples - No. of samples to be processed per frame
*
* Range Issues: None
*
* Special Issues: None.
*
* Test Method: caller_id_test.mcp for testing
*
**************************** Change History ********************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    11/05/2000     0.0.1        Created          Meera S. P.
*    19/05/2000     1.0.0        Reviewed and     Meera S. P.
*                                Baselined
*
****************************************************************************/

Result callerIDRX (callerID_sHandle * pCallerID, Word16 * pSamples, UWord16 NumberSamples)
{
    Result   result;
    Word16   sample;
    UWord16  i, numchars,status;
    bool     CC_Bit = 0;
    
    CC_Bit = callerIDGetSetConditionCode(CC_Bit);
    
    
    result = PASS;
        
    for ( i = 0; i < NumberSamples; i++)
    {
        sample = *pSamples++;
        status = CallerID_Process(sample);
    }  
    if ((status & CALLERID_DATA_READY) == CALLERID_DATA_READY)
    {
        
        numchars = CID_DATA_BUFF[1] + 2;
           
        /* Call back proc to indicate that data is ready in tx_out,
           status is always data available
         */  
            
        callerIDCallback.pCallback(                     
                    callerIDCallback.pCallbackArg,
                    CALLERID_DATA_READY,
                    CID_DATA_BUFF,
                    numchars
			      );
    }
        
    if ((status & CALLERID_ERROR) == CALLERID_ERROR)
    {
        callerIDCallback.pCallback(                     
                    callerIDCallback.pCallbackArg,
                     status,
                    NULL,
                    0
                    );
        
          result = FAIL;
      }
        
      callerIDGetSetConditionCode(CC_Bit);
      
      return (result);
    
}


void  callerIDDestroy( callerID_sHandle * pCallerID)
{
      if (pCallerID != NULL)
          memFreeEM (pCallerID);
      return ;
}     



UWord16  callerIDControl( UWord16  Command)
{
   Result result = PASS;
   
   return (result);        
}     
