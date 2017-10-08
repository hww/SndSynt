;******************************** Module **********************************
;
;  Module Name     : rx_bchk
;  Author          : Varadarajan G, Sanjay S.K
;  Date of origin  : 
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;*************************** Module Description ***************************
;
;  This file consists of modules which will be executed at the end of the
;  RXQ just before ENDRX. The module to be executed is chosen by the init.
;  modules in rx_stat.asm based on the state of the handshake.
;
;  The chosen module does one or more of the following functions
;
;  1. Checks various counters like TON2100,TONS1,TON150
;  2. Check Flags, like flg_109, mode_flg 
;  3. Checks the state timing counter rx_ctr and err_ctr
;  4. Checks the timeout counter to report error if the counter expires
;  5. Depending on the above checks it sets the state change flag
;
;  
;************************** Calling Requirements **************************
;  
;  Note : This module should be the last to be executed (just before
;         ENDRX ) in the task queue RXQ
;   
;*************************** Input and Output *****************************
; 
;  *** See the on line comments
;
;******************************* Resources ********************************
;
;
;                         NLOAC         :  147
;
;  Address Registers used : 
;                          r1  : to point to TxQ   
;  Modifier register used :
;                          None
;  Offset Registers used  : 
;                          None
;  Data Registers used    : 
;                          x0  
;  Registers Changed      : 
;                          x0  r1  sr  pc  
;  Flags                  :
;                          tx_st_id, tx_ans_flg, *flg_107, *flg_112, 
;                          *flg_104, *flg_106, *flg_109, *mode_flg
;                    
;
;***************************** Pseudo Code ********************************
;
; tx_In, n = 1,2, ..., 5,6_1,6_2,7_2,8_2 are the state initialisations
; of the nth state and is invoked in the control module tx_ctrl as a 
; subroutine.
; Refer to the online comments for further details of the state initialis-
; ations.
;
;************************** Environment ***********************************
;
;       Assembler : ASM56800 version 6.0.1.0
;       Machine   : IBM PC
;       OS        : MSDOS 6.0
;
;**************************** Assembly Code *******************************

       include "rxmdmequ.asm"
       include "gmdmequ.asm"

       SECTION V22B_RX

       GLOBAL   RX_wait
       GLOBAL   RX_cd
       GLOBAL   RX_atusb1
       GLOBAL   RX_usb1
       GLOBAL   RX_endusb1
       GLOBAL   RX_s1call
       GLOBAL   RX_cdrop
       GLOBAL   RX_signal
       GLOBAL   RX_carrierup
       GLOBAL   RX_s1ans
       GLOBAL   RX_scr12
       GLOBAL   RX_v22dm
       GLOBAL   RX_s1end
       GLOBAL   RX_wait32bit
       GLOBAL   RX_waitdm
       GLOBAL   RX_wait1sec
       GLOBAL   RX_v22bisdm
       GLOBAL   RXDM_bis
       GLOBAL   RX_retrain
       GLOBAL   RX_RETR_REP
       GLOBAL   RX_RETR_A
       GLOBAL   RX_NEXT
       GLOBAL   ENDRX
       GLOBAL   error
       GLOBAL   RX_Rmt_Ret
       GLOBAL   RXDM_CD
       GLOBAL   RXDMCDON
       GLOBAL   RXDMCDOFF
       GLOBAL   RXDM_OFF
       GLOBAL   CDONOF

        org p:
	
;--------------------------------------------------------------------------
;  Input  :                               
;          Count in rx_ctr                           
;  Output :                               
;          rx_st_chg = | 0000 0000 0000 000x |
;                      /*  x = 0, if rx_ctr == 0 else x = 1  */
;
;  /* This module sets the state change flag when the count becomes zero 
;     if it is not negative */
;--------------------------------------------------------------------------
RX_wait
        move    x:rx_ctr,a
        tst     a
        blt     end_RX_wait
        decw    x:rx_ctr                 ;Wait for specified time, set
        bne     end_RX_wait              ;  the rx_st_chg flag upon count-
        move    #1,x:rx_st_chg           ;  er reset
end_RX_wait
        jmp     rx_next_task

;--------------------------------------------------------------------------
;  Input  :                               
;       1. Carrier Detect Flag | 0000 0000 | 0000 000x | in x:CD1
;       2. count in x:rx_ctr
;          
;  Output :                               
;       1. rx_st_chg = | 0000 0000 0000 000x |
;                      /*  x = 1, if carrier is continuously detected for 
;                                 25 msec  */
;       2. rx_ctr is assigned #rxCBctr if there is a carrier drop even for
;          one baud
;--------------------------------------------------------------------------
RX_cd
        tstw    x:CD1                     ;Detect carrir continuously for 
                                          ;  25 msec
        bne     cdet                     

        move    #rxCBctr,a
        move    a,x:rx_ctr              
        bra     end_RX_cd
cdet
        decw    x:rx_ctr
        bgt     end_RX_cd
        move    #1,x:rx_st_chg
end_RX_cd        
        jmp     rx_next_task

;--------------------------------------------------------------------------
;  Input  :                               
;       1. Count in TON2100 and TON150                           
;       2. timed event counter x:rx_ctr 
;       3. The time out counter x:rx_toutctr
;  Output :                               
;          rx_st_chg = | 0000 0000 0000 000x |
;                      /*  x = 0, if TON2100 < 0 or rx_ctr > 0  */
;
;  /* This module sets the state change flag, if 2100 Hz tone is detected
;     or Unscrambled Binary Ones are detected for 150 ms continuously 
;     If neither 2100Hz tone or the USB1 is not found for the given
;     time (when x:rx_toutctr expires) it jumps over to an error routine */
;--------------------------------------------------------------------------
RX_atusb1
        jsr     RXTON
        tstw    x:TON2100                 ;Check for 2100 Hz tone
        blt     RX_usb1
        move    #1,x:rx_st_chg            ;2100 Hz tone is detected
        bra     end_RX_atusb1
RX_usb1
        move    #1,b
        move    x:TON150,a                
        tst     a                         ;Check for un.scr. bin. one's
        ble     reset
        move    #$7000,x0                 ;Lower threshold
        cmp     x0,a
        bge     yes150
        neg     b
yes150
        move    x:rx_ctr,a
        sub     b,a

        bgt     continue
        move    #1,x:rx_st_chg            ;USB1 is detected for 150 ms

        move    #Rx_StQC,x0
        add     #4,x0
        move    x0,x:Rx_StQ_ptr
        bra     end_RX_atusb1

continue
        move    x:RXTH,x0                 ;Upper threshold
        cmp     x0,a
        ble     store 
reset
        move    x:RXTH,a

store
        move    a,x:rx_ctr
        decw    x:rx_toutctr
        jle     error
end_RX_atusb1
        jmp     rx_next_task

;--------------------------------------------------------------------------
;  Input  :                               
;          Count in TON150 and err_ctr                          
;  Output :                               
;          rx_st_chg = | 0000 0000 0000 000x |
;                      /*  x = 0, if TON150 > 0  */
;
;  /* This module sets the state change flag, if the end of USB1 is
;     detected. If USB1 is not detected for 3 ms then control goes to 
;     error handler. */
;--------------------------------------------------------------------------
RX_endusb1
        tstw    x:TON150                  ;Wait for TON150 to become zero
        bge     chkerr
        move    #1,x:rx_st_chg
chkerr
        decw    x:err_ctr                 ;If end of USB1 is not detected 
        jle     error                     ;  for 3 ms, execute err. routine
end_RX_endusb1        
        jmp     rx_next_task

;--------------------------------------------------------------------------
;  Input  :                               
;          Count in TONS1 and err_ctr                          
;  Output :                               
;          rx_st_chg = | 0000 0000 0000 000x |
;
;  /* This module does check for detection of s1 for 14bauds continuously.
;     If there is a carrier drop for 8 ms continuously, then start 
;     detecting s1 again and reset the counter rx_ctr and the error
;     counter. If S1 is not detected continuously for 60ms without
;     carrier drop then state change is effected but to v22 mode. */
;--------------------------------------------------------------------------
RX_s1call
        move    #$8e00,x0                 ;Check if 14 bauds of S1 detected
        move    x:TONS1,a
        cmp     x0,a
        jlt     noinit
        move    #1,x:rx_st_chg            ;If so change state
        move    #Rx_StQGBis,x0            ;  to rxGBisA
        move    x0,x:Rx_StQ_ptr
        jmp     end_RX_s1call

noinit
        move    x:LPBAGC2,a               ;Detecting the drop in signal
        move    x:LPBAGC,x0               ;  level. Done by checking if
        asr     a                         ;  LPBAGC >= LPBAGC2/2 
        cmp     x0,a
        move    #20,a1                    ;If so then there is no drop in
        blt     NODRP                     ;  signal,              
        move    x:err_ctr,a               ;Else see if the drop in signal
        dec     a                         ;  persists for 8ms continuously
        blt     DROP                      ;  if so jump to drop 

NODRP                                    
        move    a1,x:err_ctr
        decw    x:rx_ctr
        bgt     end_RX_s1call
        move    #1,x0
        move    x0,x:rx_st_chg
        move    #Rx_StQG22,x0
        move    x0,x:Rx_StQ_ptr
        jmp     end_RX_s1call

DROP
        move    #rxCFerr,y0
        move    y0,x:err_ctr
        move    #rxCFctr,y0
        move    y0,x:rx_ctr
end_RX_s1call
        jmp     rx_next_task
        

;--------------------------------------------------------------------------
;  Input  :                               
;          Count in rx_ctr and threshold in CD1                          
;  Output :                               
;          rx_st_chg = | 0000 0000 0000 000x |
;                      /*  x = 0, if rx_ctr > 0 and CD1 != 0 */
;
;  /* This module waits for the carrier drop for 26 ms */
;--------------------------------------------------------------------------
RX_cdrop
        tstw    x:CD1                     ;Check for carrier threshold
        move    #$0800,b                  ;Detect carrier drop within 26 ms
        bgt     RXA_NOCDA                 ;Wait if no carrier drop for 26ms
        neg     b                         
RXA_NOCDA
        move    x:rx_ctr,x0
        add     x0,b
        move    #$8100,a
        cmp     a,b
        move    #$7f00,a                  ;Carrier drop detected
        ble     stchg                    
        cmp     a,b                       ;No carrier drop
        blt     nextsk
                   
        incw    x:Rx_StQ_ptr              ;The next state is AC

stchg
        move    #1,x0                     ;Change the state
        move    x0,x:rx_st_chg

nextsk
        move    b,x:rx_ctr                ;Store the counter value
end_RX_cdrop
        jmp     rx_next_task              ;Execute next task in the RxQ

;--------------------------------------------------------------------------
;  Input  :                               
;          CD1
;          rx_ctr
;  Output :                               
;          rx_st_chg = | 0000 0000 0000 000x |
;                      /*  x = 0, if rx_ctr > 0  */
;
;  /* This module waits for sudden increase in the signal level 
;     If (AGCLP1-AGCLP2) > (AGCLP1)/2, then it implies that there is a
;     sudden increase in the signal level on the line. If this state
;     persists for 10ms then jump to next state. Else reinitialise
;     rx_ctr and remain in this state */
;--------------------------------------------------------------------------
RX_signal                                 
        move    x:AGCLP1,x0               
        tfr     x0,a                      
        move    #$4000,y0                 
        mpy     x0,y0,b                   
        move    x:AGCLP2,x0               
        sub     x0,a                      
        move    #0,b0
        cmp     b,a                       ;If there is sudden increase in
                                          ;  the signal level detect for
                                          ;  continuous increase for 10ms
        jgt     suddeninc                

        move    #rxACctr,a
        move    a,x:rx_ctr
        jmp     end_RX_signal

suddeninc
        decw    x:rx_ctr
        bgt     end_RX_signal             ;No state transition if no
                                          ;  timeout
        move    #1,x0                     
        move    x0,x:rx_st_chg            ;Goto state AD
end_RX_signal
        jmp     rx_next_task              ;Execute next task in RxQ

;--------------------------------------------------------------------------
;  Input  :                               
;          Count in rx_ctr and the flag in CD1                          
;  Output :                               
;          rx_st_chg = | 0000 0000 0000 000x |
;                      /*  x = 0, if rx_ctr > 0  */
;
;  /* This module waits for the signal continuously for 6.67ms. Even
;     if CD1 becomes 0 once then the counter is reset to 6.67 ms and
;     starts from the beginning. Once the signal is detected cont.
;     for 6.67ms jump to next state */
;--------------------------------------------------------------------------
RX_carrierup
        tstw    x:CD1                     ;Wait for carrier signal for 
                                          ;  6.67 ms
        bne     detect                   
        move    #rxAC1ctr,x0
        move    x0,x:rx_ctr
        bra     end_RX_carrirup           ;If carrier not detected then
                                          ;  no state transition
detect
        decw    x:rx_ctr
        bgt     end_RX_carrirup
        move    #1,x0
        move    x0,x:rx_st_chg            ;Goto state AD
        incw    x:Rx_StQ_ptr
end_RX_carrirup
        jmp     rx_next_task

;--------------------------------------------------------------------------
;  Input  :                               
;       1. Count in rx_ctr 
;       2. Flag in  CD1                          
;       3. counter increment to decide presence or absence of carr. in RXTH
;       4. Counter to test the presence of S1 signal in TONS1
;  Output :                               
;          rx_st_chg = | 0000 0000 0000 000x |
;          AGCG and AGCLG
;
;  /* This module does check for detection of s1 for 10bauds continuously.
;     If there is a carrier drop for 8.89 ms continuously, then goto
;     state rx_AC1. If S1 is not detected continuously for 80ms without
;     carrier drop then state change is effected but to v22 mode. */
;--------------------------------------------------------------------------
RX_s1ans
        tstw    x:CD1
        move    #$1800,b                   ;Check if the carrier is down 
                                           ;  for 8.88 ms continuously
        jle     ans_nocd                  
        move    #$d000,b

ans_nocd
        move    x:RXTH,x0    
        add     x0,b
        move    b,x:RXTH                   ;If RXTH<0 after the increment
        blt     _RXAS1CD                   ;  carrier is present. 
        move    #$0500,b                   ;Else carrier not present and
        move    b,x:AGCG                   ;  and go back to state rx_AC1
        move    #0,x:AGCLG
        move    #1,x0
        move    x0,x:rx_st_chg

        move    #Rx_StQA,a
        add     #2,a
        move    a,x:Rx_StQ_ptr
        jmp     end_RX_s1ans
_RXAS1CD
        move    x:TONS1,a                  ;If TONS1>0x8a00 (i.e.,) 10 baud
        move    #$8a00,b                   ;  of S1 detected then change 
        cmp     b,a                        ;  change state

        blt     checkc
_bis
        move    #Rx_StQGBis,x0
        move    x0,x:Rx_StQ_ptr
        move    #1,x0
        move    x0,x:rx_st_chg
        bra     end_RX_s1ans

checkc
        decw    x:rx_ctr                   ;Else wait for the timeout 
        bgt     end_RX_s1ans               ;  period of 80ms and still
        move    #Rx_StQG22,a               ;  if S1 is not found then jump
        move    a,x:Rx_StQ_ptr             ;  to v22 mode.
        move    #1,x0
        move    x0,x:rx_st_chg
end_RX_s1ans
        jmp     rx_next_task



;--------------------------------------------------------------------------
;  Input  :                               
;      1.  Count in rx_ctr 
;      2.  Flag in CD1                          
;      3.  Descrambler output in rx_data
;  Output :                               
;          rx_st_chg = | 0000 0000 0000 000x |
;
; /* If in calling mode
;       if received scrambled binary ones continuously for 208 ms
;          go to next state
;       else 
;          reinitialise the rx_ctr to 208 ms range
;       endif
;    Else  (in answering mode)
;       if there is a carrier drop for the period specified by RXTH
;          re initialise the buffers and go to state rx_AC1
;       else
;          if rx_AC1 was the state thro' which the receiver traversed
;             if %0011 is the bit pattern decrement rx_ctr 
;             else reinitialise rx_ctr to #rxG22Bctr (208ms)
;          else if rx_AC was the state thro' which the receiver traversed
;             CD_CNT=CD_CNT+$00da   (to account for 250ms)
;             if CD_CNT < 0  ( note CD_CNT init to max neg. no. in rx_AC)
;                if %0011 is the bit pattern decrement rx_ctr
;                else reinitialise rx_ctr to #rxG22Bctr (208ms)
;             else     (For more than 250ms no scr bin 1 but carrier pres.)
;                initialise buffers and agc parameters and jump to stateAC
;             endif          
;          endif                    
;       endif
;       if rx_ctr expired, i.e., scr bin.1s detected continuously for
;                                   208ms
;          jump to the next state
;       else
;          be in this state and do the other tasks in the q
;       endif
;    Endif */     
;--------------------------------------------------------------------------
RX_scr12
        bftsth  #CALLANS,x:MDMCONFIG      ;0:Calling 1:Answering
                                          ;If calling start checking scr1
        jcc     rcvscrb1                 
        tstw    x:CD1                     
        move    #$1800,b                  ;If CD1 = 0 No carry
        ble     v22_nocd
        move    #$d000,b                

v22_nocd
        move    x:RXTH,x0                 ;If CD1=0, RXTH = RXTH + $1800
        add     x0,b                      ;Else      RXTH = RXTH + $d000
        move    b,x:RXTH
        jlt     rcvscrsig                

        move    #1,x0                     ;  it implies there is a drop in
        move    x0,x:rx_st_chg            ;  carrier and hence go to AC1 

        move    #Rx_StQA,x0
        add     #2,x0                     ;  state after performing some

        move    x0,x:Rx_StQ_ptr           ;  buffer initialisation 
        jsr     INIT_BEG_AGC
        jmp     End_RX_scr12

rcvscrsig
        tstw    x:CD_CNT                  ;Else check if this state is 
                                          ;  is reached thro' state AC or
                                          ;  AC1. If CD_CNT=0 it is thro'
                                          ;  AC1 else it is thro' AC

        jge     rcvscrb1

        move    #$00da,x0                 ;If it has come thro' AC,
        move    x:CD_CNT,a                ;CD_CNT = CD_CNT + $00da
        add     x0,a                      ;The step $00da is determined
        move    a,x:CD_CNT                ;  from the time reqd i.e.250ms
                                          ;If CD_CNT < 0, check scrb1
        jlt     rcvscrb1                 
        move    #$0500,a                  ;Else set AGCG = $0500
        move    a,x:AGCG                  ;     set AGCLG = 0
        move    #0,x:AGCLG
        move    #1,x0
        move    x0,x:rx_st_chg            ;     jump to state AC

        move    #Rx_StQA,x0
        add     #2,x0
        move    x0,x:Rx_StQ_ptr
        jsr     INIT_BEG
        jsr     CLR_RAM2                  ;
        jmp     End_RX_scr12

rcvscrb1
        move    x:rx_data,x0              ;Check if the output of the
        bftsth  #3,x0                     ;  descrambler is $0003.
                                          ;If yes then detected scrb1
        jcs     scrb1                     ;If yes then detected scrb1

        move    #rxG22Bctr,a              ;Else reinit counter
        move    a,x:rx_ctr
        jmp     End_RX_scr12

scrb1
        decw    x:rx_ctr
        jgt     End_RX_scr12
        move    #1,x0
        move    x0,x:rx_st_chg
End_RX_scr12    
        jmp     rx_next_task                  

        

;--------------------------------------------------------------------------
;  Input  :                               
;       1. Count in rx_ctr 
;       2. Noise power in x:NOISE
;       3. Carrier detect flag CD1
;  Output :                               
;       Bit DISCON (Disconnect) in the Flag MDMSTATUS
;
;  /*  If Noise > $0c00
;         inc=18
;      Else
;         inc=-36
;      endif
;      if CD1=0
;         rx_ctr = $d500 + inc
;      else
;         rx_ctr = rx_ctr + inc
;      endif
;      if (rx_ctr >= 0 && RET_EN is set in MDMCONFIG)
;         set Disconnect bit in MDMSTATUS
;      endif
;      jump to RXDM_CD subsection to detect drop in carrier */
;--------------------------------------------------------------------------
RX_v22dm
        move    x:NOISE,a
        move    #NOISETHR,x0
        cmp     x0,a
        move    #18,x0         

        jge     morenoise
        move    #-18*2,x0     

morenoise
        tstw    x:CD1
        move    #$d500,a
        jle     nocd1
        move    x:rx_ctr,a
nocd1  
        add     x0,a
        move    a,x:rx_ctr
        jlt     tolnoise
        bftsth  #RET_EN,x:MDMCONFIG
        bcs     disconnect
        bfset   #NOISY,x:MDMSTATUS
        jmp     tolnoise

disconnect
        bfset   #DISCON,x:MDMSTATUS

tolnoise
        jmp     RXDM_CD


;--------------------------------------------------------------------------
;  Input  :                               
;          TONS1
;  Output :                               
;          rx_st_chg = | 0000 0000 0000 000x |
;
;  /* If TONS1 falls below $7c00 then decide S1 has stopped on the line 
;     TONS1 was initialised to $7f00 when this state was entered. If 3
;     successive bauds doesnot contain S1 then it is declared as not 
;     present */
;--------------------------------------------------------------------------
RX_s1end                                  ;
        move    x:TONS1,b                 ;Get TONS1
        move    #$7c00,x0                 ;Is TONS1 > $7c00
        cmp     x0,b 
        bgt     end_RX_s1end              ;If so S1 is still present
        move    #1,x0                     ;Else change state to GBisB
        move    x0,x:rx_st_chg
end_RX_s1end
        jmp     rx_next_task

;--------------------------------------------------------------------------
;  Input  :                               
;       1. Count in rx_ctr 
;       2. Time out counter in err_ctr
;       3. Descrambler output rx_data
;
;  Output :                               
;          flg_109   = | x000 0000 0000 0000 | which will be tested in tx.
;                                              before entering data mode
;          rx_st_chg = | 0000 0000 0000 000x |
;
;  /*   err_ctr is initialised to represent 2 sec while entering the state
;       If the err_ctr expires then enter retrain state
;       Check if the descrambler output is all ones ($000f). rx_ctr is init
;       to 8. If for 8 bauds continuosly the ouput is the same then we
;       have received 32 consecutive ones. Hence get to the next state. */
;--------------------------------------------------------------------------
RX_wait32bit                              ;State GDB
        decw    x:err_ctr                 ;Decrement the timeout counter
        bgt     noretrn                  

        move    #Rx_StQGBis,x0
        add     #7,x0                     ;  go to retrain checks
        move    x0,x:Rx_StQ_ptr
        bra     st_chg1      

noretrn
        move    x:rx_data,a               ;Get the descrambler output
        bftsth  #$000f,a                  ;Check if 4 ones are recvd.

        bcc     wait32bit
        decw    x:rx_ctr                  ;If yes decrement the rx_ctr
        bgt     end_RX_wait32bit
                                          ;If rx_ctr has expired set
st_chg1                                  
        move    #$8000,x:flg_109          ;  state change flag to go to
        move    #1,x0                     ;  GBisE state
        move    x0,x:rx_st_chg

wait32bit      
        move    #rxGBisDctr,x0            ;Even if one baud doesnt contain
        move    x0,x:rx_ctr               ;  4 ones reinit the counter
end_RX_wait32bit      
        jmp     rx_next_task

;--------------------------------------------------------------------------
;  Input  :                               
;          flag containing the phase the modem is in, in x:mode_flg
;  Output :                               
;          rx_st_chg = | 0000 0000 0000 000x |
;
;  /* This module goes to the next state if the tx enters the data mode.*/
;--------------------------------------------------------------------------
RX_waitdm
        bftsth  #datamd,x:mode_flg
        bcc     end_RX_waitdm
        move    #1,x:rx_st_chg           
end_RX_waitdm
        jmp     rx_next_task
;--------------------------------------------------------------------------
;  Input  :                               
;       1. Count in rx_ctr 
;       2. TONS1
;  Output :                               
;          rx_st_chg = | 0000 0000 0000 000x |
;                      /*  x = 0, if rx_ctr > 0  */
;
;  /* Check for remote retrain requests by checking for S1 signal
;     If S1 signal is received for the given period, then remote retrain
;     request is honoured. Else after 1 sec get to the next state 
;     Note that the  local transmitter has already entered data mode*/
;--------------------------------------------------------------------------
RX_wait1sec                               
        move    x:TONS1,b                 ;Get the counter ticking for S1
                                          ;  (was init. to $8000)
        move    #$9400,a                  ;Check if TONS1>$9400
        cmp     a,b        
        jgt     Rx_Rmt_Ret                ;If so then jump to remote ret.               
        decw    x:rx_ctr
        bgt     end_RX_wait1sec
        move    #1,x0                     ;Else at the end of 1sec change
        move    x0,x:rx_st_chg            ;  state to GBisF
end_RX_wait1sec
        jmp     rx_next_task

;--------------------------------------------------------------------------
;  Input  :                               
;          Count in rx_ctr and threshold in CD1                          
;  Output :                               
;          rx_st_chg = | 0000 0000 0000 000x |
;
;  /* err_ctr initialised to 0
;     rx_ctr  initialised to $8000
;     RXTH    initialised to $00c8
;     TONS1   initialised to $8000
;     CD_CNT  initialised to $8000  */
;           
;  /* Enables v22-v42 interface at appropriate time
;     Checks for local request based on the noise power. If it crosses
;       a specific threshold, set local rertrain request if the RET_EN
;       flag is set
;     Checks for the remote request by checking for the TONS1 signal 
;     Jumps to carrier check subsection */
;--------------------------------------------------------------------------
RX_v22bisdm               
        bftsth  #CDBIT,x:MDMSTATUS        ;Check the Carrier detect bit in
                                          ;  Modem status flag
        jcc     RXDM_CD                   ;If it is not present jump to 
                                          ;  RXDM_CD subsection
        tstw    x:err_ctr                 ;If err_ctr <= 0,
        ble     RXDM_BIS                  ;  Check for retrain
        decw    x:err_ctr                 ;Decrement err_ctr
        bgt     RXDM_BIS                  ;If now err_ctr>0 Check for 
                                          ;  retrain. At this time the
                                          ;  signal has just come up 
                                          ;  after being absent, and 100ms
                                          ;  recovery time is necessary
                                          ;  if it is 22 bis connection.
                                          ;  V22-42 int remain disabled
        move    #1,x:RX_LAPM_EN           ;Else enable V22-v42 interface
        
RXDM_BIS
        bftsth  #LREQ,x:MDMSTATUS         ;Check if there is local request
                                          ;  for retrain
        jcc     NO_LREQ                  
        decw    x:RETRCNT                 ;This is done for convenience
        jmp     retrn                     ;  The RETRCNT doesnt get altered
                    
NO_LREQ
        move    x:TONS1,b                 ;Check for remote retrain req.
        move    #$8700,x0                 ;If TONS1 > $8700
        cmp     x0,b         
        jgt     Rx_Rmt_Ret                ;Then remote requ. present
        move    x:RXTH,x0                 ;Check if the channel is too 
        move    x:NOISE,b                 ;  noisy. If NOISE > $00c8,
        cmp     x0,b                      ;  it is considered noisy
        move    #9,a                      ;If NOISE > $00c8,  
                                          ;  rx_ctr = rx_ctr + 9
        bgt     RXBDEC                   
        move    #-18,a                    ;Else
                                          ;  rx_ctr = rx_ctr - 18
RXBDEC                                   

        move    x:rx_ctr,b
        add     a,b
        move    b,x:rx_ctr
        jle     RXDM_CD                   ;If rx_ctr < 0 jmp to RXDM_CD
        bftsth  #RET_EN,x:MDMCONFIG       ;Else if retrain is enabled,then
                                          ;  time to do retrain since the
                                          ;  noise is too high. Hence chg
                                          ;  state to GRetA
        jcs     retrn                     ;If retrain is enabled go to retrn
        bfset   #NOISY,x:MDMSTATUS
        jmp     RXDM_CD                   ;If retrain is not enabled then
                                          ;  push data thro' noisy chan.
retrn                                    
        move    #1,x0
        move    x0,x:rx_st_chg            ;Goto retrain checks state
                                          ;  i.e., state GRetA
        jmp     rx_next_task

;--------------------------------------------------------------------------
;  Input  :                               
;        1. err_ctr
;        2. TONS1
;        3. RETCNT_RM
;        4. RETRCNT
;        5. Flag MDMSTATUS 
;  Output :                               
;        1. rx_st_chg = | 0000 0000 0000 000x |
;        2. flag mode_flg
;
;  /* err_ctr was initialised to 1.2 sec recommended in the standard as the
;     time required to receive S1 seq. after transmitting it.(two way pro-
;     pogation delay */ 
;--------------------------------------------------------------------------
RX_retrain                    
        decw    x:err_ctr                 ;Decrement the two prop.delay ctr 
        ble     Ret_reinit                ;If ctr expired reinitialise
        move    x:TONS1,x0                ;Else check if the remote is 
        move    #$8a00,b                  ;  responding to the txed S1
        cmp     x0,b                      ;If TONS1>$8ab0 then S1 is det.
        jge     rx_next_task              ;If S1 is rxed, goto state GBisA
        jmp     st_chg                    ;Else go to next task

Ret_reinit                                ;Reinitialisation because no resp
                                          ;  for the S1 transmitted
        move    x:RETCNT_RM,a             ;Check the no. of times reinit.
        inc     a
        move    #5,x0
        cmp     x0,a
        move    a,x:RETCNT_RM             ;If it is less than 5, repeat
        jlt     RX_RETR_REP
        move    #0,x:RETRCNT              ;Else set RETRCNT = 0
        bfclr   #CDBIT,x:MDMSTATUS        ;Clear CDBIT 
        bfset   #DISCON,x:MDMSTATUS       ;Set Disconnect
        move    #5,x0                     ;Saturate RETCNT_RM
        move    x0,x:RETCNT_RM
        jmp     RX_RETR_A

RX_RETR_REP                               ;Repeating retrain sequence
        move    x:RETRCNT,b               ;If no. of self retrain req.
        inc     b                         ; is greater than 5 DISCONNECT
        move    #5,x0
        cmp     x0,b
        move    b,x:RETRCNT
        ble     RX_RETR_A                 ;Else repeat the retrain
        bfset   #DISCON,x:MDMSTATUS

RX_RETR_A
        move    #retrn,x:mode_flg         ;Set retrn mode, so that tx.can
                                          ;  change state
        bfset   #LREQ,x:MDMSTATUS         ;Set the Local Request 
        move    #0,x:TRN_LNG
        move    #0,x:CDP                  ;CDP=0
        move    #RX_retrain,a
        move    a,x:RXQ                   
        move    #ENDRX,a
        move    a,x:RXQ_8
        move    #rxRetAerr,x0
        move    x0,x:err_ctr
        jmp     rx_next_task     


;--------------------------------------------------------------------------
;  Input  :                               
;        None
;  Output :                               
;        None
;
;  /* Jump to next task */
;--------------------------------------------------------------------------
RX_NEXT
        jmp     rx_next_task

;--------------------------------------------------------------------------
;  Input  :                               
;        rx_data the output of the descrambler
;  Output :                               
;        None
;  /* Calls the V42 driver */
;--------------------------------------------------------------------------
ENDRX    
        rts      

;--------------------------------------------------------------------------
;  Input  :                               
;        None
;  Output :                               
;        None 
;  /* Sets the error bit in MDM STATUS */ 
;--------------------------------------------------------------------------
error
        bfset   #RXERR,x:MDMSTATUS
        rts



;The modules ' Rx_Rmt_Ret ' and ' RXDM_CD 'are not the parts of state. 
;These are called from different modules.
;----------------------------------------------------------
;The module Rx_Rmt_Ret is called RX_v22bisdm & RX_wait1sec
;----------------------------------------------------------  

Rx_Rmt_Ret
        move    #0,x:RX_LAPM_EN
        move    #0,x:TX_LAPM_EN

        move    #retrn,x:mode_flg         ;Set retrain bit in mode_flg
        incw    x:retctr
        bfset   #RREQ,x:MDMSTATUS         ;Remote retrain bit set
        move    #0,x:RETCNT_RM            ;RETCNT_REM = 0
st_chg
        move    #0,x:RETCNT_RM
        move    #Rx_StQGBis,x0
        move    x0,x:Rx_StQ_ptr
        move    #1,x0
        move    x0,x:rx_st_chg
end_Rx_Rmt_Ret
        jmp     rx_next_task

;--------------------------------------------------------------------------
;The module RXDMCD is called by RX_v22dm, RX_v22bisdm
;-----------------------------------------------------
;Ref. section 3.2, 3.3 and 6.5 of the standard. 
;-----------------------------------------------------
;Description of the variables used
;     CD_CNT  : This simulates the delay in the response of the 109 ckt
;               This delay is given  in the 3.2 section of the std.,
;     CDBIT   : This is a bit in MDMSTATUS. Is cleared when the carrier
;               is missing for the response time of 109 to go from on 
;               to off.
;               Is set when the carrier is up for a period more than the
;               response time of the 109 to go from off to on.
;     err_ctr : This is used both as flag to enable/disable the v22-42int.
;               and as a counter to give the 100ms delay reqd. to remove
;               the clamping from 104 ckt(which in our implementation 
;               means to stop stuffing ones in the v22-v42 interface
;               buffer) as per the section 3.2 of the standard
;------------------------------------------------------
;Case : CD BIT is set.   Implies signal is present and wait for a drop
;
;       If CD1 = 0
;          CD_CNT = CD_CNT + $0100
;       else
;          CD_CNT = CD_CNT + $fd00    /* Decrement CD_CNT */
;       endif
;       if CD_CNT < $8600             /* If less than 10ms has elapsed */
;          if CD_CNT <= $8000         /* There is no drop in carrier */
;             jump to next task
;          else if err_ctr >=0        /* Ther is drop but less than 10ms */
;             jump to next task
;          else                       /* err_ctr is negative indicating
;                                        v22-v42 interface is disabled */
;             enable v22-v42 interface                   /* 109 ckt on */
;             stuff interface buff. with ones            /* 104 = 1    */
;             err_ctr = 0
;             CD_CNT = $8000
;          endif
;       else                          /* more than 10ms elapsed */
;          if err_ctr >= 0            /* err_ctr is +ve indicating
;                                        v22-v42 interface is enabled */
;             disable v22-v42 interface
;          endif
;          err_ctr = $8000
;          if (V22 Bis Mode)
;             thresh = $9e00          /* response time of ckt 109 is longer
;                                        for v22bis mode -- 50 ms */
;          else (V22 mode)            
;             thresh = $8600          /* resp. time of ckt 109 = 10ms */
;          endif
;          if CD_CNT < thresh
;             jump to next task       /* Wait for the response time before
;                                        declaring no carry */
;          else
;             Clear CD_BIT
;             err_ctr = 0
;             CD_CNT = $7f00
;          endif
;       endif
;
;Case : CD BIT is clear.   Implies signal is absent and wait for it to come
;       
;       If CD = 0
;          CD_CNT = CD_CNT + $0100
;       else
;          CD_CNT = CD_CNT + $ffa5
;       endif
;       if CD_CNT > $5f02            /* Response time  is roughly 150ms */
;          jump next task            /* wait for the response time before
;                                       declaring the presence of signal */
;       else
;          set CDBIT
;          if (V22 Bis mode)
;             err_ctr = 60           /* 100ms counter before releasing the
;                                       clamp on the ckt 104 and enabling
;                                       v22-v42 interface */
;          else (v22mode)
;             err_ctr = 0
;             enable v22-v42 interface                     /* 109 on */
;          endif
;          stuff ones to the interface buffer              /* 104 = 1 */
;          CD_CNT = $8000
;          jump next task
;       endif
;ENDCASE
;          
;-------------------------------------------------------------------------- 
RXDM_CD                                   ;Carrier detect
        move    x:speed,y0
        bftsth  #CDBIT,x:MDMSTATUS        ;If Carrier Detect bit is cleared
        jcc     RXDMCDOFF                 ;  jump to Detect the carrier
        tstw    x:CD1                     ;Check carrier flag
        move    #$fd00,x0                 ;if CD1 = 0,
        bgt     RXDMCDON                  ;  temp = CD_CNT + $fd00 (neg.no)
        move    #$0100,x0                 ;Else
RXDMCDON                                  ;  temp = CD_CNT + $0100
        move    x:CD_CNT,a                ;Endif
        add     x0,a
        move    #$8600,x0                 ;If CD_CNT < $8600 (10ms mark)
        cmp     x0,a                      ;  jump to lt10ms
        jlt     lt10ms                    ;Else if it is greater,
        tstw    x:err_ctr                 ;If the err_ctr < 0
        jlt     cdcmiooff                 ;  then jump to cdcmiooff
        move    #0,x:RX_LAPM_EN           ;Disable V22-V42 interface
        move    #$8000,b                  ;err_ctr = $8000
        move    b,x:err_ctr
cdcmiooff
        move    #0003,b1                  ;speed =3 for v22bis 
                                          ;  and 2 for v22 connection
        cmp     y0,b                      ;Check which mode modem is in
        bgt     CDCMOF1                   ;If speed = 3, thresh =$9e00
        move    #$9e00,x0                 ;Else        , thresh =$8600
CDCMOF1
        cmp     x0,a                      ;If temp < thresh,CD_CNT = temp
        blt     WR_CDCNT                  ;Else temp >= thresh, 
        bfclr   #CDBIT,x:MDMSTATUS        ;  clear CD bit 
        move    #0,x:err_ctr              ;err_ctr = 0
        move    #$7f00,a                  ;CD_CNT = $7f00
        jmp     WR_CDCNT                  ;

lt10ms                                    ;CD_CNT<10ms mark
        move    #$8000,x0                 ;If temp <= $8000
        cmp     x0,a
        ble     WR_CDCNT                  ;  CD_CNT = $8000,jmp next task
        tstw    x:err_ctr                 ;Else if err_ctr >= 0
        bge     WR_CDCNT                  ;  CD_CNT = temp, jmp next task
        bra     CDONOF                    ;Else err_ctr = 0
                                          ;  CD_CNT = $8000
                                          ;  Enable v22-v42 interface

RXDMCDOFF                                 ;CD Bit was cleared initially
        tstw    x:CD1                     ;If CD1 = 0,
        move    #$0100,x0                 ;  temp = CD_CNT + $0100
        ble     RXDM_OFF                  ;Else
        move    #$ffa5,x0                 ;  temp = CD_CNT + $ffa5
RXDM_OFF                                  ;Endif
        move    x:CD_CNT,a
        add     x0,a
        move    #$5f02,x0
        cmp     x0,a
        move    #0003,b1                  ;  CD_CNT = temp
        bgt     WR_CDCNT                  ;  jump next task
        bfset   #CDBIT,x:MDMSTATUS        ;Else, Set CD bit
        cmp     y0,b                      ;If connected as V22 bis
        move    #60,a1                    ;  set err_ctr = 60
        move    a1,x:err_ctr              ;Else if V22 mode
        ble     CDOFF_22B                 ;  set err_ctr = 0
CDONOF                                    ;
        move    #1,x:RX_LAPM_EN           ;Enable V22-V42 interface
        move    #0,x:err_ctr   
CDOFF_22B                     
        move    #$8000,a                  ;CD_CNT = $8000

WR_CDCNT
        move    a,x:CD_CNT
        jmp     rx_next_task

        ENDSEC
