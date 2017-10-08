;******************************** Module **********************************
;
;  Module Name     : rx_demod
;  Author          : V.Shyam Sundar
;  Date of origin  : 04 Jan 96
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;*************************** Module Description ***************************
;
; This module computes the cumulative phase error, generates the cosine
; and sine values for demodulation and demodulates the input 12 I and 12 Q
; signals.
;
; The differential phase value from the baud loop (accumulated)approximated 
; to the nearest integer,is used as an offset to a 256 point sine table and 
; the phase error value is read off the table. The error value is linearly 
; interpolated with the reminder of the differential phase value to obtain 
; the cumulative phase error
;
; This error value in the phase is used to calculate the demodulation cos
; and sin values cos(w-phi) and sin(w-phi) where w is the 1200 Hz/2400 Hz
; value and phi is the error in the phase value.
;
; The samples from the bandpass filter are demodulated using the calculated
; sin and cos values
;
;************************** Calling Requirements **************************
;
;  1. The variable mdm_tbl_offset should be initialized to 3 if the modem
;     is in the CALLING mode and 1 if in the answering mode.
;
;*************************** Input and Output *****************************
;
;  Input   :
;           CPD     = | siii iiii. | ffff ffff | in x:CDP
;           DPHASE  = | siii iiii. | ffff ffff | in x:DPHASE
;           BPF_OUT = | s.fff ffff | ffff ffff | in x:BPF_OUT
;  Output  :
;           RXCB2A  = | s.fff ffff | ffff ffff | in x:RXCB2A
;
;******************************* Resources ********************************
;
;                        Cycle Count   :  561
;                        Program Words :  59
;                        NLOAC         :  48
;                                          
; Address Registers used: 
;                         r0 : to point to the modulo buffer MOD_TBL,
;                         r1 : to point to the modulo buffer SIN_TBL
;                         r2 : to point to the demodulator output at
;                              x:RXCB2A
;                         r3 : to point to the demodulator input buffer
;                              BPFOUT
;
; Offset Registers used : 
;                          n : Used as an offset to the buffers MOD_TBL
;                              SIN_TBL and BPF_OUT
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
;*********************** Constants and tables used ************************
;
; 1. A table of 24 alternate cosine and sine values of 1200 Hz sampled at
;    7200 Hz starting at x:MOD_TBL
;
; 2. A table of 256 sine values of 28.125 Hz sampled at 7200 Hz starting at
;    x:SIN_TBL
;
;***************************** Pseudo Code ********************************
;      
;    Begin
;
;      for i = 0 to 11
;
;          DPHASE = DPHASE + CDP
;
;          rem    = DPHASE % 256
;          offset = (DPHASE >> 8) & $00ff
;
;          sine1  = SIN_TBL(offset)
;          sine2  = SIN_TBL(offset+1)
;          sinphi = sine1 + (sine2-sine1)*rem
;
;          cos1   = SIN_TBL(offset+$0040)    
;          cos2   = SIN_TBL(offset+$0040+1)        
;          cosphi = cos1 + (cos2-cos1)*rem
;
;          cosw   = MOD_TBL(N++)      /* N is initially zero      */
;         -sinw   = MOD_TBL(N=N+n)    /* n = 1 if CALLING modem   */
;                                     /*   = 3 if ANSWERING modem */
;
;          COS    = cosphi*cosw - (-sinw)*sinphi
;         -SIN    = (-sinw)*cosphi + cosw*sinphi
;
;          X      = BPF_OUT(M++)      /* M is initially zero      */
;          Y      = BPF_OUT(M++)
;
;          RXCB2A(l++) = X*COS - Y*(-SIN)
;          RXCB2A(l++) = X*(-SIN) + Y*COS
;      Endfor
;
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


        GLOBAL RXDEMOD

        org p:

RXDEMOD 
	move    #BPF_OUT,r3               ;Init. pointer to demod inputs
	move    #RXCB2A,r2                ;Init. pointer to demod outputs
	move    #MOD_TBL,r0               ;Load address of carrier freq.
                                      ;  table.
	
	do      #12,end_rx_demod          ;Loop 12 times
	move    #$80ff,m01                ;r1 is set to mod 256 mode of
                                      ;  addressing
	move    x:CDP,a                   ;Load CDP from memory
    move    x:DPHASE,y0
    add     y0,a
	move    a1,x:DPHASE               ;Save DPHASE
                                      ;Note : if DPHASE overflows then
                                      ; the modulo value is stored
                                      ;REM & OFFSET
	move    #$0080,y0                 ;Load constant for DPHASE >> 8
	mpy     a1,y0,a                   ;rem = DPHASE%256 in a0
                                      ;  and offset = DPHASE>>8 in a1
	move    a0,y1                     ;Save the fractional part
	lsr     y1                        ;shift to get into 1.15 format
	bfclr   #$ff00,a                  ;Truncate offset to 8 LS bits
                                      ;  which is also a modulo 256
                                      ;  calculation
                                      ;SINPHI & COSPHI
	move    #SIN_TBL,y0               ;Get address of 256 point table
	add     a1,y0                     ;Point to the correct location
                                      ;  in the 256 point sine table
	move    y0,r1                     ;Load into the address register
	move    #$40-1,n                  ;Load offset register

	move    x:(r1)+,a                 ;sine1 = SIN_TBL(offset)
	move    x:(r1)+n,b                ;sine2 = SIN_TBL(offset+1)
	sub     a,b                       ;sine2-sine1 in y0
    move    b1,y0                     ;
	macr    y1,y0,a                   ;sinphi = sine1+(sine2-sine1)*rem

	move    x:(r1)+,b                 ;cos1 = SIN_TBL(offset+$40)
    move    a1,x0                     ;cos2-cos1 
	move    x:(r1)+,a                 ;cos2 = SIN_TBL(offset+$40+1)	
	sub     b,a                       ;cos2-cos1 in y0
    move    a1,y0
    move    x0,a                      ;Restore cos2-cos1
	move    #11,m01                   ;Set r0 to mod 12 addressing mode
                                      ;-SIN & COS
	macr    y1,y0,b                   ;cosphi = cos1+(cos2-cos1)*rem
    move    x:(r0)+,y0                ;  Get cosw from memory
    move    b,b                       ;Saturate the output
	move    x:mod_tbl_offset,n        ;Load offset to MOD_TBL
	mpyr    a1,y0,a                   ;sinphi*cosw 
	move    x:(r0)+n,y1               ;Get -sinw from memory
	macr    b1,y1,a                   ;-SIN = -sinw*cosphi+cosw*sinphi
    move    x0,n
    move    a,x0                      ;Save -SIN
    move    n,a                       ;Get cos2-cos1
    move    y0,n
    move    y1,y0                     ;Get -sinw
    move    n,y1                      ;Get cosw
	mpy     b1,y1,b                   ;cosw*cosphi in b
	macr    -a1,y0,b                  ;COS = sinw*sinphi+cosw*cosphi
	                                  ;DEMODULATE
    move    b,b                       ;Saturate the output
	move    x:(r3)+,y1                ;Get X
	mpy     b1,y1,a      x:(r3)+,y0   ;X*COS in a
                                      ;  Y in y0
	macr    -y0,x0,a                  ;X*COS-Y*-SIN
	mpy     y1,x0,a      a,x:(r2)+    ;X*-SIN in a
                                      ;  Get Y
	move    y0,y1                     ;Save Y
	macr    b1,y1,a                   ;Y*COS+X*-SIN in a
	move    a,x:(r2)+                 ;Save demodulated output
end_rx_demod
End_RXDEMOD 
    move    #$ffff,m01
    jmp     rx_next_task
;**************************** Module Ends *********************************

    ENDSEC
