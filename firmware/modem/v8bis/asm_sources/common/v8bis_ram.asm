;***********************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : v8bis_ram.asm
;
; PROGRAMMER           : Binuraj K.R.
;
; DATE CREATED         : 1/4/1998
;
;**********************MODULE  DESCRIPTION ******************************
; Description:	This file  contains the memory definitions ( ds )
;		for V.21 Modem and DTMF detection Modules. 
;
;*************************** Revision History *****************************
;
;  Date         Person             Change
;  ----         ------             ------
;  01/4/1998    Binuraj K.R.       Collated all the rom files and created this
;                                  file
;  24/4/1998    Minati             Added new variables for V21 Demodulation
;
;  04/6/1998    Varadarajan G      Added ram locations for v21 state machine
;
;  12/6/1998    Varadarajan G      Added ram locations for v21 agcg and cd
;
;  17/6/1998    Varadarajan G      Added ram locations for Ssi isr
;
;  03/7/2000    N R Prasad         Ported on to Metrowerks; changed XDEF's
;                                  to GLOBAL.
;  
;------------------------------------------------------------------------------


        SECTION v21_mod_ram 

;****************************************************************************

        GLOBAL    tx_sinetable_len
        GLOBAL    tx_sinetable_ptr
        GLOBAL    index_inc0
        GLOBAL    index_inc1 
        GLOBAL    rx_sinetable_len
        GLOBAL    rx_sinetable_ptr
        GLOBAL    fs_rl_buf 
        GLOBAL    fs_im_buf
        GLOBAL    lpfout_rl_buf 
        GLOBAL    lpfout_im_buf
        GLOBAL    lpfst_rl_buf
        GLOBAL    lpfst_im_buf
        GLOBAL    lpfst_rl_buf_ptr
        GLOBAL    lpfst_im_buf_ptr
        GLOBAL    divout_buf
        GLOBAL    avgout_buf 
        GLOBAL    zero_cross_ptr 
        GLOBAL    zero_cross_index
        GLOBAL    sampling_ptr
        GLOBAL    tau
        GLOBAL    first_zero_cross 
        GLOBAL    cos_index
        GLOBAL    sine_index
        GLOBAL    avgout_buf_ptr
        GLOBAL    decision_buf 
        GLOBAL    v21_cdflag
        GLOBAL    v21_rxctr
        GLOBAL    v21_rxstchg
        GLOBAL    v21_rxstid
        GLOBAL    v21_rxq
        GLOBAL    v21_rxq_ptr
        GLOBAL    v21_rxsti_ptr
        GLOBAL    v21_agcg
        GLOBAL    v21_acenergy
        GLOBAL    baud_enrg
        GLOBAL    V8BIS_MEM_BGN_1
        GLOBAL    V8BIS_MEM_LEN_1
        
        ORG  x:


v21_mod_ram

;***********************************************************************
;*
;* Variables used in V21 Modulation
;*
;***********************************************************************

tx_sinetable_len     ds     1
V8BIS_MEM_BGN_1       equ    tx_sinetable_len
tx_sinetable_ptr     ds     1
index_inc1           ds     1
index_inc0           ds     1

;***********************************************************************
;*
;* Variables used in V21 Demodulation
;*
;***********************************************************************

rx_sinetable_len    ds     1
rx_sinetable_ptr    ds     1  
fs_rl_buf           ds     24 
fs_im_buf           ds     24
lpfout_rl_buf       ds     13 
lpfout_im_buf       ds     13
lpfst_rl_buf        dsm    3
lpfst_im_buf        dsm    3
lpfst_rl_buf_ptr    ds     1
lpfst_im_buf_ptr    ds     1
divout_buf          ds     17
avgout_buf          dsm    36
decision_buf        ds     2
zero_cross_index    ds     1
zero_cross_ptr      ds     1 
sampling_ptr        ds     1
tau                 ds     1       
first_zero_cross    ds     1
cos_index           ds     1
sine_index          ds     1
avgout_buf_ptr      ds     1
 
;***********************************************************************
;*
;* Variables used in V21 Receiver state machine
;*
;***********************************************************************

v21_cdflag      ds           1
v21_rxctr       ds           1
v21_rxstchg     ds           1
v21_rxstid      ds           1
v21_rxq         ds           5
v21_rxq_ptr     ds           1
v21_rxsti_ptr   ds           1
v21_agcg        ds           1 

;***********************************************************************
;*
;* Variables used in V21 Receiver state machine
;*
;***********************************************************************

v21_acenergy    ds           2
baud_enrg       ds           2
V8BIS_MEM_END_1       equ     *
V8BIS_MEM_LEN_1      equ     V8BIS_MEM_END_1-V8BIS_MEM_BGN_1
        endsec
        
;****************************************************************************
;
; Variables used for single tone and dual tone detection 
;
;****************************************************************************
        SECTION ToneDet_Common_Variable 
        GLOBAL    sig_energy
        GLOBAL    coeff_ptr 
        GLOBAL    HPF_mscratch 
        GLOBAL    no_of_filter
        GLOBAL    ana_buf
        GLOBAL    shift_count
        GLOBAL    dtmf_level
        GLOBAL    sik
        GLOBAL    loop_cntr
        GLOBAL    mg_energy
        GLOBAL    pk_add
        GLOBAL    mg_fil_coeff
        GLOBAL    Dtmf_mg_fil_coeff
        GLOBAL    Stf_mg_fil_coeff
        GLOBAL    V8BIS_MEM_BGN_2
        GLOBAL    V8BIS_MEM_LEN_2
        
        
        org     x:  

sig_energy      ds           4*1          ;Signal energy expressed
                                          ; in Double precision
V8BIS_MEM_BGN_2    equ      sig_energy
coeff_ptr       ds           1 
	
no_of_filter    ds           1        
        
ana_buf         ds           144          ;Analysis Buffer of size   
                                          ; equal to Ns
shift_count     ds           1            ;Sample Normalising count

dtmf_level      ds           2            ;absolute detection threshold 

loop_cntr	ds	     1            ;general purpose loop counter

mg_energy       ds           12           ;Buffer for energy of MG filters 
pk_add          ds           4 

mg_fil_coeff    ds           6            ;buffer used to copy X-Rom 
                                          ;  values to X-Ram.
Dtmf_mg_fil_coeff   equ          mg_fil_coeff 
Stf_mg_fil_coeff    equ          mg_fil_coeff
  
sik             dsm          12           ;Buffer for MG filter states 
					  ;  channels 
					  ;  2*NO_FIL locations per channel 
HPF_mscratch    ds      9
                                          ;scratch buffer for HPF
                                          ;  coefficients sinse it is to
                                          ;  be moved from p-rom to x-ram 
V8BIS_MEM_END_2    equ    *
V8BIS_MEM_LEN_2   equ    V8BIS_MEM_END_2-V8BIS_MEM_BGN_2

        ENDSEC

        SECTION V8bis_Codec
        GLOBAL  Fcodec_tx_buffer
        GLOBAL  Fcodec_rx_buffer
        GLOBAL  Fv8_ssi_rxctr
        GLOBAL  Fv8_ssi_txctr
        
        GLOBAL  Fcodec_tx_rptr           
        GLOBAL  codec_tx_rptr             

        GLOBAL  Fg_codec_tx_buf_ptr
        GLOBAL  codec_tx_wptr 

        GLOBAL  Fcodec_rx_wptr 
        GLOBAL  codec_rx_wptr

        GLOBAL  Fg_codec_rx_buf_ptr
        GLOBAL  codec_rx_rptr

        GLOBAL  Fv8_txgain

        org     x:
;**********************************
; ISR Buffers
;**********************************       
                                         
Fcodec_tx_buffer    dsm   144*2           ;ISR  transmit double buffer of 288
                                          ; Locations
Fcodec_rx_buffer    dsm   144*2           ;ISR receive double buffer of 288
                                          ; Locations
Fv8_ssi_rxctr       ds    1               ;samples / frame or baud for Rx
Fv8_ssi_txctr       ds    1               ;  -- ditto --  for Tx

codec_tx_rptr       ds    1               ;Read  pointer for codec_tx_buffer
Fcodec_tx_rptr      equ   codec_tx_rptr

codec_tx_wptr       ds    1               ;Write pointer for codec_tx_buffer
Fg_codec_tx_buf_ptr equ   codec_tx_wptr

codec_rx_wptr       ds    1               ;Write pointer for codec_rx_buffer
Fcodec_rx_wptr      equ   codec_rx_wptr

codec_rx_rptr       ds    1               ;Read  pointer for codec_rx_buffer
Fg_codec_rx_buf_ptr equ   codec_rx_rptr

Fv8_txgain          ds    1               ;Tx gain factor

        ENDSEC

;*************************************************************************
;
;  Variables used for Single Tone and Dual Tone  Generation
;
;*************************************************************************

        SECTION ToneGen_Common_Variable
        GLOBAL    sl1
        GLOBAL    sl2
        GLOBAL    sh1
        GLOBAL    sh2
        GLOBAL    al_2
        GLOBAL    ah_2

        org     x:
sl1             ds           1            ;local variables used in
sl2             ds           1            ; dual_tone and single_tone
sh1             ds           1            ; modules
sh2             ds           1
al_2            ds           1
ah_2            ds           1

        ENDSEC


;**********************************************
; Initialization all memory locations to zeros
;**********************************************

        SECTION V8BIS_IS_RS_INIT GLOBAL

        GLOBAL  FV8bis_Init_to_Zero
        
        
FV8bis_Init_to_Zero:
       
       move     #0,y0
       move     #V8BIS_MEM_BGN_1,r0
       move     #V8BIS_MEM_LEN_1,x0
       do       x0,_make_zero_1
       move     y0,x:(r0)+
_make_zero_1
       
       move     #V8BIS_MEM_BGN_2,r0
       move     #V8BIS_MEM_LEN_2,x0
       do       x0,_make_zero_2
       move     y0,x:(r0)+
_make_zero_2
       
       rts

       ENDSEC

;********************* End of File **************************************
