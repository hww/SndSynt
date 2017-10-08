;**************************************************************************                                   
;                                                                        
;  (C) 2000 MOTOROLA, INC. All Right Reserved                            
;                                                                        
;**************************************************************************

;****************************** Function **********************************
;  
;  Function Name  : TD_FUNC
;  Project ID     : G165EC
;  Author         : Qiu Lunji
;  Modified by    : Sandeep Sehgal
;
;*************************** Reversion History ****************************
;
;  DD/MM/YY     Code Ver        Description             Author
;  --------     --------        -----------             ------
;  5/11/97      0.0.1           Macro Created           Qiu Lunji
;  19/11/97     1.0.0           Reviewed and Modified   Qiu Lunji
;  10/07/00     1.0.1           Converted macros to     Sandeep Sehgal
;                               functions    
;
;*************************** Function Description *************************
;
;  Contains all the subrountines for the Tone Detector:
;       TD_INIT_subroutine
;       TD_MASTER_RCV_subroutine
;       TD_MASTER_SND_subroutine
;  Symbols Used :
;  
;  Functions Called :
;       TD_INIT           : Initialize variables for Tone Detector
;       TD_MAST1          : Tone detection for receive channel
;       TD_MAST2          : Tone detection for send channel
;  Note : The constant and variable declarations for this module are defined
;         in file td_data.asm
;
;**************************** Function Arguments **************************
;
;  None
;
;************************* Calling Requirements ***************************
;
;  1. At least 2 locations should be available in the software stack: 
;       Subroutine                      Stacks Required
;       ----------                      ---------------
;       TD_MASTER_RCV_subroutine                2                           
;       TD_MASTER_SND_subroutine                2                           
;       TD_INIT_subroutine                      2
;  2. TD_CONST_INT_XRAM must be defined in the calling module or during
;     compilation
;
;************************** Input and Output ******************************
;
;  None
;
;*************************** Globals and Statics **************************
;
;  Globals  :
;       TD_INIT_subroutine        = | iiii iiii | iiii iiii |
;       TD_MASTER_RCV_subroutine  = | iiii iiii | iiii iiii | 
;       TD_MASTER_SND_subroutine  = | iiii iiii | iiii iiii |
;
;  Statics :
;       None
;
;****************************** Resources *********************************
;
;               Icycle Count  : 	  
;				     	   21
;		TD_INIT_subroutine      : 181
;		TD_MASTER_RCV_subroutine: 428 for TD_CONSTANT_INIT_XRAM = 1
;					  436 for TD_CONSTANT_INIT_XRAM = 0
;		TD_MASTER_SND_subroutine: 428
;		Tatal			:1058 for TD_CONSTANT_INIT_XRAM = 1
;					 1066 for TD_CONSTANT_INIT_XRAM = 0
;
;               Program Words : 		    
;					    9
;		TD_INIT_subroutine	: 163
;		TD_MASTER_RCV_subroutine: 426 for TD_CONSTANT_INIT_XRAM = 1
;					  430 for TD_CONSTANT_INIT_XRAM = 0
;		TD_MASTER_SND_subroutine: 426 for TD_CONSTANT_INIT_XRAM = 1
;					  430 for TD_CONSTANT_INIT_XRAM = 0
;		Tatal			:1024 for TD_CONSTANT_INIT_XRAM = 1
;					 1028 for TD_CONSTANT_INIT_XRAM = 0
;
;               NLOAC          		: 38
;
;  Address Registers used:
;                        r0 : used in TD_MAST1 and TD_MAST2 modules in 
;                             circular addressing modes
;                        r1 : used in TD_MAST1 and TD_MAST2 modules 
;                             in both circular and linear addressing modes
;                        r3 : used in TD_MAST1 and TD_MAST2 modules in 
;                             circular addressing modes
;
;  Offset Registers used:
;                        n  : used in TD_MAST1 and TD_MAST2 modules
;
;  Data Registers used:
;                        a0  b0  x0  y0
;                        a1  b1      y1
;                        a2  b2
;
;  Registers Changed:
;                        r0  m01  n  a0  b0  x0  y0  sr
;                        r1          a1  b1      y1  pc
;                        r3          a2  b2
;
;***************************** Pseudo Code ********************************
;
;       Begin
;       Define  TD_MASTER_RCV_subroutine
;       Define  TD_MASTER_SND_subroutine    
;       Define  TD_INIT_subroutine    
;       End
;  
;**************************** Assembly Code *******************************
        
      
        SECTION TD_RCV_CODE 
        
        GLOBAL  TD_MASTER_RCV_subroutine

        org     p:                        ;Start address of Module
        
TD_MASTER_RCV_subroutine        
        jsr     TD_MASTER_RCV                     ;Tone detect on RCV chn
        rts
        
        ENDSEC
        
        SECTION TD_SND_CODE 
        
        GLOBAL  TD_MASTER_SND_subroutine

        org     p:                               ;Start address of Module
        
TD_MASTER_SND_subroutine        
        jsr     TD_MASTER_SND                     ;Tone detect on SND chn
        rts
        
        ENDSEC

        SECTION TD_INIT_CODE  
              
        GLOBAL  TD_INIT_subroutine
        GLOBAL  FTD_INIT_subroutine

        org     p:
        
FTD_INIT_subroutine        
TD_INIT_subroutine   
   
        jsr     TD_INIT                           ;Function which initialise 
        rts                                       ;  Tone detector 
        
        ENDSEC
             
;**************************** End of File *********************************
