;************************* Initialization module **************************
;
; Module name    : init_mdm
; Module authors : Sanjay S.K & V.Shyam Sundar
; Date of origin : 14 Dec '95
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;*************************** Module description ***************************
;
; This module is the initialization routine for the transmitter modem impl-
; ementation of the CCITT V.22/V.22bis standard. This module is invoked 
; before handshake operation. Subsequent initializations are carried out in 
; the state initialization routines.
;
; This module uses both x memory and p memory to initialize.
;
;************************** Calling Requirements **************************
;  
;  1. This module should be called as a subroutine as 'jsr mdm_ini '
;
;*************************** Input and Output *****************************
;
;  Input  :
;          None
;  Output :
;          Initializations of modem transmitter are carried out.
;
;******************************* Resources ********************************
;
; Address Registers used: 
;                         r1 : Points to Task and State initialization
;                              queues in linear addressing mode.
;
; Offset Registers used : 
;                          n : used as an offset register
;
; Modifier Registers used : 
;                          None
;
; Data Registers used   : x0  
;                                    
; Registers Changed     : x0  r1  sr  pc  n  
;                                     lc
; Flags                 :
;                         *ccitt_flg, *gt_flg, tx_ans_flg,
; Counters              :
;                         tx_ctr, tx_tmp
; Buffers               :
;                         TxQ(6L), StQ1(6L), StQ2(3L), cos2100(24C), 
;                         SIN_TBL(256C)
; Pointers              :
;                         StQ_ptr(L), atone_ptr(C), gtone_ptr(C)
; Memory locations      :
;                         gtamp, tx_fm_gt_offst
; Macros                :
;                         CCITT, gtenable, THREEDB, SIXDB, gttype, CALLING      
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
; Refer to the online comments
;
;**************************** Assembly Code *******************************
	
        include "txmdmequ.asm"
        include "gmdmequ.asm"

        SECTION V22B_TX
 
        GLOBAL   TX_MDM_INIT

	org     p:

TX_MDM_INIT
        move    #0,x:tx_st_id
        move    #1,x:rx_st_id
        move    #1,x:tx_st_chg
        move    #0,x:tx_data
        move    #0,x0
        move    #tx_out,r2
        rep     #12
        move    x0,x:(r2)+
        move    #0,x:tx_quad
        move    #0,x:tx_scr_buf

        move    #0,x:tx_scr_buf_1
        move    #65,x:tx_scr_ctr
        move    #$0a00,x:DC_Alpha
        move    #0,x:gtamp
        move    #tx_fm_buf,r2
        rep     #6
        move    x0,x:(r2)+
        move    #0,x:tmp_flg
        

;-----------------------------------------;
; Initialization code of ctrl module      ;
;-----------------------------------------;

_TxQ_ini                                  ;Initialize TxQ
	move    #TxQ,r1
	move    #tx_sil,x0
	move    x0,x:(r1)+
	move    #dummy,x0
	move    x0,x:(r1)+
	move    #end_tx,x0
	move    x0,x:(r1)+
	move    #tx_enc_2,x0
	move    x0,x:(r1)+
	move    #tx_fm,x0
	move    x0,x:(r1)+
	move    #end_tx,x0
	move    x0,x:(r1)+
_end_TxQ_ini
													
_StQ_ini                                  ;Initialize StQ
	move    #StQ1,r1
	move    #tx_I1,x0
	move    x0,x:(r1)+
	move    #tx_I2,x0
	move    x0,x:(r1)+
	move    #tx_I3,x0
	move    x0,x:(r1)+
	move    #tx_I4,x0
	move    x0,x:(r1)+
	move    #tx_I5,x0
	move    x0,x:(r1)+
	move    #tx_I6_1,x0
	move    x0,x:(r1)+
	move    #StQ2,r1                  ;Initialize StQ part for v22bis
	move    #tx_I6_2,x0               ;  mode
	move    x0,x:(r1)+
	move    #tx_I7_2,x0
	move    x0,x:(r1)+
	move    #tx_I8_2,x0
	move    x0,x:(r1)+
_end_StQ_ini

tx_ctrl_ini
	move    #StQ1,x0                 
	move    x0,x:StQ_ptr
end_tx_ctrl_ini

;-----------------------------------------;
; Initialization code of feeder routines  ;
;-----------------------------------------;
tx_ton_ini
	move    #cos2100,x0
	move    x0,x:atone_ptr            ;Save answering tone pointer
end_tx_ton_ini                        ;

tx_fm_ini                             ;Initialize tx_fm 
	move    #20,n                     ;Initialize offset for 562.5 Hz
                                      ;  guard tone.
	move    #SIN_TBL,x0
	move    x0,x:gtone_ptr            ;Initialize guard tone pointer
	bftsth  #CCITT,x:ccitt_flg        ;Check for CCITT modem
	jcc     ERROR                     ;Exit to error routine if not a
                                      ;  CCITT modem
	bftsth  #gtenable,x:gt_flg        ;Check Guard tone flag register
	bcc     end_tx_fm_ini             ;If guard tone disabled goto end
	move    #THREEDB,x0
	move    x0,x:gtamp                ;Initialize guard tone amplitude
                                      ;  for 562.5 Hz guard tone
	bftsth  #gttype,x:gt_flg          ;Check modem type (1800 Hz GTone
                                      ;  or 562.5 Hz GTone)
	bcc     setoffset                 ;If Type corresponds to guard
	move    #SIXDB,x0
	move    x0,x:gtamp                ;If 1800 Hz guard tone 
                                      ;  amplitude = '12'
	move    #64,n                     ;Set offset for 1800 Hz guard
                                      ;  tone
setoffset
	move    n,x:tx_fm_gt_offset       ;Store offset pointer
end_tx_fm_ini                             

    bftsth  #CABIT,x:tx_ans_flg
    jcs     startina


	
;   /*  Time of execution for various states in the calling modem  */

startinc
	move    #-1,x0                     
	move    x0,x:txI1ctr              ; - (Wait for rx'er to
                                      ;    change the state)
	move    #1,x0
	move    x0,x:txI2ctr              ;One loop of changeover
	move    #274,x0                   ;#274           
	move    x0,x:txI3ctr              ;456 ms (Silence)
	move    #1,x0
	move    x0,x:txI4ctr              ;One loop of changeover
	move    #rx_timeout,x0
	move    x0,x:txI51ctr             ;Invalid state
	move    #60,x0
	move    x0,x:txI52ctr             ;100 ms (S1 signal - v22bis) 
	move    #-1,x0
	move    x0,x:txI61ctr             ; - (Data transmit - v22) 
	move    #-1,x0
	move    x0,x:txI62ctr             ; - (Set by tx_wr16)
	move    #120,x0                   
	move    x0,x:txI72ctr             ;200 ms (Scr. ones at 2400 bps)
	move    #-1,x0
	move    x0,x:txI82ctr             ; - (Data transmit - v22bis)
					 
	move    #0,x:gtamp                ;Disable gurd tone
	move    #tx_fm_coef_low,x0        ;Load pointer to filter coeffs.
	move    x0,x:tx_fm_coef           
	jmp     End_TX_MDM_INIT

;   /*  Time of execution for various states in the answering modem  */

startina
	move    #1290,x0                  ;#1290
	move    x0,x:txI1ctr              ;2150 ms (Silence)
	move    #1980,x0                  ;#1980
	move    x0,x:txI2ctr              ;3300 ms (Answering tone)
	move    #45,x0                    ;#45
	move    x0,x:txI3ctr              ;75 ms (Silence)
	move    #-1,x0              
	move    x0,x:txI4ctr              ; - (Unscr. ones)
	move    #459,x0
	move    x0,x:txI51ctr             ;765 ms (Scr. ones - v22)
	move    #60,x0
	move    x0,x:txI52ctr             ;100 ms (S1 signal - v22bis) 
	move    #-1,x0
	move    x0,x:txI61ctr             ; - (Data transmit - v22) 
	move    #300,x0                   ;#300
	move    x0,x:txI62ctr             ;500 ms (Scr. bin ones)
	move    #120,x0
	move    x0,x:txI72ctr             ;200 ms (Scr. ones at 2400 bps)
	move    #-1,x0
	move    x0,x:txI82ctr             ; - (Data transmit - v22bis)

	move    #tx_fm_coef_high,x0       ;Load pointer to filter coeffs.
	move    x0,x:tx_fm_coef

End_TX_MDM_INIT
	rts
;****************************** End of file *******************************

    ENDSEC
