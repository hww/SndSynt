;******************************** Module **********************************
;
;  Module Name     : tx_feed
;  Author          : Abhay Sharma, V.Shyam Sundar, Sanjay S. K.
;  Date of origin  : 17 Dec 95
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;*************************** Module Description ***************************
;
;  The modules in this file `feed' data to the modem either as an input
;  to be processed by scrambler/encoder or as an output (at tx_out).
;  The combination of these modules describe the various states in the
;  modem.
;  These modules form the task queue which is executed every baud.
;
;  Each feeder module ends with a jump to the next module in the task
;  queue of the particular state it is a part of.
;  
;************************** Calling Requirements **************************
;  
;  1. The flags flg_112 and flg_109 have to be appropriately set by the
;     receiver.
;
;  2. The state initialization have to be appropriately performed
;
;  3. A modulo buffer of length 24 should be initialized with 24 samples
;     of cos(2100Hz) at x:cos2100
;
;  4. A linear buffer of length 12 should be defined in the x memory at
;     x:tx_out
;
;  5. A memory location should be defined to hold tx_data (i/p to modem)
;   
;*************************** Input and Output *****************************
;
;  Input  :
;          None
;  Output :
;          Fill either x:tx_data or x:tx_out
;
;******************************* Resources ********************************
;
; Address Registers used: 
;                         r0 : Used to access cos2100 table in mod 24 addr-
;                              essing mode
;                         r1 : Points to the output buffer of length 12 in
;                              linear addressing mode.
;
; Offset Registers used : 
;                          n : used as an offset register
;
; Modifier Registers used : 
;                        m01 : To enable r0 to be used in circular address-
;                              ing mode
;
; Data Registers used   : a0  x0  
;                         a1           
;                         a2  
;
; Registers Changed     : a0  x0  r0  sr  pc  n  m01
;                         a1      r1      lc
;                         a2    
;
; Flags                 :
;                         *rx_st_chg, *flg_112, *flg_109, tx_ans_flg,
;                         tmp_flg
; Counters              :
;                         tx_ctr, tx_tmp
; Buffers               :
;                         TxQ(6L), StQ2(3L), tx_out(12L) 
; Pointers              :
;                         StQ_ptr(L), atone_ptr(C)
; Memory locations      :
;                         tx_tmp, tx_data
; Macros                :
;                         CALLING, datamd      
;
; ** Note :  In the ' Resources ' part of the template -
;            1. 'L' refers to Linear buffer/pointer to linear buffer
;            2. 'C' refers to Circular buffer/pointer to Circular buffer
;            3. '*' - memory location is any one of the first 64 locations
;
;************************** Environment ***********************************
;
;       Assembler : ASM56800 version 6.0.1.0
;       Machine   : IBM PC
;       OS        : MSDOS 6.0
;
;***************************** Pseudo Code ********************************
;
; Refer to the code section of this file for pseudo codes of individual
; modules
;
;**************************** Assembly Code *******************************

       include "gmdmequ.asm"

       SECTION V22B_TX 
 
       GLOBAL  dummy
       GLOBAL  ERROR
       GLOBAL  tx_sil
       GLOBAL  tx_wr4
       GLOBAL  tx_decide
       GLOBAL  tx_a_ton
       GLOBAL  tx_one_2
       GLOBAL  tx_one_4
       GLOBAL  tx_in_2
       GLOBAL  tx_in_4
       GLOBAL  tx_s1
       GLOBAL  tx_109
       GLOBAL  tx_112

	org     p:

;--------------------------------------------------------------------------
;  Input  :                               
;          None                           
;  Output :                               
;          x:tx_out[n] = 0                n = 0, 1, ..., 11
;
;  /*  A silence is effected by filling the output buffer with zero's     
;      (12 values/baud)  */
;--------------------------------------------------------------------------
tx_sil
	move    #tx_out,r1                ;Load address of output buffer
	move    #0,x0                     ;Push out 12 samles of zeros
	rep     #12                       
	move    x0,x:(r1)+                
end_tx_sil
	jmp     next_task                 ;Go to next task

;--------------------------------------------------------------------------
;  Input  :                               
;          none                           
;  Output :                               
;          x:tx_out[n] = x:cos2100[m]       n = 0, 1, ..., 11
;                                           m = 0, 1, ..., 11 or
;                                               12, 13, ..., 23
;  X memory used : 
;          atone_ptr - pointer to the table cos2100, a modulo buffer
;                      of length 24
;          tx_tmp    - a scratch memory location x:tx_tmp
;
;  /* cos2100 is a modulo table of 24 values. Values are fetched sequentia-
;     lly(12 values/baud). A phase reversal is effected after every 450 ms 
;     by skipping 12 values (modulo) of the table */
;--------------------------------------------------------------------------
tx_a_ton
	move    #23,m01                   ;To access cos2100Hz table
	move    x:atone_ptr,r0            ;Load answering tone pointer
	decw    x:tx_tmp                  ;Count down for 450 ms.
	bne     _transmit                 ;No phase change if timer not 0
	move    #271,x0
	move    #12,n                     ;Set offset register
	move    x0,x:tx_tmp               ;Reset tmp counter value to 
                                      ;  count down 450 ms.
	lea     (r0)+n                    ;Set address pointer to the
_transmit                                 ;
	move    #tx_out,r1                ;Load address of output buffer

	do      #12,up_txout              ;Update tx_out with the tone
	move    x:(r0)+,x0                ;  values obtained from the 
	move    x0,x:(r1)+                ;  table.
up_txout

	move    #$ffff,m01                ;r0 in linear addr. mode
	move    r0,x:atone_ptr            ;Save value of pointer to
                                      ;  answering tone table.
end_tx_a_ton
 	jmp     next_task                 ;jump to next task

;--------------------------------------------------------------------------
;  Input  :                               
;          none                           
;  Output :                               
;          rx_st_chg = 1  (flag)   after 8 ms
;                    = 0           before
;
;          tx_tmp    - a scratch memory location x:tx_tmp
;
;  /* The temporary counter counts down 8 ms. When the timer expires tx_wr4 
;     is turned on. After 8 ms this module becomes dormant. */
;--------------------------------------------------------------------------
tx_wr4
	decw    x:tx_tmp                  ;Countdown for 8 ms
	bne     end_tx_wr4                ;No operation if tmp counter has
    nop	                              ;  expired
    tstw    x:loopback
    bne     end_tx_wr4
    move    #$1,x:rx_st_chg           ;Set flag value
end_tx_wr4
	jmp     next_task                 ;jump to next task

;--------------------------------------------------------------------------
;  Input  :                               
;          none                           
;  Output :                               
;          tx_data = | 0000 0000 0000 0011 |
;
;  /* This module fills tx_data with ones for 2 bit   */
;  /* encoding (for 1200 bps transmission)            */
;--------------------------------------------------------------------------
tx_one_2
	move    #3,x0
	move    x0,x:tx_data              ;Push | 0000 0000 0000 0011 | 
end_tx_one_2
	jmp     next_task

;--------------------------------------------------------------------------
;  Input  :                               
;          none                           
;  Output :                               
;          tx_data = | 0000 0000 0000 0000 | or
;                    | 0000 0000 0000 0011 |
;  X memory used : 
;          tx_tmp - a scratch memory location used for storing S1 signal
;
;  /* This module fills up tx_data alternatively with */
;  /* 0s and 1s every baud for 2 bit encoding         */
;  /* (for transmission at 1200 bps)                  */
;--------------------------------------------------------------------------
tx_s1
	move    x:tx_tmp,x0               ;Get pattern to be transmitted
	move    x0,x:tx_data              ;Push S1 out
	bfchg   #$0003,x0                 ;invert the pattern
	move    x0,x:tx_tmp               ;Save pattern to be sent in the
                                      ;  next baud
end_tx_s1
	jmp     next_task                 ;Jump to next task

;--------------------------------------------------------------------------
;  Input  :                               
;          flag_112 = | s000 0000 0000 0000 | in x:flg_112
;          flag_109 = | s000 0000 0000 0000 | in x:flg_109
;  Output :
;          Change the pointer to the state initialization queue to set
;          operation to either V.22 mode or V.22 bis mode.
;
;  Note : 
;         tmp_flg is a scratch flag denoting whether a section of this
;         module has been executed or not
;--------------------------------------------------------------------------
tx_decide
	move    x:tx_ans_flg,x0
	bftstl  #CABIT,x0                 ;Check for calling mode
	bcc     end_tx_decide             ;Skip calling mode init. if in
                                      ;  answering mode
	move    x:flg_109,x0              ;Get 109 from memory
	move    x:tmp_flg,a
	and     x0,a                      ;Check if 109 set and detected
	bne     end_tx_decide             ;If so skip module
	tstw    x:flg_109                 ;Check for v22 mode in the remote
                                      ;  end
	beq     tx_112                    ;If not set check for 112
tx_109  

	move    #StQ1_5,x0                ;Load address of next state
	move    x0,x:StQ_ptr              ;  init. module on to stack
                                      ;  (down to v22 mode calling 
                                      ;  modem)
	move    #459,x0
	move    x0,x:tx_ctr               ;Set time of state to 765 ms
	move    #$8000,x0
	move    x0,x:tmp_flg              ;Set detected flag on
	bra     end_tx_decide             ;skip module
tx_112        
	move    x:flg_112,x0              ;Get flag 112 from memory
	move    x:tmp_flg,a
	and     x0,a                      ;Check for v22 bis mode
	bne     end_tx_decide             ;
	tstw    x:flg_112
	beq     end_tx_decide
	move    #360,x0
	move    x0,x:tx_ctr               ;Set time of execution of state
                                      ;  to 600 ms
	move    #$8000,x0
	move    x0,x:tmp_flg              ;Set detected flag on
end_tx_decide        
	jmp     next_task                 ;Jump to next task

;--------------------------------------------------------------------------
;  Input  :                               
;          none                           
;  Output :                               
;          tx_data = | 0000 0000 0000 1111 |
;
;  /* This module fills tx_data with ones for 4 bit   */
;  /* encoding (for 2400 bps transmission)            */
;--------------------------------------------------------------------------
tx_one_4
	move    #$000f,x0
	move    x0,x:tx_data              ;Push | 0000 0000 0000 1111 |
end_tx_one_4
	jmp     next_task                 ;Jump to next task
	

;--------------------------------------------------------------------------
;  Input  :                               
;          none                           
;  Output :                               
;          none
;
;  /* This is a dummy task                            */
;--------------------------------------------------------------------------
dummy
	jmp     next_task
end_dummy

;--------------------------------------------------------------------------
;  Input  :                               
;          none                           
;  Output :                               
;          tx_data   = | 0000 0000 0000 00bb |
;                                       b = 0 or 1
;
;  /* This module fills input data on to tx_data      */
;  /* for 2 bit encoding (for 1200 bps transmission)  */
;--------------------------------------------------------------------------
tx_in_2
end_tx_in_2
	jmp     next_task

;--------------------------------------------------------------------------
;  Input  :                               
;          none                           
;  Output :                               
;          tx_data   = | 0000 0000 0000 bbbb |
;                                       b = 0 or 1
;
;  /* This module fills input data on to tx_data      */
;  /* for 4 bit encoding (for 2400 bps transmission)  */
;--------------------------------------------------------------------------
tx_in_4
end_tx_in_4
	jmp     next_task

;--------------------------------------------------------------------------
;  Input  :                               
;          none                           
;  Output :                               
;          Error routine is executed
;
;  /* This is an error service routine which executes */
;  /* on an exception                                 */
;--------------------------------------------------------------------------
ERROR
	bfset   #TXERR,x:MDMSTATUS
    rts
end_ERROR

;**************************** Module Ends *********************************

    ENDSEC
