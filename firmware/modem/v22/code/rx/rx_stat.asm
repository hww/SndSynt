;******************************** Module **********************************
;
;  Module Name     : rx_stat
;  Author          : Varadarajan G
;  Date of origin  : 
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;*************************** Module Description ***************************
;
;  This module describes the state initializations for each rx state. This
;  module is invoked by the controller module every time a state transition 
;  takes place. It performs following actions :
;
;  1. Sets rx_st_id and (optional) flags.
;  2. (Optional) Check Flags
;  3. Sets rx_ctr - a counter to terminate the timed events.
;  4. Initializes variables and pointers for the state.
;  5. Sets up the receiver task queue for each state.
;
;  NOTE :
;     This module only sets up the task queue.
;     The task queue is executed by the controller module.
;  
;************************** Calling Requirements **************************
;  
;  Note : Each state initialization depends on the previous state init
;         modules. Therefore these modules should be called in order and
;         the TxQ buffer should not be changed between successive calls.
;   
;*************************** Input and Output *****************************
;
;  Input     :
;              None
;  Output    :
;              Initialize states
;  Flags set :
;              state_id = | 0000 0000 | 0000 nnnn | in x:rx_st_id
;                                     nnnn = state number
;              flg_xxx  = | i000 0000 | 0000 0000 | in x:flg_xxx
;                            where xxx denotes the flag number as
;                            per specifications of CCITT
;
;******************************* Resources ********************************
;
;
;                         NLOAC         :  147
;
;  Address Registers used : 
;                          r0  
;  Modifier register used :
;                          None
;  Offset Registers used  : 
;                          None
;  Data Registers used    : 
;                          x0  
;  Registers Changed      : 
;                          x0  r0  sr  pc  
;  Flags                  :
;                          rx_st_id, rx_ans_flg, flg_107, flg_112, 
;                          flg_109, mode_flg
;                    
;***************************** Pseudo Code ********************************
;
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

;RXQ and other buffers initialised in rxmdmini.asm
	
;--------------------------------------------------------------------------
;  Mode              : Calling    
;  State Description : It performs the RXQ for 500 ms (rxCActr)
;  State id          : 1
;
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RX_NEXT
;                      RX_wait
;                      ENDRX
;--------------------------------------------------------------------------

        include "rxmdmequ.asm"
        include "gmdmequ.asm"
 
        SECTION V22B_RX 


        GLOBAL rx_CA
        GLOBAL rx_CB
        GLOBAL rx_CC
        GLOBAL rx_CD
        GLOBAL rx_CE
        GLOBAL rx_CF
        GLOBAL rx_AA
        GLOBAL rx_AB
        GLOBAL rx_AC1
        GLOBAL rx_AC
        GLOBAL rx_AD
        GLOBAL rx_G22A
        GLOBAL rx_G22B
        GLOBAL rx_G22C
        GLOBAL rx_G22D
        GLOBAL rx_G22D
        GLOBAL rx_GBisA
        GLOBAL rx_GBisB
        GLOBAL rx_GBisC
        GLOBAL rx_GBisD
        GLOBAL rx_GBisE
        GLOBAL rx_GBisF
        GLOBAL rx_GBisG
        GLOBAL rx_GRetA
   

        org p:

rx_CA
        move    #1,x:rx_st_id
        move    #rxCActr,a                
        move    a,x:rx_ctr                
        move    #RX_wait,a                

        move     a,x:RXQ_6
End_rx_CA
        rts
 
;--------------------------------------------------------------------------
;  Mode              : Calling    
;  State Description : It performs the RXQ for 25 ms (rxCBctr)
;                      Detects carrier continuouslu for this time
;  State id          : 2
;
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RX_NEXT
;                      RX_cd
;                      ENDRX
;--------------------------------------------------------------------------
rx_CB
        move    #2,x:rx_st_id
        move    #rxCBctr,a               
        move    a,x:rx_ctr
        move    #RX_cd,a

        move    a,x:RXQ_6
End_rx_CB
        rts

;--------------------------------------------------------------------------
;  Mode              : Calling    
;  State Description : Detects Ans.Tone and USB1 continuously for 155ms
;  State id          : 3
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RX_NEXT
;                      RXUSB1
;                      RX_atusb1
;                      ENDRX
;--------------------------------------------------------------------------
rx_CC
        move    #3,x:rx_st_id
        move    #FASTAGC,a                ;Set Fast AGC gain adaptation
        move    a,x:AGCLG
        move    #$8000,a                  ;Set TON2100 & TON150 to max neg.
        move    a,x:TON2100               ;  val. to start detecting A-Tone
        move    a,x:TON150                ;  and USB1
        move    #rxCCctr,a                ;Initialise rx timer
        move    a,x:rx_ctr
        move    a,x:RXTH
        move    #rxCCtout,a
        move    a,x:rx_toutctr

        move     #RXQ_6,r0                ;Set the RXQ

        move    #RXUSB1,a
        move    a,x:(r0)+
        move    #RX_atusb1,a
        move    a,x:(r0)
End_rx_CC
        rts

;--------------------------------------------------------------------------
;  Mode              : Calling    
;  State Description : Detects  USB1.
;  State id          : 4
;                    
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RX_NEXT
;                      RXUSB1
;                      RX_usb1
;                      ENDRX
;--------------------------------------------------------------------------
rx_CD
        move    #4,x:rx_st_id
        move    #RX_usb1,a                ;
        move    a,x:RXQ_7
End_rx_CD
        rts

;--------------------------------------------------------------------------
;  Mode              : Calling    
;  State Description : Wait for the End of USB1. If it doesnt happen within
;                      3seconds(err_ctr), report error.
;  State id          : 5
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RX_NEXT
;                      RXUSB1
;                      RX_endusb1
;                      ENDRX
;--------------------------------------------------------------------------
rx_CE
        move    #5,x:rx_st_id
        move    #1,a                      ;Set the tx state change flag      
        move    a,x:tx_st_chg             ;  to indicate tx to start trans-
                                          ;  mitting 456ms of silence bef-
                                          ;  ore starting S1 signal
        move    #$8000,x:flg_107          ;Set flag 107 to indicate modem 
                                          ;  is up
        move    #SLOWAGC,a                ;Set for slow AGC gain adaptation
        move    a,x:AGCLG
        move    #$7fff,a                  ;Saturate TON150 to max positive
        move    a,x:TON150                ;  val. to indicate USB1 detected
        move    #$8000,a                  ;Saturate TONS1 to max neg. val. 
        move    a,x:TONS1                 ;  to start detecting S1
        move    #rxCEerr,a                ;Initialise error counter
        move    a,x:err_ctr
        move    #RX_endusb1,a
        move    a,x:RXQ_7
End_rx_CE
        rts

;--------------------------------------------------------------------------
;  Mode              : Calling    
;  State Description : Detect S1 without carrier drop.
;  State id          : 6
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RXBAUD
;                      RXS1
;                      RX_s1call
;                      ENDRX
;--------------------------------------------------------------------------
rx_CF
        move    #6,x:rx_st_id
        move    #rxCFctr,a
        move    a,x:rx_ctr
        move    #rxCFerr,a
        move    a,x:err_ctr

        move     #RXQ_5,r0
        move    #RXBAUD,a
        move    a,x:(r0)+
        move    #RXS1,a
        move    a,x:(r0)+
        move    #RX_s1call,a
        move    a,x:(r0)+
End_rx_CF
        rts


;--------------------------------------------------------------------------
;  Mode              : Answring
;  State Description : Perform RXQ till local tx. induces state change
;  State id          : 7
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RX_NEXT
;                      RX_wait
;                      ENDRX
;--------------------------------------------------------------------------
rx_AA
        move    #7,x:rx_st_id
        move    #rxAActr,a
        move    a,x:rx_ctr
        move    #RX_wait,a
        move    a,x:RXQ_6
End_rx_AA
        rts

;--------------------------------------------------------------------------
;  Mode              : Answring
;  State Description : Checks for carrier drop
;  State id          : 8
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RX_NEXT
;                      RX_cdrop
;                      ENDRX
;--------------------------------------------------------------------------
rx_AB 
        move    #8,x:rx_st_id
        move    #0,x:rx_ctr
        move    #RX_cdrop,a
        move    a,x:RXQ_6
End_rx_AB
        rts

;--------------------------------------------------------------------------
;  Mode              : Answring
;  State Description : Checks for sudden increment in signal for 10ms
;  State id          : 9
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RX_NEXT
;                      RX_signal
;                      ENDRX
;--------------------------------------------------------------------------
rx_AC
        move    #9,x:rx_st_id
        move    #rxACctr,a
        move    a,x:rx_ctr
        move    #$8000,a                  ;Saturates Carrier Detect Count      
        move    a,x:CD_CNT                ;  CD_CNT to max neg.value
                                          ;RXQ is initialised from 5th pos.  
        move    #RXQ_5,r0
        move    #RX_NEXT,a                ;  onwards till 8th pos. because
        move    a,x:(r0)+                 ;  this state is entered from 
        move    #RX_signal,a              ;  data mode where 5th,6th.7th &
        move    a,x:(r0)+                 ;  8th pos. will be different
        move    #ENDRX,a
        move    a,x:(r0)+
        move    a,x:(r0)+
End_rx_AC
        rts

;--------------------------------------------------------------------------
;  Mode              : Answring
;  State Description : Checks for carrier to come up again
;  State id          : 10
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RX_NEXT
;                      RX_carrierup
;                      ENDRX
;--------------------------------------------------------------------------
rx_AC1
        move    #10,x:rx_st_id
        move    #rxAC1ctr,a
        move    a,x:rx_ctr
        move    #0,x:CD_CNT               ;CD_CNT = 0

        move    #RXQ_5,r0                 ;RXQ is initialised from 5th pos.  
        move    #RX_NEXT,a                ;  onwards till 8th pos. because
        move    a,x:(r0)+                 ;  this state is entered from 
        move    #RX_carrierup,a           ;  data mode where 5th,6th.7th &
        move    a,x:(r0)+                 ;  8th pos. will be different
        move    #ENDRX,a
        move    a,x:(r0)+
        move    a,x:(r0)+
End_rx_AC1
        rts

;--------------------------------------------------------------------------
;  Mode              : Answring
;  State Description : start detecting s1 signal    
;  State id          : 11
;                     
;
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RXBAUD
;                      RXS1
;                      RX_s1ans
;                      ENDRX
;--------------------------------------------------------------------------
rx_AD
        move    #11,x:rx_st_id
        jsr     AGC_JAM                   ;AGCG is init. in this routine      
        move    #rxADctr,a
        move    a,x:rx_ctr
        move    #FASTAGC,a                ;Set Fast AGC updation
        move    a,x:AGCLG
        move    #$8000,a                  ;Saturate TONS1 to start s1 det-
        move    a,x:RXTH                  ;  ection. 
        move    a,x:TONS1
        move    #RXQ_5,r0
        move    #RXBAUD,a
        move    a,x:(r0)+
        move    #RXS1,a
        move    a,x:(r0)+
        move    #RX_s1ans,a
        move    a,x:(r0)
End_rx_AD
        rts


;--------------------------------------------------------------------------
;  Mode              : V22 mode
;  State Description : Process RXQ for 20ms
;  State id          : 12
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RXBAUD
;                      RX_NEXT
;                      RX_NEXT
;                      RXEQFIL
;                      RXDEC4
;                      RXEQERR
;                      RX_NEXT
;                      RXDIFDEC
;                      RXDESCR4
;                      RX_wait
;                      ENDRX
;--------------------------------------------------------------------------
rx_G22A
        move    #12,x:rx_st_id
        jsr     CLEQ_INIT                 ;Init. Various buffers
        move    #SLOWAGC,a
        move    a,x:AGCLG
        move    #rxG22Actr,a
        move    a,x:rx_ctr
        move    #RXQ_6,r0
        move    #RX_NEXT,a
        move    a,x:(r0)+
        move    a,x:(r0)+
        move    #RXEQFIL,a
        move    a,x:(r0)+
        move    #RX_wait,a
        move    a,x:RXQ_14

End_rx_G22A
        rts

;--------------------------------------------------------------------------
;  Mode              : V22 mode
;  State Description : Set up to do scrambled binary 1 detection
;  State id          : 13
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RXBAUD
;                      RX_NEXT
;                  =>  RXCAR
;                      RXEQFIL
;                      RXDEC4
;                      RXEQERR
;                  =>  RXEQUD
;                      RXDIFDEC
;                      RXDSCR4
;                  =>  RX_scr12
;                      ENDRX
;--------------------------------------------------------------------------
rx_G22B
        move    #13,x:rx_st_id
        move    #$2a00,a                  ;Adjusts the 9th real tap of the
        move    a,x:EQRT_8                ;  equaliser
        move    #$4000,a
        move    a,x:BOFF                  ;Baud Offset coeff = 0.5
        move    a,x:JITG1
        move    #$0800,a                  ;Jitter gain1 = 0.5
        move    a,x:JITG2                 ;Jitter gain2 = 2^(-4)
        move    #rxG22Bctr,a
        move    a,x:rx_ctr
        move    #RXCAR,a
        move    a,x:RXQ_7
        move    #RXEQUD,a
        move    a,x:RXQ_11
        move    #RX_scr12,a
        move    a,x:RXQ_14

End_rx_G22B
        rts
        
;--------------------------------------------------------------------------
;  Mode              : V22 mode
;  State Description : Perform RXQ till tx says to change state
;  State id          : 14
;                     
;  RXQ               : RXINTP
;                        .
;                        .
;  RXQ+14          =>  RX_waitdm
;                      ENDRX
;--------------------------------------------------------------------------
rx_G22C
        move    #14,x:rx_st_id
        move    #$0400,a                  ;Integrator Coefficient in Baud   
        move    a,x:BINTGA                ;  loop = 2^(-5)
        move    #$2000,a
        move    a,x:BOFF                  ;Baud Offset coeff. = 0.25
        move    #$8000,a                  ;Wrap flag is set bypass carrier
        move    a,x:WRPFLG                ;  phase wrapping
        move    #$0003,a                  ;USB1 pattern set to 0003
        move    a,x:USB1PAT
        move    #0002,a                   ;Speed is set to indicate 
        move    a,x:SPEED                 ;  1200 bps
        jsr     LAPM_MDM_INIT
        bfset   #V22Con,x:MDMSTATUS

        bftsth  #CABIT,x:rx_ans_flg       ;Sanjay for call modem only    
        bcs     _answering_data           ;If calling modem, set the 
        bfset   #DABIT,x:MDMSTATUS        ;  data_mode bit
          
_answering_data          
        tstw    x:loopback
        bne     _donotcheck     
        bftsth  #CABIT,x:rx_ans_flg    
        bcc     _calling                  ;If Answering modem, Effect 
        move    #1,a                      ;Effect state tras. in tx to 
        move    a,x:tx_st_chg             ;  transmit scrambled bin 1
        move    #0,x:flg_112
_calling
_donotcheck      
        move    #$8000,a                  ;Set 109 flag to say that scr.
        move    a,x:flg_109               ;  bin 1 has been det. for 270ms
        move    #rxG22Cctr,a   
        move    a,x:rx_ctr
        move    #RX_waitdm,a

        move    a,x:RXQ_14

End_rx_G22C
        rts

;--------------------------------------------------------------------------
;  Mode              : V22 mode
;  State Description : V22 data mode
;  State id          : 15
;                     
;  RXQ               : RXINTP
;                        .
;                        .
;  RXQ+14          =>  RX_v22dm
;                      ENDRX
;--------------------------------------------------------------------------
rx_G22D
 
        bfset   #DABIT,x:MDMSTATUS        ;Sanjay, for answering modem
                
        move    #15,x:rx_st_id
        move    #SLOWAGC,a                ;Set Slow AGCGain adaptation
        move    a,x:AGCLG
        move    #$1200,a                  ;AGC : LPF1 coeff. 1 : 0x1200
        move    a,x:AGCC1
        move    #$7800,a                  ;AGC : LPF1 coeff. 2 : 0x7800
        move    a,x:AGCC2
        move    #$0400,a                  ;AGC : LPF2 coeff. 1 : 0x0400
        move    a,x:AGCC3
        move    #$7c00,a                  ;AGC : LPF2 coeff. 2 : 0x7c00
        move    a,x:AGCC4
        move    #SLOWEQUD,a               ;Set slow Equaliser tap adapt.
        move    a,x:LUPALP
        move    #$0100,a                  ;Jitter Gain1 : 0x0100
        move    a,x:JITG1
        move    #$0800,a                  ;Jitter Gain2 : 0x0800
        move    a,x:JITG2
        move    #$6000,a                  ;Baud : LPF1 coeff2 :0x6000
        move    a,x:BLPG2
        move    #$0200,a                  ;Baud : Integ. coeff. :0x0200
        move    a,x:BINTGA                
        move    #$1a00,a                  ;Carrier : LPF1 coeff1 :0x1a00
        move    a,x:CARG1
        move    #$2000,a                  ;Carrier : LPF2 coeff2 :0x2000
        move    a,x:CARG2
        move    #$1000,a                  ;Carrier : Integ.coeff1:0x1000
        move    a,x:CARG3
        move    #$0400,a                  ;Carrier : Integ.coef 2:0x0400
        move    a,x:CARG4
        move    #$8000,a
        move    a,x:CD_CNT
        move    a,x:rx_ctr
        move    #0,x:err_ctr
        move    #datamd,a
        move    a,x:mode_flg              ;
        move    #RX_v22dm,a

        move    a,x:RXQ_14

End_rx_G22D
        rts 


;--------------------------------------------------------------------------
;  Mode              : V22 bis mode
;  State Description : Wait for end of s1 signal
;  State id          : 16
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RXBAUD
;                      RXS1
;                      RX_NEXT
;                      RXEQFIL
;                      RXDEC4
;                      RXEQERR
;                      RX_NEXT
;                      RXDIFDEC
;                      RXDSCR4
;                      RX_s1end
;                      ENDRX
;--------------------------------------------------------------------------
rx_GBisA
        move    #16,x:rx_st_id
        jsr     CLEQ_INIT  
        move    #$7f00,a
        move    a,x:TONS1
        move    #RX_NEXT,a
        move    a,x:RXQ_7
        move    a,x:RXQ_11
        move    #RXEQFIL,a

        move    a,x:RXQ_8
        move    #RXDEC4,a                 ;9th and 13th position in the RXQ   
        move    a,x:RXQ_9                 ;  are updated with RXDEC4 and
        move    #RXDESCR4,a               ;  RXDSCR4 to maintain the right
        move    a,x:RXQ_13                ;  RXQ when in retrain mode.
        move    #RX_s1end,a

        move    a,x:RXQ_14

End_rx_GBisA
        rts

;--------------------------------------------------------------------------
;  Mode              : V22 bis mode
;  State Description : Perform RXQ for 20ms
;  State id          : 17
;                     
;  RXQ               : RXINTP
;                        .
;                        .
;  RXQ+14          =>  RX_wait
;                      ENDRX
;--------------------------------------------------------------------------
rx_GBisB
        move    #17,x:rx_st_id
        move    #rxGBisBctr,a
        move    a,x:rx_ctr
        move    #RX_wait,a

        move    a,x:RXQ_14

End_rx_GBisB
        rts

;--------------------------------------------------------------------------
;  Mode              : V22 bis mode
;  State Description : Perform RXQ for the next 450ms
;                       If this is calling modem, transmit scrambled bin1s
;                       else first transmit s1 for 100ms & tx scr bin 1s
;  State id          : 18
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RXBAUD
;                      RXS1
;                 =>   RXCAR
;                      RXEQFIL
;                      RXDEC4
;                      RXEQERR
;                 =>   RXEQUD 
;                      RXDIFDEC
;                      RXDESCR4
;                 =>   RX_wait 
;                      ENDRX
;--------------------------------------------------------------------------
rx_GBisC
        move    #18,x:rx_st_id
        move    #$2a00,a                  ;Adjust the 9th real tap of         
        move    a,x:EQRT_8                ;  equaliser

        move    #0,x:WRPFLG
        move    #SLOWAGC,a                ;Set slow AGCGain adaptation
        move    a,x:AGCLG
        move    #10,a
        move    a,x:TRN_LNG
        move    #$4800,a                  ;Set the AGC Lowpass fiter 1&2
        move    a,x:AGCC1                 ;  coeffecients to the training
        move    #$6000,a                  ;  mode values
        move    a,x:AGCC2
        move    #$0800,a
        move    a,x:AGCC3
        move    #$7800,a
        move    a,x:AGCC4
        move    #$0,a           ;#$4000,a 2.12.96
                                          ;Set the Jitter Gain coeff. to    
        move    a,x:JITG1                 ;  training values
        move    #$0,a           ;#$0800,a 2.12.96
        move    a,x:JITG2
        tstw    x:loopback
        bne     _donotcheck1
        bftsth  #CABIT,x:rx_ans_flg    
        bcc     _notansmdm                ;If Answering modem, Effect 
        move    #1,a                      ;  state transition in the tx
        move    a,x:tx_st_chg             ;  to start trans. s1
_notansmdm                                ;In the case of calling/answering
_donotcheck1      
        move    #$8000,a                  ;  set the flag 112 to indicate
        move    a,x:flg_112               ;  the reception of s1
        move    #rxGBisCctr,a             
        move    a,x:rx_ctr
        move    #RXCAR,a

        move    a,x:RXQ_7
        move    #RXEQUD,a

        move    a,x:RXQ_11
        move    #RX_wait,a

        move    a,x:RXQ_14

End_rx_GBisC
        rts

;--------------------------------------------------------------------------
;  Mode              : V22 bis mode
;  State Description : Set up to make 16way decisions and wait for 32
;                    : consecutive ones
;  State id          : 19
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RXBAUD
;                      RXS1
;                      RXCAR
;                      RXEQFIL
;                 =>   RXDEC16
;                      RXEQERR
;                      RXEQUD 
;                      RXDIFDEC
;                 =>   RXDSCR16
;                 =>   RX_wait32bit 
;                      ENDRX
;--------------------------------------------------------------------------
rx_GBisD
        move    #19,x:rx_st_id
        move    #$0400,a                  ;Set Baud loop Integrator coeff &
        move    a,x:BINTGA                ;  the offset for the 2400bps 
        move    #$4000,a                  ;  training
        move    a,x:BOFF
        move    #$1000,a                  ;Set Carrier integrator coeff &
        move    a,x:CARG3                 ;  offset for 2400bps training
        move    #$2000,a
        move    a,x:CARG4
        move    #$8000,a                  ;Disable carrier phase wrapping
        move    a,x:WRPFLG
        move    #FASTEQUD,a               ;Set fast equaliser tap updating
        move    a,x:LUPALP
        move    #rxGBisDctr,a
        move    a,x:rx_ctr   
        move    #rxGBisDerr,a
        move    a,x:err_ctr
        move    #RXDEC16,a

        move    a,x:RXQ_9
        move    #RXDESCR16,a

        move    a,x:RXQ_13
        move    #RX_wait32bit,a

        move    a,x:RXQ_14

End_rx_GBisD
        rts

;--------------------------------------------------------------------------
;  Mode              : V22 bis mode
;  State Description : Perform RXQ till the tx allows to go the next state
;  State id          : 20
;                     
;  RXQ               : RXINTP
;                        .
;                        .
;  RXQ+14          =>  RX_waitdm
;                      ENDRX
;--------------------------------------------------------------------------
rx_GBisE
        move    #20,x:rx_st_id
        move    #$000f,a
        move    a,x:USB1PAT
        move    #$0003,a
        move    a,x:SPEED
        bfset   #V22BisCon,x:MDMSTATUS
        
        bfset   #DABIT,x:MDMSTATUS          ;Sanjay
        
        tstw    x:retctr
        bne     _for_retrn
        jsr     LAPM_MDM_INIT
_for_retrn
        move    #rxGBisEctr,a
        move    a,x:rx_ctr
        move    #RX_waitdm,a
        move    a,x:RXQ_14

End_rx_GBisE
        rts

;--------------------------------------------------------------------------
;  Mode              : V22 bis mode
;  State Description : Keep performing RXQ for 1sec checking parallely for
;                      retrain requests
;  State id          : 21
;                     
;  RXQ               : RXINTP
;                        .
;                        .
;  RXQ+14          =>  RX_wait1sec
;                      ENDRX
;--------------------------------------------------------------------------
rx_GBisF
        move    #21,x:rx_st_id
        move    #SLOWAGC,a                ;Set slow AGCGain Adaptation     
        move    a,x:AGCLG
        move    #SLOWEQUD,a               ;Set slow Equal. tap adaptation
        move    a,x:LUPALP
        move    #$1200,a                  ;Set AGC lowpass filter 1 & 2
        move    a,x:AGCC1                 ;  coefficients to data mode
        move    #$7800,a                  ;  value
        move    a,x:AGCC2
        move    #$0400,a
        move    a,x:AGCC3
        move    #$7c00,a
        move    a,x:AGCC4
        move    #$0100,a                  ;Jitter gain set for Data mode
        move    a,x:JITG1
        move    #$0800,a
        move    a,x:JITG2
        move    #$4000,a
        move    a,x:BLPG2                 ;Baud loop parameters set
        move    #$0300,a                  ;  for Data mode
        move    a,x:BINTGA
        move    #$1a00,a
        move    a,x:CARG1                 ;Carrier loop parameters set
        move    #$2000,a                  ;  for data mode
        move    a,x:CARG2
        move    #$1000,a
        move    a,x:CARG3
        move    #$0800,a
        move    a,x:CARG4
        move    #$8000,a
        move    a,x:TONS1                 ;Saturate TONS1 to neg.max to
        move    a,x:CD_CNT                ;  expect s1 signal
        move    #rxGBisFctr,a
        move    a,x:rx_ctr
        move    #RX_wait1sec,a

        move    a,x:RXQ_14
End_rx_GBisF
        rts

;--------------------------------------------------------------------------
;  Mode              : V22 bis mode
;  State Description : V22 bis data mode 
;  State id          : 22
;                     
;                     
;  RXQ               : RXINTP
;                        .
;                        .
;  RXQ+14          =>  RX_v22bisdm
;                      ENDRX
;--------------------------------------------------------------------------
rx_GBisG
        move    #22,x:rx_st_id
        move    #datamd,x0                          
        move    x0,x:mode_flg         
        move    #$0200,a
        move    a,x:BINTGA
        move    #$2000,a
        move    a,x:BOFF
        move    #$8000,a
        move    a,x:rx_ctr
        move    #0,x:err_ctr
        move    #$00c8,a
        move    a,x:RXTH
        move    #RX_v22bisdm,a

        move    a,x:RXQ_14

End_rx_GBisG
        rts


;--------------------------------------------------------------------------
;  Mode              : V22 bis Retrain mode
;  State Description : Checks performed before entering retrain mode
;  State id          : 23
;                     
;                     
;  RXQ               : RXINTP
;                      RXBPF
;                      RXDEMOD
;                      RXDECIM
;                      RXCDAGC
;                      RXBAUD
;                      RXS1
;  RXQ+14          =>  RX_retrain
;                      ENDRX
;--------------------------------------------------------------------------
rx_GRetA
        move    #23,x:rx_st_id
        move    #0,x:TX_LAPM_EN
        move    #0,x:RX_LAPM_EN
        incw    x:retctr

        move    #retrn,x:mode_flg         ;set to retrain for tx
        bfset   #LREQ,x:MDMSTATUS
        incw    x:RETRCNT                 ; The type of retrain in
        move    x:RETRCNT,a               ; MDMSTATUS has to cleared      
        move    #5,x0
        cmp     x0,a

        jle     nodisc

        bfset   #DISCON,x:MDMSTATUS       ;If the number of local retrain
                                          ;  req. exceeds the limit discon.
nodisc 

        move    #0,x:TRN_LNG
        move    #0,x:CDP
        move    #rxRetAerr,a
        move    a,x:err_ctr
        move    #RX_retrain,a             ;Set the RXQ

        move    a,x:RXQ_7
        move    #ENDRX,a

        move    a,x:RXQ_8

End_rx_GRetA
        rts

        ENDSEC
