;******************************** Module **********************************
;
;  Module Name     : initsr
;  Author          : Varadarajan G
;  Date of origin  : 
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;*************************** Module Description ***************************
;
;         This file contain the initialisation subroutines
;   1.  INIT_SP_COMMON    Initialises the signal processing variables
;                         related to modem called during powerup and
;                         a part of it done during retraining
;
;   2.  INIT_BEG_AGC      Initialise all the receiver variables. Called
;                         while starting modem receiver. Called from
;                         rx_stat.asm
;
;   3.  CLEQ_INIT         Equaliser and related variables are initialised
;                         Called during handshaking.
;
;   4.  AGC_JAM           Initialises AGCG in Answering mode before dete.
;                         S1. It is required since calling modem doesnt
;                         transmit USB1, a good signal to adapt AGCG.
;                         It is done based on the linear approximation to
;                         a parabolic curve.
;  
;************************** Environment ***********************************
;
;       Assembler : ASM56800 version 6.0.1.0
;       Machine   : IBM PC
;       OS        : MSDOS 6.0
;
;**************************** Assembly Code *******************************
	
        include "rxmdmequ.asm"
        include "txmdmequ.asm"
        include "gmdmequ.asm"


        SECTION INITISR

        GLOBAL    INIT_SP_COMMON
        GLOBAL    AGC_JAM
        GLOBAL    INIT_BEG
        GLOBAL    INIT_BEG_AGC
        GLOBAL    CLEQ_INIT
        GLOBAL    CLR_RAM2


        org p:

INIT_SP_COMMON
        
INIT_SP_TRN
        move    #0,x:RETCNT_RM
        move    #0,x:speed
        move    #0,x:TNSUM
        move    #0,x:TNASUM
        move    #0,x:rx_dscr_buff

        move    #0,x:rx_dscr_buff_1
        move    #64,x:dscr_cntr
        move    #1,x:rx_st_chg
        move    #$0c00,x:IBCNT
        move    #12,x:TXBD_CNT

        move    #0,x:BLP
        move    #0,x:BINTG
        move    #0,x:BOFF
        move    #0,x:BACC1
        move    #0,x:BACC2
        move    #0,x:AGCLP1
        move    #0,x:AGCLP2
        move    #$4800,a
        move    a,x:AGCC1
        move    #$6000,a
        move    a,x:AGCC2
        move    #$0800,a
        move    a,x:AGCC3
        move    #$7800,a
        move    a,x:AGCC4
        move    #$0500,a
        move    a,x:AGCG
        move    #0,x:AGCLG
        move    #IB,r0
        move    r0,x:IBPTR
        move    r0,x:IBPTR_IN
        move    #hndshk,x:mode_flg
        move    #0,a
        move    a,x:IFBANK

        move    #IFCOE,r0                 ;Select the filter coefficients 
        move    #64,n                     ;  for interpolation
        move    #ICOEFF,r1

        do      #6,tr1
        move    x:(r0)+n,a
        move    a,x:(r1)+
tr1
        move    #-64,n

        move    #IFCOE,a
        add     #383,a
        move    a1,r0

        do      #6,tr2
        move    x:(r0)+n,a
        move    a,x:(r1)+
tr2
        move    #RXBPF22H,r0               
        move    #3,n                      ;Offset to sine tab for bandpass
        move    #DPHASECAL,a              ;  filtering on the high channel
        bftsth  #CALLANS,x:MDMCONFIG

        jcc     callmodem
        move    #RXBPF22L,r0
        move    #1,n                      ;Offset to sine tab for bandpass
        move    #DPHASEANS,a              ;  filtering on low channel

callmodem
        move    r0,x:BPF_PTR
        move    n,x:mod_tbl_offset
        move    a,x:DPHADJ
CLR_RAM2
        move    #0,x:LASTDP
        move    #0,x:WRAP
        move    #0,x:JITG1
        move    #0,x:JITG2
        move    #0,x:JITTER
        move    #BBUF,r0
        move    r0,x:BBUFPTR
        clr     a
        rep     #13
        move    a,x:(r0)+
        move    #$7300,a
        move    a,x:RCBUF
        move    #$8d00,a

        move    a,x:RCBUF_1
        move    #$4000,a

        move    a,x:RCBUF_2

        rts

;******************************************************************

INIT_BEG_AGC
        move    #$0500,a                  ;Initialise the AGC Gain to  
        move    a,x:AGCG                  ;  a nominal value
        move    #0,x:AGCLP1               ;Initialise the AGC LPF states
        move    #0,x:AGCLP2
        move    #0,x:AGCLG                ;Dont allow updation of AGCG
        move    #0,x:LPBAGC               ;Initialise the Carrier Detect
        move    #0,x:LPBAGC2              ;  LPF states
        move    #0,x:CD1                  ;Carrier Detect flag is set to 0
INIT_BEG
        move    #0,x:WRPFLG               ;Enable 

        move    #IB,r0
        clr     a

        move    #IBSIZ,x0
        do      x0,clr_int_fil            ;Initialise the Interpolation
        move    a,x:(r0)+                 ;  filter input to zero
clr_int_fil

        move    #RXRB,r0                  ;Initialise BPF input sample 
        move    r0,x:RXFPTR               ;  pointer and init. buffer to
                                          ;  zero
        move    #RX_FILT_V22,x0
        do      x0,clr_rx_filt
        move    a,x:(r0)+
clr_rx_filt

        move    #0,x:DPHASE               ;Initialise Carrier phase error
        move    #0,x:CDP                  ;  to zero
        move    #0,x:CD_CNT               ;Initialise the Carrier detect 
                                          ;  count to zero

        move    #RXCB2A_6,r0
        move    r0,x:RXCBPTR              ;  demodulated samples for decim.

        move    #RXCB_6,r0
        move    r0,x:RXCBIN_PTR           ;Init the pointer used to store
                                          ;  the decimated samples
        move    #RXCB,r0                  ;Init the pointer used to pick
        move    r0,x:RXCBOUT_PTR          ;  the decimated samples for 
                                          ;  further processing
        move    #ENERBUF,r0               ;Init the pointer used to store
        move    r0,x:ENBUF_PTR            ;  energy of the demod. samples
        move    #BPF_OUT,r0               ;Init the pointer used to store
        move    r0,x:BPFOUT_PTR           ;  Bandpass filtered output
        move    #PREV_ENERGY,r0           ;Init the pointer used to store
        move    r0,x:PRV_ENPTR            ;  Previous baud energy and init
                                          ;  the buffer to zero
        do      #12,clr_prev_energy
        move    a,x:(r0)+
clr_prev_energy

        move    #$0555,a                  ;Init the Highpass filter coeff.
        move    a,x:HPG1                  ;  used in Baud loop
        move    #$8800,a
        move    a,x:HPG2
        move    #$4000,a                  ;Init the Lowpass filter coeff.
        move    a,x:BLPG1                 ;  used in the Baud loop
        move    a,x:BLPG2
        move    #$6000,a                   
        move    a,x:BOFF
        move    #MOD_TBL,a                ;Init the pointer used to pick
        move    a,x:RXMPTR                ;  carrier for demodulation
        move    #0,x:BHPX1                ;Init. the Highpass filter states
        move    #0,x:BHPY1                ;  of the first and the 3rd 
        move    #0,x:BHPE1                ;  samples and the energy of the
        move    #0,x:BHPX3                ;  HPF output of the 1st and 3rd
        move    #0,x:BHPY3                ;  samples
        move    #0,x:BHPE3
        move    #0,x:BACC1                ;Init the accumulator in the 
        move    #0,x:BLP                  ;  baud loop
        move    #0,x:BINTG                ;Init the Integrator state & the
        move    #0,x:BINTGA               ;  scaling factor in Baud loop
        move    #0,x:RX_LAPM_EN
        move    #0,x:TX_LAPM_EN
        rts

;************************************************************************

CLEQ_INIT
        move    #$3000,a                  ;Initialises the PLL filter and 
        move    a,x:CARG1                 ;  the integrator coefficients
        move    #0,x:CARG2                ;  in the carrier loop.
        move    #$1c00,a
        move    a,x:CARG3
        move    #$3000,a
        move    a,x:CARG4
        move    #0,x:CLP                  ;Initialises the PLL LPF state &
        move    #0,x:COFF                 ;  the integrator state.
        move    #RCBUF,r0                 
        move    #$7300,a                  ;Initialis the first 3 reflection
        move    a,x:(r0)+                 ;  coefficients
        move    #$8d00,a
        move    a,x:(r0)+
        move    #$4000,a
        move    a,x:(r0)+
        clr     a                         ;
        rep     #3                        ;Initialise the rest of the refl-
        move    a,x:(r0)+                 ;  ection coefficients to zero
        move    #THBUF,r0
        rep     #6                        ;Initialse the jitter filter 
        move    a,x:(r0)+                 ;  updates to zero
        move    #BBUF,r0
        rep     #13                       ;Initialise the jitter delay
        move    a,x:(r0)+                 ;  line
        move    #0,x:JITTER               ;Initialise the jitter itself!
        move    #0,x:JITG1                ;Initialise the input scaling
        move    #0,x:JITG2                ;  factors
        move    #0,x:RXSCRD               ;Initialise the descrambler state
        move    #0,x:RXODAT               ;
        move    #EQRT,r0

        move    #EQTSIZ22,x0
        do      x0,clr_eq_r_taps          ;Initialise the Equaliser taps to
        move    a,x:(r0)+                 ;  zero
clr_eq_r_taps

        move    #EQIT,r0

        do      x0,clr_eq_i_taps          ;Initialise the Equaliser taps to
        move    a,x:(r0)+                 ;  zero
clr_eq_i_taps

        move    #EQRSB,r0
        move    r0,x:EQRBIN

        asl     x0                        ;x0 = 2*EQTSIZ22
        do      x0,clr_eq_r_states        ;Initialise the Equaliser state
        move    a,x:(r0)+                 ;  to zero
clr_eq_r_states

        move    #EQISB,r0
        move    r0,x:EQIBIN

        do      x0,clr_eq_i_states
        move    a,x:(r0)+
clr_eq_i_states

        move    #EQTSIZ22,a
        move    a,x:EQUDSIZ
        move    #FASTEQUD,a               ;Initialise the step size of the
        move    a,x:LUPALP                ;  equaliser for fast adaption

        move    x:ENBUF_PTR,r0            ;Find the max. energy sample
        move    #35,m01                   ;  inside a baud. Also find the
        move    #-12,n                    ;  position of the max.energy.
        move    #1,a
        lua     (r0)+n
        clr     x0
        move    x:(r0)+,y0

        move    #11,x0
        do      x0,fndmax
        move    x:(r0)+,b
        cmp     y0,b

        jle     nxten

        move    b,y0
        move    a1,x0

nxten  
        incw    a
        nop
        nop

fndmax
        move    x:RXCBIN_PTR,r0           ;Position RXCBPTR and RXCBOUT_PTR
        move    #RXCB_MOD,m01             ;  based on the max. energy pos.
        move    x0,a                      ;  RXCBPTR is positioned sucht
        andc    #3,x0                     ;  that one sample in the 
        lsl     x0                        ;  decimated samples has max.ener
        move    #RXCB2A,y0                ;  RXCBOUT_PTR is positioned such
        add     x0,y0                     ;  that the mid sample in the 
        move    y0,x:RXCBPTR              ;  baud taken for processing has
        move    #-8,n                     ;  the max. energy.
        move    #3,x0
        cmp     x0,a
        jle     over

        move    #-6,n
        move    #7,x0
        cmp     x0,a

        jle     over

        move    #-10,n

over   
        nop
        lua     (r0)+n
        move    r0,x:RXCBOUT_PTR
        move    #$ffff,m01
        rts

;*************************************************************************


AGC_JAM
        move    x:AGCLP1,x0
        move    #$0c00,y0
        cmp     y0,x0
        move    #$007a,a
        jge     RUNJAM_1
        move    #$0300,y0
        cmp     y0,x0
        move    #$005f,a
        jge     RUNJAM_1
        move    #$0100,y0
        cmp     y0,x0
        move    #$0030,a
        jge     RUNJAM_1
        move    #$0040,y0
        cmp     y0,x0
        move    #$0018,a
        jge     RUNJAM_1
        move    #$0010,y0
        cmp     y0,x0
        move    #$6000,a0
        jlt     RUNJAM_2
RUNJAM_1
        andc    #$fffe,sr
        rep     #16
        div     x0,a
RUNJAM_2
        move    a0,x:AGCG
        move    #$1800,a
        move    a,x:AGCLP1
        move    #$1600,a
        move    a,x:AGCLP2
        rts

;*************************************************************************

        ENDSEC
