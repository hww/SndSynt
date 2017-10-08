;/*****************************************************************************
;*
;* Motorola Inc.
;* (c) Copyright 2000 Motorola, Inc.
;* ALL RIGHTS RESERVED.
;*
;******************************************************************************
;*
;****************************************************************************
;*
;* Module: callerIDGetSetConditionCode ()
;*
;* Description: The callerIDGetSetConditionCode gets the condition code
;*              and sets it.
;*
;* Returns: Previous Condition code
;*
;* Arguments: Condition code
;*
;* Range Issues: None
;*
;* Special Issues: None.
;*
;* Test Method: caller_id_test.mcp for testing
;*
;**************************** Change History ********************************
;* 
;*    DD/MM/YYYY     Code Ver     Description      Author
;*    ----------     --------     -----------      ------
;*    11/05/2000     0.0.1        Created          Meera S. P.
;*    19/05/2000     1.0.0        Reviewed and     Meera S. P.
;*                                Baselined
;*    23/03/2001		             Fixed brclr instruction bug for CW 4.0
;****************************************************************************/

        SECTION rtlib

        global  FcallerIDGetSetConditionCode
	
	     org     p:



;asm bool callerIDGetSetConditionCode (bool C_Code)
;{
;
FcallerIDGetSetConditionCode:
   move  #0,X0
 ;  brclr #0x100,OMR,CC_Clear
   bftstl #$0100,OMR
   bcs CC_Clear
   move  #1,X0
CC_Clear:

	cmp   #0,Y0
	beq   CC_Off
	bfset #$100,OMR
	move  X0,Y0
	rts
CC_Off:
	bfclr #$100,OMR
	move  X0,Y0
	rts

    ENDSEC

