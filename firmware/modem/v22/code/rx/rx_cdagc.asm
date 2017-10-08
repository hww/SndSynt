;******************************* MODULE ***********************************
;
;   Module Name          rx_cdagc.asm
;   Name of the Author   N.R. Sanjeev
;   Date of Origin       01/30/1995
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;************************* MODULE DESCRIPTION *****************************
;
;This module lowpass filters RXSBAG and decides whether the carrier is pre-
;sent or not. It also computes the energy in the demodulated and decimated
;samples which is in turn used in updating the AGC gain factor AGCG.
;
;************************ CALLING REQUIREMENTS ****************************
;
;  1. rx_ans_flg shall be initialised to call. or ans. mode accordingly  
;
;  2. mode_flg should reflect the phase (training or data) rx is in.
;
;********************** INPUTS, OUTPUT AND UPDATES ************************
;
;Inputs
;  1. RXSBAG which is contained in the memory location x:RXSBAG
;
;  2. AGCLG  which is contained in the memory location x:AGCLG
;
;  3. RXCBOUT_PTR which is contained in the memory location x:RXCBOUT_PTR 
;     and which points to the buffer RXCB which contains the decimated IQ
;     samples.
;
;Output
;  1. Presence of the carrier which is indicated in the memory location
;     x:CD1. If the carrier is present $0001 is written into x:CD1.
;     If the carrier is absent $0000 is written into x:CD1.
;
;Updates
;  1. The IIR filter states LPBAGC and LPBAGC2 contained in the memory 
;     locations x:LPBAGC and x:LPBAGC2 respectively.
;
;  2. The IIR filter states AGCLP1 and AGCLP2 contained in the memory 
;     locations x:AGCLP1 and x:AGCLP2 respectively. 
;
;  3. The AGC gain contained in the memory location x:AGCG 
;
;
;Note : The default storage format is | sfff ffff | ffff ffff | unless
;       specified otherwise
;
;*************************** CONSTANTS USED *******************************
;
;  1. THRESH1 = $00c0
;     
;  2. THRESH2 = $0048
;    
;  3. THRESH3 = $005c
;   
;  4. THRESH4 = $0070
;  
;  5. AGCC1, which is a filter coefficient used in filtering the energy
;     in the computation of the AGC gain. 
;     
;  6. AGCC2, which is a filter coefficient used in filtering the energy
;     in the computation of the AGC gain.
;    
;  7. AGCC3, which is a filter coefficient used in filtering the energy
;     in the computation of the AGC gain.
;   
;  8. AGCC4, which is a filter coefficient used in filtering the energy
;     in the computation of the AGC gain.
;  
;
;Note1 : The default storage format is | sfff ffff | ffff ffff | unless
;        specified otherwise
;
;Note2 : AGCC1,AGCC2,AGCC3 and AGCC4 have different values in handshaking
;        and data phase.
;
;****************************** RESOURCES *********************************
;
;                 Program Words:     162
; Worst Case Instruction Cycles:     176
;                         NLOAC:     125
; 
; Address Registers Used: r0
;
; Modifier Register Used: m01
;
;    Data Registers Used:   a0   b0   x0   y0
;                           a1   b1        y1
;                           a2   b2        
;
;      Registers Changed:   a0   b0   x0   y0   sr
;                           a1   b1        y1   pc
;                           a2   b2        
;
;***************************** ENVIRONMENT ********************************
;
;    Assembler:    Motorola DSP56800 Assembler Version 6.0.1.0
;    Simulator:    Motorola DSP56800 Simulator Version 6.0.33
;    Machine  :    SunSparc
;    OS       :    SunOS 4.1.3_U1
;
;***************************** PSEUDO CODE ********************************
;
;BEGIN
;     /*of carrier detection*/
;     RXSBAG = RXSBAG*4
;     if(calling)
;       temp = RXSBAG*$7f00
;     else
;       temp = RXSBAG*$3f00
;     endif
;     temp = temp + ($7800)*LPBAGC
;     if(temp > THRESH1)
;        temp = THRESH1
;     endif
;     LPBAGC = temp
;     temp1 = temp*($0200)
;     temp1 = temp1 + ($7e00)*LPBAGC2
;     LPBAGC2 = temp1
;     if(LPBAGC > THRESH2)
;       if(training)
;         if(LPBAGC < THRESH3)
;           CD1 = 0
;         else
;           CD1 = 1
;         endif
;       else
;         if(LPBAGC2 < THRESH3)
;           CD1 = 0
;         else
;           if(LPBAGC2 > THRESH4)
;             CD1 = 1
;           else
;             retain previous CD1
;           endif
;         endif
;       endif
;     else
;       CD1 = 0
;     endif
; End /*of carrier detection*/
;
; Begin 
;     /*of updating AGC gain*/
; RXCBOUT_PTR = RXCBOUT_PTR + 6
; RD_PTR = RXCBOUT_PTR
; energy = 0
; for i = 0 to 5
;     temp = *RDPTR++
;     energy = energy + temp*temp
; endfor
; agcref = $2000
; if(calling)
;   energy = energy*($3800)
; else
;   energy = energy*($2a00)
; endif
; temp = energy*AGCC1
; temp = temp + AGCLP1*AGCC2
; AGCLP1 = temp
; LPENERGY = AGCC3*temp
; LPENERGY = LPENERGY + AGCC4*AGCLP2
; AGCLP2 = LPENERGY
; if(CD1 > 0)
;   excess = LPENERGY - agcref
;   if(|excess|>=$0800)
;     if(excess>0)
;       excess = excess - $0800
;     else
;       excess = excess + $0800
;     endif
;     AGCG = AGCG - (AGCG*excess)*AGCLG
;     if(AGCG < $0080)
;       AGCG = $0080
;     endif
;   endif
; endif
; End /*AGC gain update*/
;END /*of module*/
;
;**************************** ASSEMBLY CODE *******************************

        include "rxmdmequ.asm"
        include "gmdmequ.asm"

        SECTION V22B_RX       

        GLOBAL RXCDAGC


        org p:

RXCDAGC
        move    x:RXSBAG,a                ;Load the value of RXSBAG from
                                          ;  memory into one of the 
                                          ;  accumulators
        asl     a
        asl     a                         ;finished multiplying RXSBAG by 4
        move    a,a1                      ;saturating a 

        move    #$3f00,y0
        bftsth  #CALLANS,x:MDMCONFIG

        bcs     SCALE
        move    #$7f00,y0                

SCALE
        mpy     a1,y0,a                   ;
        move    #$7800,x0                 ;move the first IIR filter coeff
                                          ;  to the register x0.
        move    x:LPBAGC,y0               ;read filter state from memory
        macr    x0,y0,a                   ;perform
                                          ;  temp = temp + ($7800)*LPBAGC           
        move    #THRESH1,x0
        cmp     x0,a

        jle     NOCLIPREQ
        move    x0,a

NOCLIPREQ                               
        move    a,x:LPBAGC                ;finished updating LPBAGC 
        move    a,x0                      ;move saturated value of a to x0

;start of updating LPBAGC2
        move    #$0200,y0                 ;move filter coefficient to y0
        mpy     x0,y0,a                   ;temp1 = temp*($0200) 
        move    #$7e00,y1                 ;read filter coefficient to y1
        move    x:LPBAGC2,y0              ;read filter state from memory
        macr    y1,y0,a                   ;perform the operation
                                          ;  temp1=temp1+($7e00)*LPBAGC2
        move    a,x:LPBAGC2               ;store filter state in memory
;end of updating LPBAGC2
                                          ;REF
RX_CDAGCIFS
        move    x:LPBAGC,a                ;
        move    #THRESH2,x0
        cmp     x0,a                      ;LPBAGC too small so do not
                                          ;  enter the if loop
        jle     TOOSMALLPBAGC            
        bftsth  #datamd,x:mode_flg

        jcs     NOTTRAINING

        move    x:LPBAGC,a                ;
        move    #THRESH3,x0
        cmp     x0,a                      ;jump if (LPBAGC >= THRESH3)
        jge     BEYONDTHRESH3             ;jump if (LPBAGC >= THRESH3)

        move    #$0000,x:CD1              ;move 0 into x:CD1
        jmp     ENDCARDETECT

BEYONDTHRESH3
        move    #$0001,y1                 ;load $0001 into y1
        move    y1,x:CD1                  ;load $0001 into x:CD1
        jmp     ENDCARDETECT

NOTTRAINING
        move    x:LPBAGC2,x0
        move    #THRESH3,a
        cmp     x0,a                      ;check if (THRESH3 > LPBAGC2)
                                          ;if(lpbagc2 >= thresh3) goto
        jle     AGAINBEYONDTHRESH3        ;  AGAINBEYONDTHRESH3
        move    #$0000,x:CD1              ;since carrier is not present
                                          ;  load 0 into y1
        jmp     ENDCARDETECT

AGAINBEYONDTHRESH3

        move    #THRESH4,a                ;
        cmp     x0,a                      ;check if (LPBAGC2 > THRESH4)     
        jge     ENDCARDETECT              ;if the test fails abort 
                                          ;  updating x:CD1
        move    #$0001,x:CD1              ;since (LPBAGC2 > THRESH4)  
                                          ;  x:CD1 is loaded with $0001
        jmp     ENDCARDETECT

TOOSMALLPBAGC 

        move    #$0000,x:CD1              ;since (LPBAGC <= THRESH2)
                                          ;  $0000 is loaded in x:CD1
ENDCARDETECT              
;End of carrier detection.                ;
;Start of AGC gain update. 

        move    #6,n                      ;load into the offset register
                                          ;  to offset the modulo pointer

        move    #RXCB_SIZ,x0
        sub     #1,x0
        move    x0,m01                    ;load m01 with the size of the
                                          ;  circular buffer
        move    x:RXCBOUT_PTR,r0          ;load RXCBOUT_PTR in x0
        nop                               ;nop because address register can't
                                          ;  be modified in the immediately
                                          ;  next move.
        lea     (r0)+n
        move    r0,x0
        move    x0,x:RXCBOUT_PTR          ;store the offset pointer in
                                          ;  x:RXCBOUT_PTR
        clr     a        x:(r0)+,y0       ;initialize energy to 0
                                          ;  read first I value from memory
         
        rep     #5                        ;for i = 0 to 5
        mac     y0,y0,a  x:(r0)+,y0       ;  energy = energy + temp*temp
                                          ;  temp = *RDPTR++
        macr    y0,y0,a                   ;  energy = energy + temp*temp

        move    #$ffff,m01                ;make both r0 and r1 linear again

        move    a,a1                      ;saturate energy

        move    #$3800,y0                 ;Move filter coefficient corres-
                                          ;  ponding to the calling mode.
        bftsth  #CALLANS,x:MDMCONFIG

        bcc     ENERGYSCALE
                                          ;  goto _ENERGYSCALE
        move    #$2a00,y0                 ;move filter coefficient corres-
                                          ;  ponding to the the answering
                                          ;  mode                 
ENERGYSCALE

        mpyr    a1,y0,a                   ;do energy = energy*$filtercoeff
        move    a,a1                      ;saturate a
        move    x:AGCC1,y0                ;read the filter coefficient
                                          ;  AGCC1 	
        mpy     y0,a1,a                   ;temp = energy*AGCC1
        move    x:AGCLP1,x0               ;read filter state 
        move    x:AGCC2,y0                ;read filter coefficient 
        mac     x0,y0,a                   ;perform
                                          ;  temp = temp+AGCLP1*AGCC2
        move    a,x:AGCLP1                ;store AGLP1
        move    a,a1                      ;clip a
        move    x:AGCC3,y0                ;read filter coefficient
        mpy     y0,a1,a                   ;perform
                                          ;  LPENERGY=AGCC3*temp
        move    x:AGCLP2,x0               ;read filter state from
                                          ;  memory
        move    x:AGCC4,y0                ;read filter coefficient
        mac     x0,y0,a                   ;perform
                                          ;  LPENERGY=LPENERGY +
                                          ;  AGCC4*AGCLP2
        move    a,x:AGCLP2                ;store filter state in memory
        tstw    x:CD1                     ;test if carrier was detected 
        jle     End_RXCDAGC               ;If carrier was not detected
                                          ;  abort AGC gain update 
        move    #$2000,x0                 ;move agcref to x0
        sub     x0,a                      ;perform
                                          ;  excess = LPENERGY - agcref
        tfr     a,b                       ;store a copy of excess in b
        abs     a                         ;compute the absolute value of
                                          ;  energy
        move    #$0800,x0                 ;move reference to x0
        cmp     x0,a                      ;check if (|excess| >= $0800)
        jlt     End_RXCDAGC               ;if not so, abort updating
        tst     b                         ;check if (excess > 0)
                                          ;if (excess <= 0) goto 
                                          ;  _NONPOSEXCESS
        jle     NONPOSEXCESS             

        sub     x0,b                      ;for positive excess
                                          ;  excess = excess - $0800
                                          ;goto _ASSIGNAGCG
        jmp     ASSIGNAGCG               

NONPOSEXCESS
        add     x0,b                      ;for negative excess
                                          ;  excess = excess + $0800

ASSIGNAGCG
        move    b,b1                      ;saturate b
        move    x:AGCLG,y1                ;read AGCLG from memory
        mpy     y1,b1,b                   ;b contains the product of
                                          ;  AGCLG and excess
        move    b,b1                      ;saturate b
        move    x:AGCG,y1                 ;read AGCG from memory
        mpyr    y1,b1,b                   ;b now contains product2 =
                                          ;  AGCG*excess*AGLCG
        move    x:AGCG,a                  ;read AGCG again
        sub     b,a                       ;perform
                                          ;  AGCG = AGCG - product2
        move    #$0080,x0                 ;move least value of AGCG 
                                          ;  into x0
        cmp     x0,a                      ;check if (AGCG < $0080)
        jge     ENDAGCUPDATE              ;if (AGCG >= $0080) goto
                                          ;  ENDAGCUPDATE  
        move    x0,a                      ;move lowest value of 
                                          ;  AGCG to x0
ENDAGCUPDATE
        move    a,x:AGCG                  ;move the updated AGCG
                                          ;  to memory
End_RXCDAGC
        move    #$ffff,m01
        jmp     rx_next_task                      

        ENDSEC
