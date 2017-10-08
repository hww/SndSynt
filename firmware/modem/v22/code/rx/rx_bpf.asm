;******************************** Module **********************************
;
;  Module Name     : rx_bpf
;  Author          : V.Shyam Sundar
;  Date of origin  : 09 Jan 96
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;*************************** Module Description ***************************
;
; This module bandpass filters the 12 input samples to 12 samples of I and 
; 12 samples of Q. The implementation of this module is based on Hilbert 
; transform computation. AGC gain is applied to the resulting filtered
; outputs.
;
; The energy of the last three samples of I and Q are computed and given
; as an output of this module
;
;************************** Calling Requirements **************************
;
;  1. The pointer x:BPF_PTR should be initialized to point to either
;     RXBPF22H or RXBPF22L depending on the channel of operation.
;
;  2. A buffer of length 48 to hold the band pass filter input values 
;     pointed to by x:RXFPTR
;
;  3. A buffer of length 24 to hold the band pass filter output values at
;     BPFOUT
;
;  4. A buffer of length 12 to hold the interpolator outputs (bpf inputs)
;     at RXSB
;
;
;*************************** Input and Output *****************************
;
;  Input   :
;           BPF_PTR is pointer to the bandpass filter coeffs. at x:BPF_PTR
;
;           RXSB(n) = | s.fff ffff | ffff ffff | in x:RXSB+k
;                                                   k = 0, 1, ..., 11
;
;           AGCG    = | s.fff ffff | ffff ffff | in x:AGCG
;
;           AGCG_SCALE is a macro variable denoting the scale factor for
;           the AGC gain factor.
;
;           RXFPTR is pointer to a modulo 48 buffer which forms the delay
;           line for the 48 long Band pass filter
;
;  Output  :
;           RXSBAG    =  | s.fff ffff | ffff ffff | in x:RXSBAG
;
;           BPFOUT(n) =  | s.fff ffff | ffff ffff | pointed by x:BPFOUT_PTR
;                                                   n = 1, 2, ..., 24
;
;*********************** Constants and tables used ************************
;
; 1. The pointer BPF_PTR points to the table of band pass filter coeffs.
;    RXBPF22H or RXBPF22L which are linear buffers of length 48
;
;******************************* Resources ********************************
;
;                        Cycle Count   :
;                        Program Words : 79
;                        NLOAC         : 67
;                                          
; Address Registers used: 
;                         r0 : to point to the modulo buffer pointed by
;                              RXFPTR
;                         r1 : to point to the input buffer RXSB
;                         r2 : to point to the bandpass filter output
;                              BPFOUT
;                         r3 : to point to the bandpass filter coeffs.
;
; Offset Registers used : 
;                          n : Used as an offset to the buffer pointed by
;                              x:RXFPTR
;
; No of do loops used   : 2
;
; No. of stack locations used : none
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
;      RXSBAG = 0
;
;      for i = 0 to 11
;
;          *RXFPTR = *RXSB++
;          filtptr = BPF_PTR
;
;          SumI = 0
;          SumQ = 0
;
;          for j = 0 to 47
;
;              SumI = SumI + (*RXFPTR)   * (*filtptr++)
;              SumQ = SumQ + (*RXFPTR--) * (*filtptr++)  
;
;          endfor
;
;          RXFPTR++
;
;          SumI = SumI << 1
;          SumQ = SumQ << 1
;
;          if i > 8
;
;              RXSBAG = RXSBAG + SumI*SumI + SumQ*SumQ
;
;          endif
;
;          SumI = SumI * (AGCG*AGCG_SCALE)
;          SumQ = SumQ * (AGCG*AGCG_SCALE)
;
;          *BPF_OUT++ = SumI
;          *BPF_OUT++ = SumQ
;
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

        include "rxmdmequ.asm"

        SECTION V22B_RX

        GLOBAL RXBPF

        org p:
	      
RXBPF 
	move    x:RXFPTR,r0               ;Init. pointer to mod 48 buffer
	move    x:BPFOUT_PTR,r2           ;Init. pointer to bpf outputs
	move    #RXSB,r1                  ;Init. pointer to bpf inputs.
	move    #47,m01                   ;Set r0 for modulo 48 addressing
	move    #0,n                      ;Set offset to decrement by one
	move    #0,x:RXSBAG               ;Initialize RXSBAG to zero

	do      #12,end_rx_bpf            ;Loop 12 times
	move    x:BPF_PTR,r3              ;Init. pointer to bpf filter
                                      ;  coeffs.
	clr     a                         ;SumI = 0
	move    x:(r1)+,y0    x:(r3)+,x0  ;Load interpolated value
                                      ;  Load filter coefficient
    clr     b             
	move    y0,x:(r0)-                ;  Put interpolated value in

;-----------------------------------------;        
; The filter coefficient buffer is linear ;
; and coeffs. are fetched in order        ;
; The RXSB buffer is a modulo 24 buffer   ;
; and values corresponding to previous    ;
; values of I and Q are fetched from this ;
; buffer by decrrementing the pointer in  ;
; the loop.                               ;
;-----------------------------------------;

    bfset   #$0300,sr

	lea     (sp)+                     ;Push the value of loop count
	move    la,x:(sp)+                ;  and loop address
	move    lc,x:(sp)                 ;

;For_CW: Changing label to sum
    do      #48,sum
	mac     y0,x0,a      x:(r0)+n,y1   x:(r3)+,x0   
                                      ;SumI = SumI + filtcoeff*ival
	mac     y0,x0,b      x:(r0)+n,y1   x:(r3)+,x0
                                      ;SumQ = SumQ + filtcoeff*ival
    move    x:(r0)-,y0

sum
	pop     lc                        ;Pop the saved loop count and
	pop     la                        ;  loop address

    bfclr   #$0200,sr

	asl     a            x:(r0)+,y0   ;SumI << 1
                                      ;  Dummy move to advance pointer
	asl     b            x:(r0)+,y0   ;SumQ << 1
                                      ;  Dummy move to advance pointer
	move    lc,y0                     ;Get the loop count
    move    #4,x0                     ;  than 4
    cmp     x0,y0     
	bgt     _agcbegin                 ;skip if lesser than 4
    move    a,x:temp1
    move    b,x:temp2
_agcbegin 
	move    x:AGCG,y0                 ;Get the AGC gain factor
	move    a0,y1                     ;Perform double precision
	move    a,x0                      ;  multiplication of
                                      ;  input buffer
	mpysu   y0,y1,a                   ;  SumI and AGCG
	move    a1,y1
	move    a2,a
	move    y1,a0
	mac     y0,x0,a

    move    #AGC_SCALE,x0 
	rep     #AGC_SCALE                ;Multiply with AGC scale factor
	asl     a                         ;
scale_up1

	rnd     a                         ;Round off SumI to 16 bits
	move    a,x:(r2)+                 ;Save output
	move    b0,y1
	move    b,x0
	mpysu   y0,y1,a                 
	move    a1,y1
	move    a2,a
	move    y1,a0
	mac     y0,x0,a
	move    lc,y0                     ;Get the loop count
    move    #4,x0
    cmp     x0,y0
	bgt     _endrxsbag                ;skip if lesser than 4
	move    x:temp1,y0                ;Get SumI
	move    x:RXSBAG,b                ;Get RXSBAG
	mac     y0,y0,b                   ;temp =  SumI*SumI+RXSBAG
	move    x:temp2,y0                ;Get SumQ
	macr    y0,y0,b                   ;RXSBAG = SumQ*SumQ+temp
	move    b,x:RXSBAG                ;Save RXSBAG
_endrxsbag

    move    #AGC_SCALE,x0
	rep     #AGC_SCALE                ;Multiply with AGC scale factor
	asl     a                         ;
scale_up2

	rnd     a
	move    a,x:(r2)+                 ;Save SumQ
end_rx_bpf
    move    r0,x:RXFPTR               ;Save RXFPTR
	move    #$ffff,m01                ;Set modifier register for linear
                                      ;  addressing
End_RXBPF
	jmp     rx_next_task              ;Jump to the next task

;**************************** Module Ends *********************************

        ENDSEC
