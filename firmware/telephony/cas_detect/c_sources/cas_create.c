/**********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
***********************************************************************
*
* File Name: cas_create.c
*
* Description: Includes a function to create the instance of CAS
*
* Modules Included: casDetectCreate                   
*
* Author: Sandeep S
*
* Date: 23/11/2000
*
**********************************************************************/

#include "mem.h"
#include "casDetect.h"

#define FRAME_SZ 80

/**********************************************************************
*
* Module: casDetectCreate()
*
* Description: To create an instance of the casDetect  
*              configuration and context parameters. Each call to the
*              create allocates 82 words of external memory.
*
* Returns: Pointer to Structure of type casDetect_sHandle.
*
* Arguments: None.
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

casDetect_sHandle *casDetectCreate (void)
{
    casDetect_sHandle *pCasDetect;
    
    /* Allocate the memory for the handle structure*/
    
    pCasDetect = (casDetect_sHandle *) memMallocEM (
                    sizeof (casDetect_sHandle));
    
    if (pCasDetect == NULL) return (NULL);
    
    /* Allocate memory for the In_Context_buf */

    pCasDetect->In_Context_buf = (Int16 *) memMallocEM (FRAME_SZ * sizeof(Int16));
    if (pCasDetect->In_Context_buf == NULL) return (NULL);
                
    return (pCasDetect);
    
}    
    