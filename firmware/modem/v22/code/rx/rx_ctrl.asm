
;******************************** Module **********************************
;
;  Module Name     : rx_ctrl
;  Author          : Varadarajan G
;  Date of origin  : 04 Feb 96
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;*************************** Module Description ***************************
;
;  This module is executed every baud. This module performs the following
;  actions.
;  1. Monitors  state change flag.
;  2. Calls appropriate rx_state module for state initialisation.
;  3. Performs RxQ.
;  4. On error detection it exits to error handler.
;
;************************** Calling Requirements **************************
;
;  1. rx_st_chg flag must be set to one when this module is called for 
;     the first time.
;
;*************************** Input and Output *****************************
;
;  Input   :  None
;  Output  :  None
;
;******************************* Resources ********************************
;
;                        Cycle Count   :  
;                                        
;                        Program Words : 16
;                        NLOAC         : 17
;                                          
; Address Registers used: 
;                         r3 : to point to the State init. queue StQ,
;                              also points to task queue
;
; Offset Registers used : 
;                          none
;
; Data Registers used   :     x0, y0
;
; Registers Changed     :     x0, y0, r3, sp  
;
;***************************** Pseudo Code ********************************
;      
;
;    Begin
;
;
;      If (rx_st_chg == 1)                     
;          perform state initialization        
;          reset rx_st_chg flag to zero             
;      Endif
;
;      perform RxQ                         
;
;************************** Environment ***********************************
;
;       Assembler : ASM56800 version 6.0.0.0
;       Machine   : HP Xterm
;       OS        : Sun OS 
;
;**************************** Assembly Code *******************************

      SECTION V22B_RX 

      GLOBAL RXBAUDPROC
      GLOBAL rx_no_sti
      GLOBAL rx_next_task

      org p:

RXBAUDPROC
        	
;-----------------------------------------;
; If (tx_st_chg == 1)                     ;
;     perform state initialization        ;
;     reset tx_st_chg to zero             ;
;-----------------------------------------;
	tstw    x:rx_st_chg               ;Check the state change flag
	beq     rx_no_sti                 ;Branch on no state change ,
	jsr     perf_sti_rx               ;Perform state initialization
;*****************************************

    move    #0,x:rx_st_chg            ;Reset the state change flag

rx_no_sti        
    nop

;-----------------------------------------;
;     perform RxQ                         ;
;-----------------------------------------;
perform_RxQ
	move    #RXQ,r3                   ;Load the starting address of 
                                      ;  RxQ 
	move    r3,x:RxQ_ptr              ;Store the present RxQ pointer 
                                      ;  in memory location
rx_next_task
	lea     (sp)+
	move    x:RxQ_ptr,r3              ;Restore the RxQ pointer
	incw    x:RxQ_ptr                 ;Increament the RxQ_ptr. 
	move    x:(r3),x0                 ;Get the address of next task 
	move    x0,x:(sp)+                ;Push the address of task to be
	move    sr,x:(sp)                 ;  performed onto the stack
	rts                               ;Perform task

;-----------------------------------------;
;     perform State Initialisation        ;
;-----------------------------------------;

perf_sti_rx   
        move    x:Rx_StQ_ptr,r3           ;Get state queue pointer
        lea     (sp)+                     ;Advance stack pointer position
        incw    x:Rx_StQ_ptr              ;Advance state queue pointer
        move    x:(r3),y0                 ;Get addr. of state init. module
        move    y0,x:(sp)+                ;Push address of the state init.
                                          ;  module
        move    sr,x:(sp)                 ;
        rts                               ;Perform State initialization
_End_perf_sti

;****************************** End of File *******************************

       ENDSEC

