;******************************* Module **********************************
;
;  Module Name          : rx_ton
;  Author               : Sanjay S. K.  
;  Date of origin       : 13 Jan 1996
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;************************* Module Description ****************************
;
;  This module performs detection of 2100Hz tone, USB1 and S1 signals.
;  Tone deteciton : Bandpass filtering followed by lowpass filtering is 
;  done over interpolated  12 samples, per baud. Bandpass fil-
;  ter is an IIR filter of 4th order. Lowpass filter is a first order IIR 
;  filter. The energy in the tone is compared with a threshold which inturn  
;  depends on the AGC gain.
;  USB1 detection : The correlation of two bauds apart is negative and that
;  of four bauds apart is positive. Whereas the energy is always positive.
;  decision is taken upon the correlation and energy of alternate bauds and
;  4 bauds apart.
;  S1 detection : The dc level of s1 signal is fairly constant. The average
;  of I and Q levels over the current and the past 3 bauds is computed. If 
;  there is too much change in dc level of either I or Q, S1 is said to be 
;  absent in that baud. Sum of dc levels should also be within certain thr-
;  eshold. The correlation of alternate bauds is minimum and two bauds  
;  apart is maximum.
;  
;             Symbols used :
;                      cor : Correlation of the bauds
;                       en : Energy of the bauds
;                  RD_PTR1 : Pointer to input buffer
;                  RD_PTR2 : Pointer to input buffer
;              RXCBOUT_PTR : Points to the beginning of current baud
;                     RXSB : Input buffer
;                     temp : Temporary register 
;                   TON150 : Counter for USB1 detection
;                    TONS1 : Counter for S1 detection
;                  TON2100 : Counter for 2100 Hz tone detection 
;                      IDC : Temporary reg. for I dc level
;                      QDC : Temporary reg. for Q dc level
;                    TNSUM : Memory location for Average I dc level
;                   TNASUM : Memory location for Average Q dc level
;                 PrevIsum : Average I dc level computed in the previous 
;                          : baud
;                 PrevQsum : Average Q dc level computed in the previous 
;                          : baud
;                     CIDC : Absolute value of the difference between curr-
;                          : ent and previous average I dc levels
;                     CQDC : Absolute value of the difference between curr-
;                          : ent and previous average Q dc levels
;                    CDCTH : Threshold for CIDC and CQDC
;                      SUM : Sum of absolute values of average I and Q dc
;                          : levels computed in the present baud
;                    SUMTH : Threshold for SUM
;                   CORTH1 : Threshold for correlation of 2 alternate bauds 
;                          : in S1 detection
;                   CORTH2 : Threshold for correlation of 2 bauds apart 
;                     AGCG : Gain of AGC
;                      THR : Threshold for energy in the tone
;                      sig : Energy in the tone
; 
;************************* Calling Requirements **************************
; 
; *  Note : There are 3 modules in this file. They are - rx_usb1 : for det-
;    ecting unscrambled binary ones at 1200 bps, rx_s1 : for detecting s1 
;    signal at 1200 bps and rx_ton : for detecting tone of 2100 Hz. *
;
;    /*  Calling requirements of rx_usb1  */
;
; 1. Every baud, 3 Demodulated and decimated samples of I and Q should be 
;    stored altnatively in a modulo buffer RXCB of length 30.
;
; 2. RXCBOUT_PTR should point to the beginning of the current baud in RXCB.
;
; *  Note : This subroutine has one do loop, hence the calling routine sho-
;    uld take care of la and lc contents. *
;
;    /*  Calling requirements of rx_s1  */
;
; 1. The 'mode_flg' should be set to either 'data' mode or 'handshake' mode 
;
; 2. Every baud, 3 Demodulated and decimated samples of I and Q should be 
;    stored altnatively in a modulo buffer RXCB of length 30.
;
; 3. RXCBOUT_PTR should point to the beginning of the current baud in RXCB.
;
; *  Note : This subroutine has one do loop, hence the calling routine sho-
;    uld take care of la and lc contents. *
;
;    /*  Calling requirements of rx_ton  */
;
; 1. This module calls TONEDETECT subroutine. Hence, stack pointer should    
;    be initialised. 
;
;
;*********************** Inputs and Outputs *******************************
;
;         /*  For rx_usb1  */
;
;  Input  :
;         1. RXCBOUT_PTR = | sfff ffff | ffff ffff |  in x:RXCBOUT_PTR
;                                             Points to buffer   RXCB
;                         /* Starting location of the current baud */
;
;  Update :
;         1. TONS150     = | s.iii iiii | 0000 0000 | in x:TON150
;         
;         /*  For rx_s1  */
;
;  Input  :
;         1. RXCBOUT_PTR = | iiii iiii | iiii iiii |  in x:RXCBOUT_PTR
;                                            Points to buffer RXCB
;                         /* Starting location of the current baud */
;
;  Update :
;         1. TNASUM      = | s.fff ffff | ffff ffff | in x:TNASUM
;         2. TNSUM       = | s.fff ffff | ffff ffff | in x:TNSUM
;         3. TONS1       = | s.iii iiii | 0000 0000 | in x:TONS1
;
;         /*  For rx_ton  */
;
;  Input  :
;         1. RXSB(n)     = | s.fff ffff | ffff ffff | for n = 0..11
;
;         2. AGCG        = | s.iii iiii | iiii iiii | in x:AGCG
;         
;
;  Updates :
;         1. TONS2100    = | s.iii iiii | iiii iiii | in x:TON2100 
;
;*********************** Tables and Constants *****************************
;
;  None
;
;******************************* Resources ********************************
;
;                    Cycle Count   : 277
;                    Program Words : 274
;                    NLOAC         : 193
;
; Modifier register used : 
;                    m01 : For modulo addressing of r0 and r1
;
; Address Registers used : 
;                     r0 : Used as a pointer to Input buffer in modulo
;                          30 addressing mode. 
;                     r1 : Used as a pointer to Input buffer in modulo
;                          30 addressing mode. 
;                     r3 : Used as a pointer to Input buffer in linear
;                          addressing mode.
;                     n  : used as an offset register to Input buffer
;
; Data Registers used    :
;                          a0  b0  x0  y0
;                          a1  b1      y1
;                          a2  b2
;
; Registers Changed      :  
;                          r0  a0  b0  x0  y0  sr  n  m01
;                          r1  a1  b1      y1  pc
;                              a2  b2
;
;**************************** Pseudo code *********************************
;
;     BEGIN
;
;     /*  USB1 detection  */
;
;         cor = en = 0
;         RD_PTR2 = RXCBOUT_PTR
;         RD_PTR1 = RXCBOUT_PTR - 12
;         for i = 0 to 5
;            temp = (*RD_PTR1++)*(RD_PTR2++)
;            cor = cor + temp    /* Correlation of 2 bauds apart */
;            en = en + |temp|    /* Energy of 2 bauds apart      */
;         endfor    
;         en = en * ($9c00)
;         if (cor < en)
;            cor = en = 0
;            RD_PTR2 = RXCBOUT_PTR
;            RD_PTR1 = RX_CBOUT_PTR - 24
;            for i = 0 to 5
;               temp = (*RD_PTR1++)*(*RD_PTR2++)
;               cor = cor + temp    /* Correlation of 4 bauds apart */
;               en = en + |temp|    /* Energy of 4 bauds apart      */
;            endfor    
;            en = en * ($6400)
;            if (cor > en)
;               TON150 = TON150 + $1400
;            else
;               TON150 = TON150 + $f400
;            endif
;         else
;            TON150 = TON150 + $f400
;         endif
;             
;     /*  Detect S1 signal  */        
;
;         IDC = QDC = 0
;         RD_PTR1 = RXCBOUT_PTR -18
;         for i = 0 to 11
;            IDC = IDC + (*RD_PTR1++)
;            QDC = QDC + (*RD_PTR1++)
;         endfor   
;         PrevIsum = TNSUM
;         PrevQsum = TNASUM
;         TNSUM = IDC/12
;         TNASUM = QDC/12
;         CIDC = | TNSUM - PrevIsum |
;         CQDC = | TNASUM - PrevQsum |
;         if (CIDC >= CDCTH)
;            TONS1 = TONS1 + $ff00
;         else
;            if(CQDC > CDCTH)
;               TONS1 = TONS1 + $ff00
;            else
;               SUM = | TNSUM | + | TNASUM |
;               if (SUM < SUMTH)
;                  TONS1 = TONS1 + $ff00
;               else
;                  RD_PTR1 = RXCBOUT_PTR - 6
;                  RD_PTR2 = RXCBOUT_PTR
;                  cor = 0
;                  for i = 0 to 2
;                     cor = cor + ((*RD_PTR1++) - TNSUM) * ((*RD_PTR2++)
;                           - TNSUM)
;                     cor = cor + ((*RD_PTR1++) - TNASUM) * ((*RD_PTR2++)
;                           - TNASUM)
;                  endfor
;                  if (cor > CORTH1)
;                     TONS1 = TONS1 + $ff00
;                  else
;                     RD_PTR1 = RXCBOUT_PTR - 12
;                     RD_PTR2 = RXCBOUT_PTR
;                     cor = 0
;                     for i = 0 to 2
;                        cor = cor + ((*RD_PTR1++) - TNSUM) * ((*RD_PTR2++)
;                              - TNSUM)
;                        cor = cor + ((*RD_PTR1++)-TNASUM) * ((*RD_PTR2++)
;                              - TNASUM)
;                     endfor
;                     if (cor < CORTH2)
;                        TONS1 = TONS1 + $ff00
;                     else
;                        TONS1 = TONS1 + $0100
;                     endif
;                  endif           
;               endif
;            endif
;         endif
;
;     /*  2100 Hz Answer tone Detection  */
;
;         sig = TONEDETECT(PAR_2100, DEL_2100, RXSB)
;         if (AGCG > $7800)
;            THR = $0d00
;         else
;            THR = $1000
;         endif
;         if (sig >= THR)
;            TON2100 = TON2100 + $000e
;         else
;            TON2100 = TON2100 - $000e
;         endif
;
;     END
;
;
;************************** Environment ***********************************
;
;       Assembler : ASM56800 version 6.0.0.0
;       Machine   : IBM PC
;       OS        : MSDOS 6.0
;
;****************************** Assembly Code *****************************

        include "gmdmequ.asm"
        include "rxmdmequ.asm"

        ;Detection of Unsrambled binary ones

        SECTION V22B_RX 

        GLOBAL  RXUSB1
        GLOBAL  RXS1
        GLOBAL  RXTON

        org p:

RXUSB1

        move    #RXCB_SIZ,x0
        sub     #1,x0
        move    x0,m01                    ;Set r0 and r1 in modulo 30
        orc     #$8000,m01                ;  addressing mode
        move    x:RXCBOUT_PTR,r0          ;Get pointer to demodulated and
                                          ;  decimated samples of I and Q
                                          ;  i.e., r0 = RD_PTR2
        move    #-12,n                    ;Get the offset value
        move    r0,r1                     
        move    #0,y1                     ;Set energy of 2 alternate bauds 
                                          ;  to zero, i.e., en = 0
        clr     b         x:(r1)+n,x0     ;Set correlation of 2 alternate
                                          ;  bauds to zero, and dummy move
                                          ;  into x0, 
                                          ;  r1=RD_PTR1 -> RXCBOUT_PTR - 12
        move    x:(r1)+,y0                ;y0 = *RD_PTR1, RD_PTR1++  
        move    x:(r0)+,x0                ;x0 = *RD_PTR2, RD_PTR2++  

        do      #6,endcoren1             ;Compute over one baud
        mpy     y0,x0,a   x:(r1)+,y0      ;temp = (*RD_PTR1++)*(*RD_PTR2)
        add     a,b       x:(r0)+,x0      ;cor = cor+temp, RD_PTR2++
        abs     a                         ;Compute | temp |
        add     y1,a                      ;en = en + | temp |
        move    a,y1                      ;Store energy 

endcoren1
        move    #$9c00,x0                 ;Get constant for multiplying en
        move    #$f400,y0                 ;Constant to be added to TON150
        mpy     y1,x0,a                   ;en = en * $9c00
        cmp     b,a                       ;If cor < en do
        ble     check1
        move    x:RXCBOUT_PTR,r0          ;Get pointer to demodulated and
                                          ;  decimated samples of I and Q
                                          ;  i.e., r0 = RD_PTR2
        move    #-24,n                    ;Get the offset value
        move    r0,r1                     ;
        move    #0,y1                     ;Set energy of 2 bauds seperated 
                                          ;  by 4 bauds to zero, i.e. en=0
        clr     b         x:(r1)+n,x0     ;Set correlation of 2 seperated 
                                          ;  by 4 bauds to zero, and dummy 
                                          ;  move into x0, 
                                          ;  r1=RD_PTR1 -> RXCBOUT_PTR - 24
        move    x:(r1)+,y0                ;y0 = *RD_PTR1, RD_PTR1++  
        move    x:(r0)+,x0                ;x0 = *RD_PTR2, RD_PTR2++  

        do      #6,endcoren2              ;Compute over one baud

        mpy     y0,x0,a   x:(r1)+,y0      ;temp = (*RD_PTR1++)*(*RD_PTR2)
        add     a,b       x:(r0)+,x0      ;cor = cor+temp, RD_PTR2++
        abs     a                         ;Compute | temp |
        add     y1,a                      ;en = en + | temp |
        move    a,y1                      ;Store energy 

endcoren2
        move    #$6400,x0                 ;Get constant for multiplying en
        mpy     y1,x0,a                   ;en = en * $6400
        move    #$1400,y0                 ;Constant to be added to TON150
        cmp     b,a                      

        blt     check1                    ;If cor > en do
        move    #$f400,y0                 ;TON150 = TON150 + $1400 else

check1
        move    x:TON150,a
        add     y0,a                      ;TON150 = TON150 + $f400
        move    a,x:TON150                ;Store back TON150
        move    #-1,m01                   ;Make r0 and r1 to be linear
End_RXUSB1
        jmp     rx_next_task

;------------------------------------------------------------------
;   /*  Detect s1 signal  */
;------------------------------------------------------------------

RXS1    

        move    #RXCB_SIZ,x0
        sub     #1,x0
        move    x0,m01
        orc     #$8000,m01                ;r1 in mod 30 addressing mode
        move    x:RXCBOUT_PTR,r1           
        move    r1,r0                     ;r0 = RD_PTR2
        move    #-18,n                    ;Offset to get RD_PTR1
        clr     a                         ;Set dc value of I (IDC) to 0
        clr     b         x:(r1)+n,x0     ;Set dc value of Q (QDC) to 0
                                          ;  dummy resd into x0,
                                          ;  r1 = RD_PTR1
        move    x:(r1)+,x0

        do      #12,enddc
        add     x0,a      x:(r1)+,y0      ;IDC = IDC + (*RD_PTR1++)
        add     y0,b      x:(r1)+,x0      ;QDC = QDC + (*RD_PTR1++)

enddc
        move    x:TNSUM,x0                ;PrevIsum = TNSUM
        asr     a                         
        asr     a                         ;Divide IDC by 4
        move    #$2aaa,y1                 ;Factor for Dividing by 3
        move    a,y0                      ;Saturate acc
        mpyr    y1,y0,a                   ;Divide IDC by 3
        move    a,x:TNSUM                 ;TNSUM = IDC/12
        asr     b
        asr     b                         ;Divide QDC by 4
        move    b,y0                      ;Saturate acc
        mpyr    y1,y0,b                   ;Divide QDC by 3
        move    x:TNASUM,y0               ;PrevQsum = TNASUM
        move    b,x:TNASUM                ;TNASUM = QDC/12
        sub     x0,a                      ;Get (TNSUM - PrevIsum)
        abs     a                         ;Get absolute value, i.e., CIDC
        sub     y0,b                      ;Get (TNASUM - PrevQsum)
        abs     b                         ;Get absolute value, i.e., CQDC
        move    #$0300,r2                 ;CDCTH for data mode
        move    #$1800,y0                 ;SUMTH for data mode
        move    x:mode_flg,y1
        move    #hndshk,x0
        cmp     x0,y1
        bne     _dmode
        move    #$0800,r2                 ;CDCTH for training mode
        move    #$0100,y0                 ;SUMTH for training mode
_dmode
        move    r2,x0
        cmp     x0,a                      ;If CIDC >= CDCTH go
        jge     nos1
        cmp     x0,b                      ;If CQDC > CDCTH go
        jgt     nos1
        move    x:TNSUM,a                 ;Get TNSUM
        move    x:TNASUM,b                ;Get TNASUM
        abs     a                         ;Get absolute value of TNSUM
        abs     b                         ;Get absolute value of TNASUM
        add     b,a                       ;SUM = | TNSUM | + | TNASUM |
        cmp     y0,a                      ;If sum < SUMTH go
        jlt     nos1
        move    #-6,n                     ;Get the offset value
        move    r0,r1                     
        nop 
        clr     a         x:(r1)+n,x0     ;Set correlation of 2 alternate
                                          ;  bauds to zero, and dummy move
                                          ;  into x0, 
                                          ;  r1=RD_PTR1 -> RXCBOUT_PTR - 6
        move    x:(r1)+,b                 ;b = *RD_PTR1++

        do      #3,corend1               ;Repeat over 3 symbol duration
        move    x:TNSUM,x0                
        sub     x0,b      
        move    b,y0                      ;Saturate the difference
        move    x:(r0)+,b
        sub     x0,b
        move    b,y1                      ;Satutate the difference
        mac     y1,y0,a   x:(r1)+,b       ;cor=cor+((*RD_PTR1++)) - TNSUM)* 
                                          ;  ((*RD_PTR2++)-TNSUM), 
                                          ;  b = *RD_PTR1++
        move    x:TNASUM,x0                
        sub     x0,b      
        move    b,y0                      ;Saturate the difference
        move    x:(r0)+,b
        sub     x0,b
        move    b,y1                      ;Satutate the difference
        mac     y1,y0,a   x:(r1)+,b       ;cor=cor+((*RD_PTR1++)) - TNASUM) 
                                          ;  * ((*RD_PTR2++) - TNASUM)
                                          ;  b = *RD_PTR1++
corend1
        move    #$fe00,r2                 ;CORTH1 for training mode
        move    x:mode_flg,y0
        move    #hndshk,x0
        cmp     x0,y0
        beq     _trnm
        move    #$fa00,r2                 ;CORTH1 for data mode
_trnm
        move    r2,x0
        cmp     x0,a

        bgt     nos1
        move    x:RXCBOUT_PTR,r0          ;Get pointer to demodulated and
                                          ;  decimated samples of I and Q
                                          ;  i.e., r0 = RD_PTR2
        move    #-12,n                    ;Get the offset value
        move    r0,r1                     
        nop 
        clr     a         x:(r1)+n,x0     ;Set correlation of 2 alternate
                                          ;  bauds to zero, and dummy move
                                          ;  into x0, 
                                          ;  r1=RD_PTR1 -> RXCBOUT_PTR - 6
        move    x:(r1)+,b                 ;b = *RD_PTR1++

        do      #3,corend2               ;Repeat over 3 symbol duration
        move    x:TNSUM,x0                
        sub     x0,b      
        move    b,y0                      ;Saturate the difference
        move    x:(r0)+,b
        sub     x0,b
        move    b,y1                      ;Satutate the difference
        mac     y1,y0,a   x:(r1)+,b       ;cor=cor+((*RD_PTR1++)) - TNSUM) 
                                          ;   * ((*RD_PTR2++) - TNSUM)
                                          ;  b = *RD_PTR1++
        move    x:TNASUM,x0                
        sub     x0,b      
        move    b,y0                      ;Saturate the difference
        move    x:(r0)+,b
        sub     x0,b
        move    b,y1                      ;Satutate the difference
        mac     y1,y0,a   x:(r1)+,b       ;cor=cor+((*RD_PTR1++)) - TNASUM) 
                                          ;  * ((*RD_PTR2++) - TNASUM)
                                          ;  b = *RD_PTR1++
corend2
        move    #$0200,r2                 ;CORTH2 for training mode
        move    x:mode_flg,y0
        move    #hndshk,x0
        cmp     x0,y0
        beq     _trndm
        move    #$0500,r2                 ;CORTH2 for data mode
_trndm
        cmp     x0,a                      ;If cor < CORTH2 go
        blt     nos1
        move    x:TONS1,b                 ;TONS1 = TONS1 + $0100
        add     #$0100,b

        bra     store
nos1
        move    x:TONS1,b
        add     #$ff00,b                  ;TONS1 = TONS1 + $ff00

store
        move    b,x:TONS1
        move    #-1,m01                   ;r0 and r1 in linear addr. mode
End_RXS1
        jmp     rx_next_task

;-----------------------------------------------------------------------
;   /*  Tone Detection  */
;-----------------------------------------------------------------------


RXTON
        move    #PAR_2100,r3              ;Pointer to filter coef buffer
        move    #DEL_2100,r0              ;Pointer to filter states buffer
        move    #RXSB,r1                  ;Pointer to Input buffer
        jsr     TONEDETECT                ;Subroutine, returns the value in 
                                          ;  accumulator a
        move    x:AGCG,x0
        move    #$1000,y1                 
        move    #$0d00,b                  ;THR = $0d00
        move    #$7800,y0                 ;If AGCG > $0d00, THR = $0d00
        cmp     y0,x0
        nop                               ;
        tle     y1,b                      ;  else THR = $1000
        move    b,x0
        move    x:TON2100,b
        move    #$0037,y0                 
        cmp     x0,a                      ;Check for sig value
        blt     _subtract                 ;If sig >= THR, TON2100 = TON2100
        add     y0,b                      ;  + $0037
        bra     _save
_subtract                                 
        sub     y0,b                      ;If sig < THR, TON2100 = TON2100
_save                                     ;  - $0037
        move    b,x:TON2100
End_RXTON 
        rts

        ENDSEC

