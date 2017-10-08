/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*****************************************************************************
*
* File Name: tmain_cpt.c
*
* Description: This module calls the CPT test function
*
* Modules Included:
*                   main ()
*
* Author : Manohar Babu
*
* Date   : 26 Sept 2000
*
*****************************************************************************/

#include <stdio.h>
#include "port.h"

extern Result test_CPTdet(void);


/*****************************************************************************
*
* Module: main ()
*
* Description: This module calls the CPT test function
*
* Returns: None
*
* Arguments: None
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method:    tested through test_cpt.mcp
*
***************************** Change History ********************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    26/09/2000     0.0.1        Created          Manohar Babu
*    11/10/2000     1.0.0        Reviewed and     Manohar Babu
*                                Baselined
*
*****************************************************************************/

void main()
{

    Result  result;
    
    result = test_CPTdet();
    
    return ;

}
