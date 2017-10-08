/**********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
***********************************************************************
*
* File Name: cas_init.c
*
* Description: Includes a function to initialize the instance of CAS
*
* Modules Included: casDetectInit
*                   
* Author: Sandeep S
*
* Date: 23/11/2000
*
**********************************************************************/

#include "casDetect.h"

EXPORT void CAS_DETECT_INIT(void);

/**********************************************************************
*
* Module: casDetectInit()
*
* Description: Initializes the instance of casDetect. 
*
* Returns: None
*
* Arguments: Pointer to structure casDetect_sHandle
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

#include "casDetect.h"

EXPORT void CAS_DETECT_INIT(void);

void casDetectInit (casDetect_sHandle *pCasDetect)
{
  
    /* Clear the initial context_buf_length */
    
    pCasDetect->context_buf_length = 0;
    
    /* Call the ASM init function to initialize the buffers and
       the variable states */

    CAS_DETECT_INIT(); /* Call to the ASM code of init*/
    
    return;
}
