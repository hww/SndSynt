          
           SECTION TX_MEM

           GLOBAL   TXMEMB
           GLOBAL   txI1ctr
           GLOBAL   txI2ctr
           GLOBAL   txI3ctr
           GLOBAL   txI4ctr
           GLOBAL   txI51ctr
           GLOBAL   txI52ctr
           GLOBAL   txI61ctr
           GLOBAL   txI62ctr
           GLOBAL   txI72ctr
           GLOBAL   txI82ctr
           GLOBAL   mdm_flg
           GLOBAL   gt_flg
           GLOBAL   ccitt_flg
           GLOBAL   tx_ans_flg
           GLOBAL   tx_rx16
           GLOBAL   atone_ptr
           GLOBAL   tx_data
           GLOBAL   tx_out
           GLOBAL   Ftx_out
           GLOBAL   tx_quad
           GLOBAL   Ival
           GLOBAL   Qval
           GLOBAL   tx_scr_buf
           GLOBAL   tx_scr_buf_1
           GLOBAL   tx_scr_ctr
           GLOBAL   gtamp
           GLOBAL   gtone_ptr
           GLOBAL   tx_fm_buf
           GLOBAL   tx_fm_coef
           GLOBAL   tx_fm_gt_offset
           GLOBAL   tx_ctr
           GLOBAL   tx_tmp
           GLOBAL   tmp_flg
           GLOBAL   tx_st_chg
           GLOBAL   TxQ
           GLOBAL   TxQ_1
           GLOBAL   TxQ_2
           GLOBAL   TxQ_3
           GLOBAL   TxQ_4
           GLOBAL   TxQ_5
           GLOBAL   StQ1
           GLOBAL   StQ1_1
           GLOBAL   StQ1_2
           GLOBAL   StQ1_3
           GLOBAL   StQ1_4
           GLOBAL   StQ1_5
           GLOBAL   StQ2
           GLOBAL   StQ_ptr
           GLOBAL   TxQ_ptr
           GLOBAL   TXMEMSIZE
           GLOBAL   DC_Alpha
           GLOBAL   DC_Tap
           GLOBAL   DC_Tap_Scaled
           GLOBAL   DC_Error

;----------------------------------------------------------------------

           org x:

;-----------------------------------------;
; Storage allocation for time counters    ;
;-----------------------------------------;
txI1ctr         ds           1
TXMEMB          equ          txI1ctr
txI2ctr         ds           1
txI3ctr         ds           1
txI4ctr         ds           1
txI51ctr        ds           1
txI52ctr        ds           1
txI61ctr        ds           1
txI62ctr        ds           1
txI72ctr        ds           1
txI82ctr        ds           1
 
;-----------------------------------------;
;Initializations of flags                 ;
;-----------------------------------------;
mdm_flg         ds           1            ;Modem is set to V22bis/v22mode
gt_flg          ds           1            ;The gaurd tone status register 
                                          ;  gt_flg=| xxxx xxxx xxxx xxTG |
                                          ; T = 0; 562.5 Hz guard tone
                                          ; T = 1; 1800 Hz guard tone
                                          ; G = 1; Guard tone enable
ccitt_flg       ds           1            ;Initialize modem as CCITT type
tx_ans_flg      ds           1            ;Flag to denote calling/ans  mode
tx_rx16         ds           1            ;Flag to indicate 16 way decision
                                          ;  enabled(in rx'er) set by tx'er
;-----------------------------------------;
; Initializations of feeder variables     ;
;-----------------------------------------;

;tx_a_ton initializations
;------------------------
atone_ptr       ds           1            ;Pointer to answering tone table
tx_data         ds           1            ;Input memory location
tx_out          ds           12           ;Output buffer
Ftx_out         equ          tx_out       ;For C interface

;tx_enc initializations
;----------------------
tx_quad         ds           1            ;Quadrant number of input
Ival            ds           1
Qval            ds           1

;tx_scr initializations
;----------------------
tx_scr_buf      ds           2            ;Scrambler state buffer
tx_scr_buf_1    equ          tx_scr_buf+1

tx_scr_ctr      ds           1            ;Counter of 64 1's

;tx_fm initializations
;---------------------
gtamp           ds           1            ;Amplitude of the guard tone
gtone_ptr       ds           1            ;Pointer to the guard tone table
tx_fm_buf       ds           6            ;Buffer of inputs
tx_fm_coef      ds           1            ;Pointer to the filter coeff.
                                          ;  table
tx_fm_gt_offset ds           1            ;Offset to the 256 point
                                          ;  guard tone table

;-----------------------------------------;
; Storage allocation for ctrl variables   ;
;-----------------------------------------;
tx_ctr          ds           1            ;Timer for each state
tx_tmp          ds           1            ;Scratch memory loction
tmp_flg         ds           1
tx_st_chg       ds           1            ;Tx State change flag initialized
                                          ;  to denote a change
;-----------------------------------------;
; Storage allocation for Queues           ;
;-----------------------------------------;
TxQ             ds           6            ;The task queue comprising a
TxQ_1           equ          TxQ+1
TxQ_2           equ          TxQ+2
TxQ_3           equ          TxQ+3
TxQ_4           equ          TxQ+4
TxQ_5           equ          TxQ+5
                                          ;  state
StQ1            ds           6            ;The state queue describing the
                                          ;  different states of a V22 mode
                                          ;  answering modem

StQ1_1          equ          StQ1+1
StQ1_2          equ          StQ1+2
StQ1_3          equ          StQ1+3
StQ1_4          equ          StQ1+4
StQ1_5          equ          StQ1+5


StQ2            ds           3            ;The state queue describing the
                                          ;  different states of a V22bis
                                          ;  mode answering modem
StQ_ptr         ds           1            ;Storage location for state init-
                                          ;  ialisation pointer
TxQ_ptr         ds           1            ;Storage location for task queue
                                          ;  pointer
                                          ;

TXMEME          equ          *

TXMEMSIZE       dc          TXMEME-TXMEMB

DC_Alpha        ds           1  
DC_Tap          ds           1 
DC_Tap_Scaled   ds           1
DC_Error        ds           1

         ENDSEC
