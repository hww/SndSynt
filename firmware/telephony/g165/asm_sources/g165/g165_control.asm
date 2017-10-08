;**************************************************************************
;
;  (c) 2000 MOTOROLA, INC. All Rights Reserved 
;
;**************************************************************************

;****************************** Function **********************************
;
;  Project ID     : G165EC  
;  Function Name  : G165_CONTROL
;  Author         : Sandeep Sehgal
;
;*************************** Revision History *****************************
;
;  DD/MM/YY    Code Ver     Description                Author
;  --------    --------     -----------                ------
;  01/10/97    0.0.1        Macro created              Quay Cindy
;  18/11/97    1.0.0        Modified per review        Quay Cindy
;                           comments
;  10/07/00    1.0.1        Converted macros to        Sandeep Sehgal
;                           function
;
;*************************** Function Description **************************
;
;  This function alters the program flow, if any of the following flags are 
;  set
;
;  Symbols Used :
;       inhibit_converge      : Inhibits convergence
;       reset_coef            : Resets the filter coeffs
;
;  Functions called
;       None
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. The functions EC_INIT  HRL_INIT and TD_INIT should be called before  
;     the first call of this function
;
;************************** Input and Output ******************************
;
;  Input  : 
;       None
;
;  Output : 
;       None
;
;
;************************ Globals and Statics *****************************
;
;  Globals  :
;
;       inhibit_converge  = | 0000 0000  | 0000 000i |
;
;       reset_coef        = | 0000 0000  | 0000 000i |
;
;
;  Statics :
;       None 
;
;**************************** Assembly Code *******************************

	SECTION G165_CODE


    GLOBAL      FG165_CONTROL
    
    org p:
    
FG165_CONTROL

    brclr  #$0002,y0,chk_for_rst_coeff
    move   #1,x:inhibit_converge
    rts
chk_for_rst_coeff

    brclr  #$0004,y0,chk_for_enb_coeff
    move   #1,x:reset_coef
    rts
chk_for_enb_coeff

    brclr  #$0008,y0,exit_control
    move   #0,x:inhibit_converge

exit_control
    rts   
    
    ENDSEC