/**********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
***********************************************************************
*
* File Name: cas_destroy.c
*
* Description: Includes a function that destroys the instance of CAS
*
* Modules Included: casDetectDestroy
*                   
* Author: Sandeep S
*
* Date: 23/11/2000
*
**********************************************************************/

#include "mem.h"
#include "casDetect.h"

/**********************************************************************
*
* Module: casDetectDestroy()
*
* Description: Destroys the instance of casDetect. 
*
* Returns: None
*
* Arguments: Pointer to casDetect_sHandle structure 
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: Tested through test_casdetect.mcp
*
***************************** Change History **************************
*
*  DD/MM/YY    Code Ver     Description                Author
*  --------    --------     -----------                ------
*  23/11/2000  0.0.1        Function created          Sandeep S
*  18/12/2000  1.0.0        Modified per review       Sandeep S
*                           comments and baselined
*
**********************************************************************/

void casDetectDestroy (casDetect_sHandle *pCasDetect)
{
   /* Deallocate the memory for the context buffer */
   
   if (pCasDetect->In_Context_buf != NULL) 
    memFreeEM (pCasDetect->In_Context_buf);    
    
    if (pCasDetect != NULL)
   /* Free up the memory for the handle structure */
    memFreeEM (pCasDetect);
    
    return;
    
}    
    