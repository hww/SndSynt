;******************************** Module **********************************
;
;  Module Name     : rx_baud
;  Author          : V.Shyam Sundar
;  Date of origin  : 16 Jan 96
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;*************************** Module Description ***************************
;
; In this module baud allignment is done so that the sample with maximum
; energy is centered in the baud. Early-Late gate synchronisation algorithm
; is used for this purpose.
;
; The first and the 3rd pair of samples of the output of the decimators are
; passed through the highpass filter. The energy of the outputs of the HPF
; are computed and the difference in the energy is lowpass filtered and
; accumulated. The accumulated value is compared with a threshold and if it
; exceeds then the sample correction is done by choosing a different 
; filterbank in the interpolation filter.
;
;************************** Calling Requirements **************************
;
;  1. x:BHPE1 and x:BHPE3 should be in consecutive memory locations
;
;  2. x:BHPX1 and x:BHPY1 x:BHPX3 and x:BHPY3 should be in consecutive 
;     memory locations
;
;  3. x:HPG1 and x:HPG2 should be in consecutive memory locations 
;
;  4. x:BLPG1 and x:BLPG2 should be in consecutive memory locations
;
;  5. x:BLP and x:BINTG should be in consecutive memory locations
;
;*************************** Input and Output *****************************
;
;  Input   :
;       
;       RXCBOUT_PTR : Output Pointer to the circular buffer RXCB in 
;                     x:RXCBOUT_PTR. It points to the starting location
;                     of the most recent baud.
;
;  Update  :
;       BHPX1,BHPX3 : The highpass filter states for the I channel for 1st
;                     and 3rd samples in x:BHPX1 and x:BHPX3
;
;       BHPY1,BHPY3 : The highpass filter states for the Q channel for 1st
;                     and 3rd samples in x:BHPY1 and x:BHPY3
;
;       BHPE1,BHPE3 : The energy of the first and 3rd pair of samples in
;                     x:BHPE1 and x:BHPE3
;
;       BLP         : The lowpass filter state in x:BLP
;
;       BINTG       : Integrator state in x:BINTG
;
;       BACC1,BACC2 : The accumulators which are compared with thresholds 
;                     in x:BACC1 and x:BACC2
;
;       IBCNT       : Counter to count the no. of samples received from
;                     codec 
;                     | 0000 xxxx | 0000 0000 |  in x:IBCNT
;
;       IFBANK      : The filter bank number which will be used in the 
;                     interpolation in next baud  
;                     | 0000 0000 | 00xx xxxx |  in x:IFBANK
;
;       DPHASE      : The carrier phase offset used in the demodulator
;                     in the next baud 
;                     | siii iiii | ffff ffff |  in x:DPHASE
;    
;  Output  :
;  
;       ICOEFF      : Pointer to the starting location of the 12 long 
;                     linear buffer which contains the interpolation filter
;                     coefficients in x:ICOEFF
;
;Note: The default format of data storage is | sfff ffff | ffff ffff |
;
;*********************** Constants and tables used ************************
;
;       HPG1,HPG2   : Higpass filter coefficients in x:HPG1 and x:HPG2
;
;       BLPG1,BLPG2 : Lowpass filter coefficients in x:BLPG1 and x:BLPG2
;
;       BOFF        : Offset coefficient in x:BOFF
;
;       BINTGA      : Integrator alpha (coefficient) in x:BINTGA
;
;Note1 : The default format of data storage is | sfff ffff | ffff ffff |
;
;Note2 : The constants BLPG1,BLPG2,BOFF and BINTGA takes different values
;        during handshaking phase and data phase
;
;******************************* Resources ********************************
;
;                        Cycle Count   :  561
;                        Program Words :  177
;                        NLOAC         :  140
;                                          
;
; Data Registers used   : a0  b0  x0  y0
;                         a1  b1      y1
;                         a2  b2
;
; Registers Changed     : a0  b0  x0  y0  r0  sr  pc
;                         a1  b1      y1  r1
;                         a2  b2          r2
;                                         r3
;
;***************************** Pseudo Code ********************************
;      
;    Begin
;
;      /* Highpass filter the baud edge samples */
;
;      rd_ptr  = RXCBOUT_PTR
;      wr_ptr  = BHPE1
;      xst_ptr = BHPX1
;      yst_ptr = BHPY1
;
;      baud_hpxy(rd_ptr, wr_ptr, xst_ptr, yst_ptr)
;
;      rd_ptr  = RXCBOUT_PTR+4
;      wr_ptr  = BHPE3
;      xst_ptr = BHPX3
;      yst_ptr = BHPY3
;
;      baud_hpxy(rd_ptr, wr_ptr, xst_ptr, yst_ptr)
;
;     /* Lowpass filtering the difference in the energy */
;
;     en_dif   = BHPE1 - BHPE3
;     temp     = BLPG1 * en_dif
;     temp     = temp  + BLP * BLPG2
;     BLP      = temp
;
;     /* Integration operation */
;
;     BINTG    = BINTG+BINTGA*temp
;     acc      = BINTG * (0x0020)
;     temp     = acc + temp*BOFF
;
;     /* Accumulation operation */
;
;     BACC1    = BACC1 + temp
;     abacc    = |BACC1| & (0xfff0)
;     if (abacc > 0)
;        if (abacc > 0x0070)
;           abacc = 0x0070           /* Limit to 0x0070 */
;        endif
;        abacc = abacc >> 4          /* abacc has nontrivial value only 
;                                       the last 3 bits */
;        if (BACC1 < 0)
;           abacc = -abacc
;        endif
;        BACC1 = 0
;     endif
;     
;     /* Compare with the threshold to decide if adjustment is nec. */
;
;     if (abacc != 0)
;        BACC2 = BACC2 + abacc       /* BACC2 is a finer counter whose 
;                                       inc/dec depends on abacc. This 
;                                       counter can take integer values
;                                       between -10 and +10*/
;        if (BACC2 >= 0)
;        temp  = BACC2 - 10
;        if (temp >= 0) 
;           IFBANK = (IFBANK + 1) & 0x003f   /* choose  next filter bank */ 
;           BACC2  = temp
;           if (IFBANK = 0)
;              IBCNT = IBCNT + $ff00   /* If IFBANK has wrapped around add
;                                         one sample */
;           endif
;           dphaseadj = 2/3 or 4/3 depending on calling or ans mode resp.
;       else
;           DONT DISTURB THE BAUD CLOCK
;       endif
;   else
;       temp = BACC2 + 10
;       if (temp <= 0)
;           direction = IFBANK -1
;           IFBANK = direction & 0x003f
;           if (direction < 0)
;                IBCNT = IBCNT + 0x0100 /*If IFBANK has wrapped around
;                                         one sample */
;           endif
;           dphaseadj = -2/3 or -4/3 depending on call. or ans. mode resp.
;       else
;           DONT DISTURB THE BAUD CLOCK
;       endif
;    endif
;    DPHASE = (DPHASE + dphaseadj) & 0xff00
;    Copy the Filterbank corresponding to IFBANK to the buffer pointed by
;      ICOEFF
;    End
;
;************************** Environment ***********************************
;
;       Assembler : ASM56800 version 6.0.0.0
;       Machine   : IBM PC
;       OS        : MSDOS 6.0
;
;**************************** Assembly Code *******************************
	
        SECTION V22B_RX 
     
        GLOBAL  RXBAUD

        org p:

RXBAUD 
;-----------------------------------------;        
; Highpass filtering the baud edge samples;
;-----------------------------------------;
	move    x:RXCBOUT_PTR,r0          ;Init. pointer to input buffer
	move    #29,m01                   ;Set to modulo addressing
	move    #BHPE1,r2                 ;Set pointer to wr_ptr
	move    #BHPX1,r1                 ;Set xst_ptr
	move    #HPG1,r3                  ;Set pointer to highpass filter
					  ;  coeffs.
	move    #-1,n                     ;Initialize offset to -1 for use
					  ;  in the subroutine baud_hpxy
	jsr     baud_hpxy                 ;Calculate energy BHPE1
	lea     (r0)+                     ;Adjust the rd_ptr to point to
	lea     (r0)+                     ;  the other end of the baud
	jsr     baud_hpxy                 ;Calculate the energy BHPE3
;-----------------------------------------;        
; Lowpass filtering the energy difference ;
;-----------------------------------------;
	move    #BLPG1,r1                 ;Set pointer to LPF coeffs.
	move    #BLP,r3                   ;Set pointer to LPF state
	lea     (r2)-                     ;Move pointer to x:BHPE3
	move    x:(r2)-,x0                ;Get BHPE3
	move    x:(r2),a                  ;Get BHPE1
	sub     x0,a         x:(r1)+,y0    x:(r3)+,x0
                                      ;en_dif = BHPE1 - BPHE3
                                      ;  Get BLPG1
                                      ;  Get BLP
	move    a,a                       ;Saturate accum.
	mpy     a1,y0,a      x:(r1)+,y0   ;temp = en_dif * BLPG1
                                      ;  Get BLPG2
	macr    y0,x0,a      x:(r3)+n,b   ;temp = temp + BLP*BLPG2
                                      ;  Get BINTG
;-----------------------------------------;        
; Integrating                             ;
;-----------------------------------------;
	move    a,a                       ;Saturate accum.
	move    #BACC1,r2                 ;Set pointer to BACC1
	move    x:BINTGA,y0               ;Get BINTGA
	macr    a1,y0,b      a,x:(r3)+    ;BINTG = BINTG + BINTGA*temp
                                      ;  Save BLP
	move    #$0020,y1                 ;Move constant $0020
	move    b,b                       ;Saturate accum.
	mpy     b1,y1,b      b,x:(r3)+    ;acc = BINTG >> 10
                                      ;  Save BINTG
	move    x:BOFF,y0                 ;Get BOFF
	macr    a1,y0,b      x:(r2)+,a    ;temp = temp*BOFF + acc
                                      ;  Get BACC1
;-----------------------------------------;
; Baud clock adjustment decision phase    ;
;-----------------------------------------;
	add     b,a          x:(r2)+n,x0  ;BACC1 = BACC1+temp
                                      ;  Dummy move to dec. pointer
	abs     a            a,x:(r2)+    ;|BACC1|
                                      ;  Save BACC1
	move    #$fff0,y0                 ;Move constant for truncating
                                      ;  |BACC1|
	and     y0,a                      ;abacc = |BACC1| & $fff0
	ble     _not_greater              ;If abacc <= 0 branch off
	move    #$0070,x0                 ;Move constant threshold value
	cmp     x0,a                      ;Check if abacc > threshold
    nop                               ;Workaround for the bug in this
                                      ;  revision of the proc
	tgt     x0,a                      ;If so limit abacc to #$0070
	move    #$0800,y0                 ;Move constant for shifting abacc
                                      ;  by 4 bits
	mpyr    a1,y0,a      x:(r2)+n,x0  ;abacc = abacc >> 4
                                      ;  Dummy move to dec. pointer
	move    #0,x0                     ;Move constant 0
	tfr     a,b                       ;Save abacc
	neg     a                         ;-abacc in accum.
                                      ;  Dummy move to dec. pointer
	tstw    x:(r2)                    ;Check if BACC1 < 0
	nop                               ;Workaround for the bug in this
                                      ;  revision of the proc
	tge     b,a                       ;If BACC1 > 0 abacc in accum.
	move    x0,x:(r2)+                ;BACC1=0
_not_greater
	tst     a            x:(r2)+,b    ;Check if abacc is zero
                                      ;  Get BACC2

    jeq     baud_end                  ;Branch off to the end of the
                                      ;  routine if abacc = 0
	add     a,b          x:(r2)+n,x0  ;BACC2 = BACC2 + abacc
                                      ;Dummy move to dec. pointer
	move    b,x:(r2)                  ;Save BACC2
	blt     _baud22                   ;If BACC2 lesser than zero
                                      ;  branch off
	move    #10,x0                    ;Move constant 10 from memory
	sub     x0,b                      ;temp = BACC2 - 10

    jlt     baud_end                  ; Branch off if temp < 0
	move    b,x:(r2)                  ;BACC2 = temp
	move    x:IFBANK,x0               ;Get IFBANK
	incw    x0                        ;Increment IFBANK
	move    #$3f,y0                   ;Get constant for mod 64 addition
	and     y0,x0                     ;Perform modulo operation
	move    x0,x:IFBANK               ;Save IFBANK
	move    sr,x:status               ;Disable interrupts
	orc     #3,sr
	move    x:IBCNT,b                 ;Get IBCNT
	tstw    x0                        ;Check if IFBANK = 0
    move    x:DPHADJ,a
	bne     _dphaseadj                ;If IFBANK != 0 skip
	move    #$ff00,a                  ;Get constant for updating IBCNT
	add     a,b                       ;IBCNT = IBCNT+$ff00
	move    b,x:IBCNT                 ;Save IBCNT
    move    x:DPHADJ,a
	bra     _dphaseadj
_baud22
	move    #10,y1                    ;Get constant 10
	add     y1,b                      ;temp = BACC2 + 10
    jgt     baud_end                  ;If temp > 0, do not disturb baud
                                      ;  clock (branch off)
	move    b,x:(r2)                  ;temp = BACC2
	move    x:IFBANK,x0               ;Get IFBANK
	decw    x0                        ;direction = IFBANK - 1
	move    #$3f,y0                   ;Constant for modulo 64 operation
	and     x0,y0                     ;Perform modulo operation
	move    y0,x:IFBANK               ;IFBANK = direction modulo 64
	move    sr,x:status               ;Disable interrupts
	orc     #3,sr
    move    x:DPHADJ,a
    neg     a
	tstw    x0                        ;Check direction
	bge     _dphaseadj                ;If direction >= 0 skip
	move    x:IBCNT,b                 ;Get IBCNT
	move    #$0100,a                  ;Get constant $0100
	add     a,b                       ;IBCNT = IBCNT + $0100
	move    b,x:IBCNT                 ;Save IBCNT
    move    x:DPHADJ,a
    neg     a
_dphaseadj
	move    x:status,sr               ;Enable interrupts
	move    x:DPHASE,b                ;Get DPHASE
 	add     a,b                       ;DPHASE = DPHASE +dphaseadj
	move    b1,x:DPHASE               ;Save dphaseadj
	move    #IFCOE,r1                 ;Set RD_PTR = IFCOE
	move    x:IFBANK,n                ;Load offset for RD_PTR
    nop
	lea     (r1)+n                    ;Set RD_PTR = IFCOE+IFBANK
	move    #ICOEFF,r3                ;Set WR_PTR
	move    #64,n                     ;Set offset to 64

    do      #6,wrfc6                  ;Write filter coefficients
    move    x:(r1)+n,y0               ;Fetch the filter coeff.
	move    y0,x:(r3)+                ;Write the filter coeff.
wrfc6

    move    #IFCOE,a
    move    #383,x0
    add     x0,a                      ;Set RD_PTR = IFCOE+383
	move    x:IFBANK,x0               ;Load offset for RD_PTR
	sub     x0,a                      ;Set RD_PTR = IFCOE-IFBANK
	move    a,r1                      ;Set RD_PTR
	move    #-64,n                    ;Set offset to -64

    do      #6,wrfc12                 ;Write filter coefficients
    move    x:(r1)+n,y0               ;Fetch the filter coeff
	move    y0,x:(r3)+                ;Write the filter coeff.
wrfc12
	nop

baud_end
End_RXBAUD
	jmp     rx_next_task              ;perform next task

;-----------------------------------------;        
; Subroutine : baud_hpxy                  ;
;              calculates BHPE1 and BHPE3 ;
;The transfer function of the High pass   ;
;  filter used is given as                ;
;                                         ;
;          HPG1(1-z^(-1))                 ;
; H(z) =   --------------                 ;
;         (1-HPG2*Z^(-1))                 ;
;-----------------------------------------;
baud_hpxy
	move    x:(r0)+,y0   x:(r3)+,x0   ;Get sample xval in temp
                                      ;  Get HPG1
	mpy     y0,x0,a      x:(r1)+,y0    x:(r3)-,x0
                                      ;temp = temp * HPG1
                                      ;  Get (*xptr)
                                      ;  Get HPG2
	macr    y0,x0,a      x:(r1)+n,x0  ;temp = temp + (*xptr)*HPG1
                                      ;  dummy move to dec. pointer
    move    a,x:(r1)+                 ;  (*xptr) = temp
	sub     y0,a                      ;tmp = temp - (*xptr)
					 
	move    a,y0                      ;Save tmp
	mpy     y0,y0,a                   ;enx = tmp*tmp
	move    x:(r0)+,y0    x:(r3)+,x0  ;Get sample yval in temp
                                      ;  Get HPG1
	mpy     y0,x0,b      x:(r1)+,y0    x:(r3)-,x0
                                      ;temp = temp * HPG1
                                      ;  Get (*yptr)
                                      ;  Get HPG2
	macr    y0,x0,b      x:(r1)+n,x0  ;temp = temp + (*yptr)*HPG1
                                      ;  dummy move to dec. pointer
    move    b,x:(r1)+
	sub     y0,b                      ;tmp = temp - (*yptr)
	move    b,y0                      ;Save tmp
	macr    y0,y0,a                   ;(*outptr) = enx*enx + eny*eny
                                      ;  where eny = tmp*tmp
	move    a,x:(r2)+                 ;save the energy calculated

end_baud_hpxy
	rts

;**************************** Module Ends *********************************

        ENDSEC
