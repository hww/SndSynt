;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL).
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : v21_rxsm.asm
;
; PROGRAMMER           : Varadarajan G
;
; DATE CREATED         : 01-Jun-1998
; 
; FILE DESCRIPTION     : Receiver State Machine
; 
;
; FUNCTIONS            : V21_Rxctrl, V21_Rx_Nxt_Tsk, V21_Rx_Stinit
;
; MACROS               : None
;
;************************************************************************
        

        SECTION V21_Rxsm

        GLOBAL  FV21_Rxctrl
        GLOBAL  V21_Rx_Nxt_Tsk

              
;****************************** Module ************************************
;
;  Module Name    : V21_Rxctrl
;  Author         : Varadarajan G
;
;************************** Module Description ****************************
;
;  This module executes the functions in the task queue in that order
;  for a given state. If a state change was requested, will perform the
;  initializations for the new state and will execute the task queue
;  corresponding to the new state
;
;  Calls :
;        Modules : V21_Rx_Stinit and some of the following functions
;                  v21_rxdem, v21_rxcd, v21_rxtimejam, v21_rxtimrec, 
;                  v21_rxcdwait, v21_rxagc, v21_rxfirstzc, v21_rxdata.
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
;  01 Jun 98   Varadarajan G       First Version
;  03/07/2000  N R Prasad          Ported on to Metrowerks.
;
;************************* Calling Requirements ***************************
;
;  1. Initialize SP.
;
;  2. v21_rxstchg should be set to 1 when this module is called for the
;     first time, also v21_rxsti_ptr should be initialised.
;
;************************** Input and Output ******************************
;
;  Input  :
;        state chg req.= | 0000 0000 | 0000 000i | in x:v21_rxstchg
;        
;
;  Output :
;        None
; (for non 1.15 format, fill the format field)
;****************************** Resources *********************************
;
;  Registers Used:       r3, x0, sr
;
;  Registers Changed:    r3, x0, sr
;                        
;  Number of locations 
;    of stack used:      2 (Max at any time)
;
;  Number of DO Loops:   None
;
;**************************** Assembly Code *******************************

        ORG     p:

FV21_Rxctrl
                
;-----------------------------------------;
; If (v21_rxstchg == 1)                   ;
;     perform state initialization        ;
;     reset v21_rxstchg to zero           ;
;-----------------------------------------;
        tstw    x:v21_rxstchg             ;Check the state change flag
        beq     _v21_rx_nosti             ;Branch on no state change ,
        jsr     V21_Rx_Stinit             ;Perform state initialization
        move    #0,x:v21_rxstchg          ;Reset the state change flag
_v21_rx_nosti        
;-----------------------------------------;
;     perform RxQ                         ;
;-----------------------------------------;
_perform_rxq
        move    #v21_rxq,x:v21_rxq_ptr    ;v21_rxq_ptr points to the first
                                          ;  Function in the v21_rxq
V21_Rx_Nxt_Tsk
        lea     (sp)+
        move    x:v21_rxq_ptr,r3          ;Restore the RxQ pointer
        incw    x:v21_rxq_ptr             ;Increament the RxQ_ptr. 
        move    x:(r3),x0                 ;Get the address of next task 
        move    x0,x:(sp)+                ;Push the address of task to be
        move    sr,x:(sp)                 ;  performed onto the stack
        rts                               ;Perform task



;****************************** Module ************************************
;
;  Module Name    : V21_Rx_Stinit
;  Author         : Varadarajan G
;
;************************** Module Description ****************************
;
;     Perform State Initialisation. Before entering a state, this function
;     is called to initialise the state specific parameters. The state 
;     initialisation is done through calling the right function pointed
;     by v21_rxsti_ptr
;
;  Calls :
;        Modules : v21_rxcdw_init, v21_rxagc_init, v21_rxfzc_init,
;                  v21_rxdat_init
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
; 02 Jun 98     Varadarajan        First Version (Reuse from V22bis)
; 03/07/2000    N R Prasad         Ported on to Metrowerks.
;
;************************* Calling Requirements ***************************
;
;  1. Initialize SP.
;
;  2. v21_rxsti_ptr should be initialized
;
;************************** Input and Output ******************************
;
;  Input  :
;        state init pointer in x:v21_rxsti_ptr
;        
;
;  Output :
;        None
; (for non 1.15 format, fill the format field)
;****************************** Resources *********************************
;
;  Registers Used:       r3, sp
;
;  Registers Changed:    r3, sp
;                        
;  Number of locations 
;    of stack used:      2
;
;  Number of DO Loops:   None              
;
;**************************** Assembly Code *******************************

V21_Rx_Stinit   
        move    x:v21_rxsti_ptr,r3        ;Get state queue init pointer
        lea     (sp)+                     ;Advance stack pointer position
        move    r3,x:(sp)+                ;Push address of the state init.
                                          ;  module
        move    sr,x:(sp)                 ;
End_v21_rx_stinit
        rts                               ;Perform State initialization


        ENDSEC

;****************************** End of File *******************************
