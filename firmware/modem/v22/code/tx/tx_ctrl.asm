;******************************** Module **********************************
;
;  Module Name     : tx_ctrl
;  Author          : Abhay Sharma, V.Shyam Sundar, Sanjay S. K.
;  Date of origin  : 17 Dec 95
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;*************************** Module Description ***************************
;
;  This module is executed every baud. This module performs the following
;  actions.
;  1. Monitors the retrain and state change flags.
;  2. Calls appropriate tx_state module for state initialisation.
;  3. Performs TxQ.
;  4. On error detection it exits to error handler.
;  5. If retraining required, it exits to retrain handler.
;
;************************** Calling Requirements **************************
;
;  The tx_st_chg flag should be set to 1 before calling this routine for
;  the first time. 
;
;*************************** Input and Output *****************************
;
;  Input   :  None
;  Output  :  None
;
;******************************* Resources ********************************
;
;                        Cycle Count   :  
;                        Program Words :  91
;                        NLOAC         :  79
;                                          
; Address Registers used: 
;                         r3 : to point to the State init. queue StQ
;                              also points to task queue
;
; Offset Registers used : 
;                          none
;
; Data Registers used   : a0  x0  y0
;                         a1
;                         a2
;
; Registers Changed     : a0  x0  y0  r3  sr  pc  sp
;                         a1
;                         a2
;
;***************************** Pseudo Code ********************************
;      
;    Repeat every baud
;    Begin
;
;      If (retrn_flg == 1)                     
;          Execute retrain module as a subroutine  
;      Endif                                   /* Pseudo code for retrain
;                                                 is explained in retrain
;                                                 module */
;
;      If (tx_st_chg == 1)                     
;          perform state initialization        
;          reset tx_st_chg flag to zero             
;      Endif
;
;      If (tx_ctr < 0)                         /* Event terminated */
;          perform TxQ                         
;          decrement tx_ctr                    
;          if (tx_ctr <= rx_timeout)           /* rx_timeout is a negative 
;              exit to error handler              value */
;          Endif
;      Endif
;
;      If (tx_ctr >= 0)                        /* Time terminated */
;          perform TxQ                         
;          decrement tx_ctr                    
;          if (tx_ctr = 0 )                    
;              tx_st_chg = 1                   
;          Endif
;      Endif
;
;    End
;
;************************** Environment ***********************************
;
;       Assembler : ASM56800 version 6.0.1.0
;       Machine   : IBM PC
;       OS        : MSDOS 6.0
;
;**************************** Assembly Code *******************************

        include "gmdmequ.asm"
        include "txmdmequ.asm"

        SECTION V22B_TX 


        GLOBAL TXBAUD
        GLOBAL Chk_St_Chg
        GLOBAL next_task
        GLOBAL RETRAIN
        GLOBAL perf_sti_tx

        org     p:
TXBAUD                                    ;Repeat every baud
        bftsth  #retrn,x:mode_flg         ;Check if retrain reqd
        jcc     Chk_St_Chg
        jsr     RETRAIN                   ;Execute retrain module
        
;-----------------------------------------;
; If (tx_st_chg == 1)                     ;
;     perform state initialization        ;
;     reset tx_st_chg to zero             ;
;-----------------------------------------;
Chk_St_Chg
        tstw    x:tx_st_chg               ;Check the state change flag
        beq     tx_no_sti                 ;Branch on no state change ,
        jsr     perf_sti_tx               ;Perform state initialization
;*****************************************

;*****************************************
        move    #0,x:tx_st_chg
tx_no_sti        

;-----------------------------------------;
; If (tx_ctr < 0)                         ;Event terminated
;     perform TxQ                         ;
;     decrement tx_ctr                    ;
;     if (tx_ctr <= rx_timeout)           ;rx_timeout is a negative value
;         exit to error handler           ;
;-----------------------------------------;
        jsr     perform_TxQ               ;Perform TxQ
        bftsth  #datamd,x:mode_flg

        jcs     end_ctrl_loop

        tstw    x:tx_ctr                  ;Check the time elapsed

        bge     time_terminated           ;If time elapsed is positive
                                          ;  execute`time terminated event'
                                          ;  routine
        decw    x:tx_ctr                  ;Decrement the time count
                                          ;  (This value is negative)
        move    x:tx_ctr,a
        move    #rx_timeout,y0
        cmp     y0,a
                                          ;  timeout value
        jle     ERROR                     ;On timeout exit to error handler
     
        rts
     

;-----------------------------------------;
; If (tx_ctr >= 0)                        ;Time terminated
;     perform TxQ                         ;
;     decrement tx_ctr                    ;
;     if (tx_ctr = 0 )                    ;
;         tx_st_chg = 1                   ;
;-----------------------------------------;

time_terminated

        clr     a                         ;Set default tx_st_chg = 0
        decw    x:tx_ctr                  ;Decrement the time counter
        move    #1,x0                     ; 
        teq     x0,a                      ;If the time counter has expired
                                          ;  set tx_st_chg = 1
        move    a,x:tx_st_chg             ;Save tx_st_chg

end_ctrl_loop                             ;End of control loop
        rts

;-----------------------------------------;
; Control routine perform_TxQ             ;
;-----------------------------------------;
perform_TxQ
        move    #TxQ,r3                   ;Load the starting address of 
                                          ;  TxQ 
        move    r3,x:TxQ_ptr              ;Store the present TxQ pointer 
                                          ;  in memory location
next_task
        lea     (sp)+
        move    x:TxQ_ptr,r3              ;Restore the TxQ pointer
        incw    x:TxQ_ptr                 ;Increament the TxQ_ptr. 
        move    x:(r3),x0                 ;Get the address of next task 
        move    x0,x:(sp)+                ;Push the address of task to be
        move    sr,x:(sp)                 ;  performed onto the stack
        rts                               ;Perform task

;-----------------------------------------;
; Initialization routine RETRAIN          ;
;-----------------------------------------;
RETRAIN
        move    #0,x:tmp_flg              ;Used in tx_decide module 
        
        move    #1,x:Sync_sent_status     ;;;;;Sanjay
        bfclr   #DABIT,x:MDMSTATUS        ;;;;;Sanjay
        move    #1,x:retrain_flag         ;;;;;Sanjay

        move    #TxQ_3,r3                 ;Initialise the task queue
        move    #tx_enc_2,x0
        move    x0,x:(r3)
        move    #hndshk,x0
        move    x0,x:mode_flg             ;Set mode_flg to handshake mode

        move    #StQ1_4,x0                 

        move    x0,x:StQ_ptr              ;Set state initialisation pointer
                                          ;  to tx_I5
                                          ;Set flags for calling mode
        move    #0,x:flg_106              ;  handshake
        move    #0,x:flg_112
        move    #0,x:flg_109
        move    #1,x:flg_104
        move    #-1,x:txI62ctr


        move    #CALLING,x:tx_ans_flg     ;Set flag for calling mode
        move    #CALLING,x:rx_ans_flg     ;Set flag for calling mode
        tstw    x:loopback
        beq     _noloopback1
        bftsth  #RREQ,x:MDMSTATUS         ;Setting for loopback test
        bra     _check1 
_noloopback1      
        bftsth  #LREQ,x:MDMSTATUS
_check1      
        bcs     _self_trig
        tstw    x:loopback
        beq     _noloopback2      
        bftsth  #LREQ,x:MDMSTATUS         ;Setting for loopback test
        bra     _check2 
_noloopback2      
        bftsth  #RREQ,x:MDMSTATUS
_check2
        jcc     ERROR
       
_rem_trig
      
        tstw    x:loopback
        beq     _noloopback3      
        bfclr   #LREQ,x:MDMSTATUS         ; Setting for loopback test
        bra     _check3
_noloopback3      
        bfclr   #RREQ,x:MDMSTATUS
_check3      
        move    #ANSWERING,x:tx_ans_flg   ;Set flag for answering mode
        move    #ANSWERING,x:rx_ans_flg   ;Set flag for answering mode
                                          ;  handshake for remote triggered
                                          ;  retrain
        move    #$8000,x:flg_112          ;To ensure handshake of V22bis
                                          ;  answering modem
        move    #300,x:txI62ctr
        bra     end_RETRAIN
_self_trig
      
        tstw    x:loopback
        beq     _noloopback4      
        bfclr   #RREQ,x:MDMSTATUS         ;Setting for loopback test
        bra     _check4
_noloopback4        
        bfclr   #LREQ,x:MDMSTATUS       
_check4      
        move    #1,x:tx_st_chg            ;Transmitter state change
                                          ;  should occur only for self 
                                          ;  triggered and receiver should
                                          ;  change state only after receiv
                                          ;  -ing S1 completely
end_RETRAIN
        rti                               ;Return to test routine 

;-----------------------------------------;
; Stata Initialization routine perf_sti   ;
;-----------------------------------------;
perf_sti_tx
        move    x:StQ_ptr,r3              ;Get state queue pointer
        lea     (sp)+                     ;Advance stack pointer position
        incw    x:StQ_ptr                 ;Advance state queue pointer
        move    x:(r3),y0                 ;Get addr. of state init. module
        move    y0,x:(sp)+                ;Push address of the state init.
                                          ;  module
        move    sr,x:(sp)                 ;
        rts                               ;Perform State initialization

;**************************** Module Ends *********************************
        ENDSEC
