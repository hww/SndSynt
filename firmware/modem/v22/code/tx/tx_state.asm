;******************************** Module **********************************
;
;  Module Name     : tx_state
;  Author          : Abhay Sharma, V.Shyam Sundar, Sanjay S. K.
;  Date of origin  : 17 Dec 95
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;*************************** Module Description ***************************
;
;  This module describes the state initializations for each state. This
;  module is invoked by the controller module every time a state transition 
;  takes place. It performs following actions :
;
;  1. Sets state_id and (optional) flags.
;  2. (Optional) Check Flags, on error, set tx_ctr to rx_timeout and 
;     abort to tx_ctrl.
;  3. Sets tx_ctr - a counter to terminate the timed events.
;  4. Initializes variables and pointers for the state.
;  5. Sets up the transmitter task queue for each state.
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
;              state_id = | 0000 0000 | 0000 nnnn | in x:tx_st_id
;                                     nnnn = state number
;              flg_xxx  = | i000 0000 | 0000 0000 | in x:flg_xxx
;                            where xxx denotes the flag number as
;                            per specifications of CCITT
;
;******************************* Resources ********************************
;
;                               Cycle Count       Program words 
;
;     tx_I1                :        12                 8
;     tx_I2                :        25                 21
;     tx_I3                :        14                 10
;     tx_I4                :        23                 19
;     tx_I5                :        25                 36
;     tx_I61               :        19                 15
;     tx_I62               :        22                 18
;     tx_I72               :        25                 21
;     tx_I82               :        14                 10
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
;  Counters               :
;                          txI1ctr, txI2ctr, txI3ctr, tcI4ctr, txI51ctr,
;                          txI52ctr, txI61ctr, txI62ctr, txI72ctr,txI82ctr,
;                          tx_ctr, tx_tmp
;  Buffers                :
;                          TxQ(6L), StQ2(3L)
;  Pointers               :
;                          StQ_ptr(L)
;  Memory locations       :
;                          tx_tmp
;  Macros                 :
;                          CALLING, datamd      
;                    
; ** Note :  1. 'L' refers to Linear buffer/pointer to linear buffer
;            2. '*' - memory location is any one of the first 64 locations
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

       include "gmdmequ.asm"

       SECTION V22B_TX 


       GLOBAL  tx_I1
       GLOBAL  tx_I2
       GLOBAL  tx_I3
       GLOBAL  tx_I4
       GLOBAL  tx_I5
       GLOBAL  tx_I6_1
       GLOBAL  tx_I6_2
       GLOBAL  tx_I7_2
       GLOBAL  tx_I8_2

       org     p:

;-----------------------------------------+--------------------------------
; Mode      : ANSWERING                   | Mode    : CALLING
; State     : silence                     | State   : silence
; Time      : 2150 ms                     | Time    : rx'er terminated
;-----------------------------------------+--------------------------------
;                       Description : Fills tx_out with zeros
;
;  Note : The module init_mdm should be executed before calling this module
;
;-----------------------------------------+--------------------------------
; TxQ       :                             ; TxQ     :
;               +----------+              ;
;               | tx_sil   |              ;
;               +----------+              ;
;               | dummy    |              ;
;               +----------+              ;         Same as answering
;               | end_tx   |              ;
;               +----------+              ;
;-----------------------------------------+--------------------------------
tx_I1                                     ;TxQ is initialised in init_mdm
                                          ;  modulo for I1
	move    #$0001,x0                     ;
	move    x0,x:tx_st_id                 ;Set state id
	move    x:txI1ctr,x0                  ;CALLING   : Set up for event
	move    x0,x:tx_ctr                   ;  termination by the rx'er
                                          ;ANSWERING : Set up time of exec
                                          ;  to 2150 ms
end_tx_I1
	rts                                   ;Return to the controller module

;-----------------------------------------+--------------------------------
; Mode      : ANSWERING                   | Mode    : CALLING
; State     : Tone of 2100 Hz             | State   : Disabled
; Time      : 3300 ms                     | Time    :    -
;-----------------------------------------+--------------------------------
;                  Description : Fills tx_out with answering tone 
;-----------------------------------------+--------------------------------
; TxQ       :                             ; TxQ     :
;               +----------+              ;
;               | tx_a_ton |              ;
;               +----------+              ;
;               | dummy    |              ;
;               +----------+              ;
;               | end_tx   |              ;              None
;               +----------+              ;
;-----------------------------------------+--------------------------------
tx_I2
	move    #$0002,x0
	move    x0,x:tx_st_id             ;Set state id
	move    x:txI2ctr,x0              ;CALLING   : Disabled
	move    x0,x:tx_ctr               ;ANSWERING : Set the time of exec 
                                      ;  to 3300 ms
	move    x:tx_ans_flg,x0           ;Get answering mode flag
	bftstl  #CABIT,x0                 ;Check for answering mode
	bcs     end_tx_I2                 ;Jump to next state init. if in
                                      ;  calling mode
	move    #271,x0
	move    x0,x:tx_tmp               ;Set tmp counter to count down
                                      ;  450 ms.(for phase inversion 
                                      ;  in module tx_a_ton)
	move    #TxQ,r1                   ;Load address of TxQ
	move    #tx_a_ton,x0              ;Load the TxQ
	move    x0,x:(r1)+                ;
end_tx_I2
	rts                               ;Return to controller module

;-----------------------------------------+--------------------------------
; Mode      : ANSWERING                   | Mode    : CALLING
; State     : silence                     | State   : silence
; Time      : 75 ms                       | Time    : 456 ms
;-----------------------------------------+--------------------------------
;                       Description : Fills tx_out with zeros    
;-----------------------------------------+--------------------------------
; TxQ       :                             ; TxQ     :
;               +----------+              ;
;               | tx_sil   |              ;
;               +----------+              ;
;               | dummy    |              ;
;               +----------+              ;
;               | end_tx   |              ;         same as answering
;               +----------+              ;
;-----------------------------------------+--------------------------------
tx_I3
	move    #$0003,x0
	move    x0,x:tx_st_id             ;Set state id
	move    x:txI3ctr,x0              ;
	move    x0,x:tx_ctr               ;CALLING   : Set time of exec to
                                      ;  465 ms
                                      ;  ANSWERING : Set time of exec
                                      ;  to 75 ms.
	move    #TxQ,r1                   ;Load address of TxQ   
	move    #tx_sil,x0                ;Load the TxQ
	move    x0,x:(r1)+                ;
end_tx_I3
	rts                               ;Return to controller module

;-----------------------------------------+--------------------------------
; Mode      : ANSWERING                   | Mode    : CALLING
; State     : unscr. bin. ones at 1200 bps| State   : Disabled
; Time      : terminated by rx'er         | Time    :    -
;-----------------------------------------+--------------------------------
; Description :Unscr. bin. ones are encoded(2 bits/baud) & filter modulated
;-----------------------------------------+--------------------------------
; TxQ       :                             ; TxQ     :
;               +----------+              ;
;               | tx_wr4   |              ;
;               +----------+              ;
;               | tx_one_2 |              ;
;               +----------+              ;
;               | dummy    |              ;              none
;               +----------+              ;
;               | tx_enc_2 |              ;
;               +----------+              ;
;               | tx_fm    |              ;
;               +----------+              ;
;               | end_tx   |              ;
;               +----------+              ;
;-----------------------------------------+--------------------------------
tx_I4
	move    #$0004,x0
	move    x0,x:tx_st_id             ;Set state id
	move    x:txI4ctr,x0              ;CALLING   : disabled
	move    x0,x:tx_ctr               ;ANSWERING : Set up for event
                                      ;  termination by rx'er
	move    x:tx_ans_flg,x0           ;Get answering mode flag
	bftstl  #CABIT,x0                 ;Check for answering mode
	bcs     end_tx_I4                 ;Jump to next state init. if in
                                      ;  calling mode
	move    #$8000,x:flg_107          ;Set flag 107 on.
	move    #6,x0
	move    x0,x:tx_tmp               ;Load tmp counter to count down
                                      ;  8 ms( for module tx_wr4 )
	move    #TxQ,r1                   ;Load address of TxQ
	move    #tx_wr4,x0                ;Load TxQ
	move    x0,x:(r1)+                ;
	move    #tx_one_2,x0              ;
	move    x0,x:(r1)+                ;
	move    #dummy,x0                 ;
	move    x0,x:(r1)+                ;
end_tx_I4
	rts                               ;Return to controller module

;-----------------------------------------+--------------------------------
; Mode      : ANSWERING                   | Mode    : CALLING
; State     : scr. bin. ones at 1200 bps  | State   : S1 at 1200 bps
;                    OR   S1 at 1200 bps  |
; Time      : 765 ms OR   100 ms          | Time    : 100 ms
;-----------------------------------------+--------------------------------
;      Description : bin. ones are scrambled, encoded(2 bits/baud) and 
;                            filter modulated
;-----------------------------------------+--------------------------------
; TxQ       :                    (v22)    ; TxQ     :
;               +----------+              ;
;               | dummy    |              ;
;               +----------+              ;
;               | tx_one_2 |              ;
;               +----------+              ;
;               | tx_scr_2 |              ;
;               +----------+              ;
;               | tx_enc_2 |              ;
;               +----------+              ;
;               | tx_fm    |              ;
;               +----------+              ;
;               | end_tx   |              ;
;               +----------+              ;       same as v22 bis TxQ 
;-----------------------------------------;       of answering mode
; TxQ         :                  (v22bis) ;
;               +----------+              ;
;               | tx_s1    |              ;
;               +----------+              ;
;               | dummy    |              ;
;               +----------+              ;
;               | dummy    |              ;
;               +----------+              ;
;               | tx_enc_2 |              ;
;               +----------+              ;
;               | tx_fm    |              ;
;               +----------+              ;
;               | end_tx   |              ;
;               +----------+              ;
;-----------------------------------------+--------------------------------
tx_I5
	move    #$0005,x0
	move    x0,x:tx_st_id             ;Set state id
	move    x:tx_ans_flg,x0           ;Get answering mode flag
	bftstl  #CABIT,x0                 ;Check for answering mode
	bcs     _v22bis                   ;Jump to v22 bis mode for calling
                                      ;  mode handshake
	tstw    x:flg_112                 ;Check calling modem mode
                                      ;  (V22 or V22bis)
	beq     _v22                      ;Switch to v22 mode of operation
                                      ;  if flag 112 not set
_v22bis                               ;
	move    x:txI52ctr,x0             ;
	move    x0,x:tx_ctr               ;Set the time of execution to
                                      ;  100 ms.
	move    #0,x:tx_tmp               ;Set tmp to 0(for module tx_s1)
                                      ;  x:tx_tmp is used as a scratch
                                      ;  location
	move    #StQ2,x0                  ;Load address of v22 bis states
	move    x0,x:StQ_ptr              ;Save address in stack
	move    #TxQ,r1                   ;Load address of TxQ
	move    #tx_s1,x0                 ;Load TxQ
	move    x0,x:(r1)+                ;
	move    #dummy,x0                 ;Dummy operation
	move    x0,x:(r1)+                ;
	move    x0,x:(r1)+                ;
	rts                               ;Return to controller module
_v22                                      ;
	move    x:txI51ctr,x0             ;
	move    x0,x:tx_ctr               ;ANSWERING : Set the time of 
                                      ;  execution to 765 ms.
                                      ;CALLING   : Invalid state
	move    #TxQ,r1                   ;Load address of TxQ
	move    #dummy,x0                 ;dummy operation
	move    x0,x:(r1)+                ;
	move    #tx_one_2,x0              ;Load TxQ
	move    x0,x:(r1)+                ;
	move    #tx_scr_2,x0              ;
	move    x0,x:(r1)+                ;
end_tx_I5
	rts                               ;Return to controller module

;-----------------------------------------+--------------------------------
; Mode      : ANSWERING                   | Mode    : CALLING
; State     : transmit data at 1200 bps   | State   : transmit data at
;                                         |           1200 bps
; Time      :           -                 | Time    :      -
;-----------------------------------------+--------------------------------
; Description : data is scrambled, encoded(2 bits/baud) & filter modulated
;-----------------------------------------+--------------------------------
; TxQ       :   ( V.22bis fall back to    ; TxQ     :
;        +----------+              ;
;               | tx_scr_2 |              ;      same as answering mode
;               +----------+              ;
;               | tx_enc_2 |              ;
;               +----------+              ;
;               | tx_fm    |              ;
;               +----------+              ;
;               | end_tx   |              ;
;               +----------+              ;
;-----------------------------------------+--------------------------------
tx_I6_1
	move    #$0006,x0
	move    x0,x:tx_st_id             ;Set state id
	move    #$8000,x:flg_106          ;Assert flag 106 high
	move    #0,x:flg_104              ;Assert flag 104 low
	move    #datamd,x:mode_flg        ;Set mode to data mode
    move    #1,x:RX_LAPM_EN
    move    #1,x:TX_LAPM_EN
	move    #$8000,x:flg_109          ;Check for flag 109
	move    x:txI61ctr,x0             ;CALLING   : Set for data trans-
                                      ;  mission
	move    x0,x:tx_ctr               ;ANSWERING : Set for data trans-
                                      ;  mission
	move    #TxQ,r1                   ;Load the address of TxQ
	move    #dummy,x0                 ;Load TxQ
	move    x0,x:(r1)+
	move    #tx_in_2,x0               
	move    x0,x:(r1)+                
end_tx_I6_1
	rts                               ;Return to controller module

;-----------------------------------------+--------------------------------
; Mode      : ANSWERING                   | Mode    : CALLING
; State     : scr. bin. 1s at 1200 bps    | State   : scr. bin 1s at
;                                         |           1200 bps
; Time      : terminated by tx controller | Time    : terminated by tx ctrl
;-----------------------------------------+--------------------------------
; Description : scr. bin. 1s, encoded(2 bits/baud) & filter modulated
;-----------------------------------------+--------------------------------
; TxQ       :                             ; TxQ     :
;               +----------+              ;
;               | tx_decide|              ;
;               +----------+              ;
;               | tx_one_2 |              ;
;               +----------+              ;
;               | tx_scr_2 |              ;      same as answering mode
;               +----------+              ;
;               | tx_enc_2 |              ;
;               +----------+              ;
;               | tx_fm    |              ;
;               +----------+              ;
;               | end_tx   |              ;
;               +----------+              ;
;-----------------------------------------+--------------------------------
tx_I6_2
	move    #$0006,x0
	move    x0,x:tx_st_id             ;Set state id
	move    x:txI62ctr,x0             ;CALLING   : Set state termin. by
	move    x0,x:tx_ctr               ;  tx controller
                                      ;ANSWERING : Set state termin. by
                                      ;  tx controller
	move    #TxQ,r1                   ;Load the address of TxQ
	move    #tx_decide,x0             ;Load TxQ
	move    x0,x:(r1)+                ;
	move    #tx_one_2,x0              ;
	move    x0,x:(r1)+                ;
	move    #tx_scr_2,x0              ;
	move    x0,x:(r1)+                ;
end_tx_I6_2
	rts                               ;Return to controller module

;-----------------------------------------+--------------------------------
; Mode      : ANSWERING                   | Mode    : CALLING
; State     : scr. bin. 1s at 2400 bps    | State   : scr. bin 1s at
;                                         |           2400 bps
; Time      : 200 ms                      | Time    : 200 ms
;-----------------------------------------+--------------------------------
; Description : data is scrambled, encoded(4 bits/baud) & filter modulated
;-----------------------------------------+--------------------------------
; TxQ       :                             ; TxQ     :
;               +----------+              ;
;               | dummy    |              ;
;               +----------+              ;
;               | tx_one_4 |              ;
;               +----------+              ;
;               | tx_scr_4 |              ;      same as answering mode
;               +----------+              ;
;               | tx_enc_4 |              ;
;               +----------+              ;
;               | tx_fm    |              ;
;               +----------+              ;
;               | end_tx   |              ;
;               +----------+              ;
;-----------------------------------------+--------------------------------
tx_I7_2
	move    #$0007,x0
	move    x0,x:tx_st_id             ;Set state id
	move    x:txI72ctr,x0             ;CALLING   : Set time of exec. to
	move    x0,x:tx_ctr               ;  200 ms
                                      ;ANSWERING : Set time of exec. to
                                      ;  200 ms
	move    #TxQ,r1                   ;Load the address of TxQ+1
	move    #dummy,x0                 ;Load TxQ
	move    x0,x:(r1)+                ;
	move    #tx_one_4,x0              ;
	move    x0,x:(r1)+                ;
	move    #tx_scr_4,x0              ;
	move    x0,x:(r1)+                ;
	move    #tx_enc_4,x0              ;
	move    x0,x:(r1)+                ;
end_tx_I7_2
	rts                               ;Return to controller module

;-----------------------------------------+--------------------------------
; Mode      : ANSWERING                   | Mode    : CALLING
; State     : transmit data at 2400 bps   | State   : transmit data at
;                                         |           2400 bps
; Time      :           -                 | Time    :      -
;-----------------------------------------+--------------------------------
; Description : data is scrambled, encoded(4 bits/baud) & filter modulated
;-----------------------------------------+--------------------------------
; TxQ       :                             ; TxQ     :
;               +----------+              ;
;               | dummy    |              ;
;               +----------+              ;
;               | tx_in_4  |              ;
;               +----------+              ;
;               | tx_scr_4 |              ;      same as answering mode
;               +----------+              ;
;               | tx_enc_4 |              ;
;               +----------+              ;
;               | tx_fm    |              ;
;               +----------+              ;
;               | end_tx   |              ;
;               +----------+              ;
;-----------------------------------------+--------------------------------
tx_I8_2
	move    #$0008,x0
	move    x0,x:tx_st_id             ;Set state id
	move    #$8000,x:flg_106          ;Assert flag 106 high
    move    #1,x:RX_LAPM_EN
    move    #1,x:TX_LAPM_EN
	move    #0,x:flg_104              ;Assert flag 104
	move    #datamd,x:mode_flg        ;Set to data mode
	move    x:txI82ctr,x0             ;CALLING   : Set infinite time
	move    x0,x:tx_ctr               ;ANSWERING : Set infinite time

    move    #TxQ_1,r1                 ;Load the address of TxQ+1
                                      ;  TxQ -> dummy operation
	move    #tx_in_4,x0               ;Load TxQ 
	move    x0,x:(r1)+                ;
	rts                               ;Return to controller module
end_tx_I8_2

;**************************** Module ends *********************************

    ENDSEC
