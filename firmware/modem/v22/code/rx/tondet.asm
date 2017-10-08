;******************************* Module **********************************
;
;  Module Name          : tondet.asm
;  Author               : Sanjay S. K.  
;  Date of origin       : 16 Jan 1996
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;************************* Module Description ****************************
;
;  This module does pure tone detection. The interpolated  
;  samples of A/D converter are filtered using a 4th order bandpass filter.
;  This bandpass filter is a cascade of 2 II order IIR filters. The o/p of 
;  this filter is then lowpass filtered using I order IIR LPF.
;
;            Symbols used  :
;                   PARAM  : Starting location of filter coefficient buffer
;                   DELAY  : Starting location of filter states buffer
;                   ALPHA  : Register having first filter coefficient
;                   INBUF  : Starting location of the input buffer
;    BETA2, BETA3, ALPHA3  : Filter coefficients
;
;************************* Calling Requirements **************************
; 
;  1. r1 points to the parameter buffer(linear) of length 3
;
;  2. r0 points to the filter state buffer(linear) of length 5
;
;  3. r3 points to the beginning of the input buffer of length 12 
;
;  4. m01 = $ffff to ensure both r0 and r1 to be in linear addressing mode.
;
;  5. The stack pointer should point to the last filled location. 
;     * Note : This module uses two stack locations *
;
;  6. The Filter coefficients ALPHA3, BETA2 and BETA3 should be assigned  
;     with proper values beore calling this subroutine. 
;
;  NOTE :
;     This module has one do loop, hence the calling module should take 
;     care of stack initializations and saving of la and lc registers.
;
;*********************** Inputs and Outputs *******************************
;
;  Input  :
;         1. INBUF(n)    = | s.fff ffff | ffff ffff |  n = 0,1,2 ..., 11
;                                                       
;         2. PARAM(n)    = | s.fff ffff | ffff ffff |  n = 0,1,2
;                                                        
;         3. DELAY(n)    = | s.fff ffff | ffff ffff |  n = 0,1,2,3,4
;                                                       
;         3. BETA2       = | s.fff ffff | ffff ffff | constant
;         4. BETA3       = | s.fff ffff | ffff ffff | constant
;         5. ALPHA3      = | s.fff ffff | ffff ffff | constant
;
;  Output : 
;            sum3  = | s.fff ffff | ffff ffff |  in a
;
;*********************** Tables and Constants *****************************
;
;             x:PARAM(1) = $01e0     /* Filter coefficients */
;             x:PARAM(2) = $e0c1         
;             x:PARAM(3) = $dd60
;                  BETA2 = $c0c3
;                  BETA3 = $7f1e
;                 ALPHA3 = $00e2 
;
;******************************* Resources ********************************
;
;                    Cycle Count   : 94
;                    Program Words : 34
;                    NLOAC         : 32
;
; Modifier register used : 
;                          None  
;
; Address Registers used : 
;                     r0 : Used as a pointer to the filter coefficient 
;                          buffer of length 3, in linear addressing mode
;                     r1 : Used as a pointer to the input buffer of length
;                          12 starting at INBUF
;                     r2 : temporary storage for r0
;                     r3 : Used as a pointer to filter states buffer of 
;                          length 5 in linear addressing mode 
;                     n  : used as an offset register
;
; Data Registers used    :
;                          a0  x0  y0
;                          a1      y1
;                          a2  
;
; Registers Changed      :  
;                          r0  a0  x0  y0  sr  n
;                          r1  a1      y1  pc
;                          r3  a2          sp
;
;**************************** Pseudo code *********************************
;
;                  TONEDETECT(PARAM,DELAY)      /* Subroutine */
;                                               /* Pure tone detection */
;         Begin
;                            
;            RD_PTR1 = PARAM                   
;            ALPHA = *RD_PTR1++
;
;            for i = 0 to 2
;               RD_PTR2 = DELAY
;               sum = (*INBUF++) * ALPHA         /* II order IIR BPF no 1 */
;               sum = sum + (*RD_PTR2++) * BETA2
;               temp = (*RD_PTR2--)
;               sum = sum + temp * (*RD_PTR1++)
;               sum = sum << 1
;               *RD_PTR2++ = temp
;               *RD_PTR2++ = sum
;
;               sum2 = sum * ALPHA              /* II order IIR BPF no 2 */
;               sum2 = sum2 + (*RD_PTR2++) * BETA2
;               temp = *RD_PTR2--
;               sum2 = sum2 + temp * (*RD_PTR1--)
;               sum2 = sum2 << 1
;               *RD_PTR2++ = temp
;               *RD_PTR2++ = sum2
;               
;               sum3 = | sum2 | * ALPHA3       /* I order IIR LPF */
;               sum3 = sum3 + (*RD_PTR2) * BETA3
;               *RD_PTR2 = sum3
;            endfor
;            return(sum3)
;
;         END
;                          
;************************** Environment ***********************************
;
;       Assembler : ASM56800 version 6.0.0.0
;       Machine   : IBM PC
;       OS        : MSDOS 6.0
;
;****************************** Assembly Code *****************************

        include "rxmdmequ.asm"

        SECTION V22B_RX 

        GLOBAL TONEDETECT

        org p:

TONEDETECT                                ;Label for calling this module as 
                                          ;  a subroutine
        move    #-1,n                     ;Offset for RD_PTR2
        move    r0,r2                     ;Save RD_PTR2 onto stack
        move    #BETA2,y0                 ;Get the filter coefficient

        do      #12,ENDIIR                ;Perform bandpass and lowpass 
                                          ;  filtering over 1 baud
        ;   /*  II order IIR BPF no 1  */

        move    x:(r1)+,y1   x:(r3)+,x0   ;Get INP(0) and PAR(0)
        mpy     y1,x0,a      x:(r0)+,y1   ;sum=PAR(0) * INP(0)
                                          ;  Get DEL(0)
        move    x0,b                      ;Save PAR(0)
        mac     y1,y0,a      x:(r0)+n,y1   x:(r3)+,x0
                                          ;sum=sum + DEL(0)*BETA2, 
                                          ;  get DEL(1) and PAR(1)
        mac     y1,x0,a      y1,x:(r0)+   ;sum = sum+DEL(1)*PAR(1), 
                                          ;  DEL(0) = DEL(1)
        asl     a                         ;sum = sum*2
        move    a,x:(r0)+                 ;DEL(1) = sum

       ;    /*  II order IIR BPF no 2  */

        move    a,y1                      ;Store sum 
        mpy     b1,y1,a     x:(r0)+,y1    ;sum2 = sum * PAR(0), Get DEL(2)
        mac     y1,y0,a     x:(r0)+n,y1    x:(r3)-,x0
                                          ;sum2=sum2+DEL(2)*BETA2 
                                          ;  Get DEL(3) and PAR(2)
        mac     y1,x0,a     y1,x:(r0)+    ;sum2=sum2 + DEL(3)*PAR(2)
                                          ;  DEL(2) = DEL(3)
        asl     a                         ;sum2=sum2*2

        ;    /*  I order IIR LPF  */

        abs     a           a,x:(r0)+     ;Find | sum2 |, DEL(3)= sum2
        move    #ALPHA3,y1                
        move    a,x0                      
        mpy     y1,x0,a                   ;sum3 = | sum2 | * ALPHA3
        move    #BETA3,x0                 
        move    x:(r0),y1                 ;Get DEL(4)
        mac     y1,x0,a     x:(r3)+n,x0   ;sum3=sum3+DEL(4)*BETA3, Dummy move
        move    a,x:(r0)                  ;DEL(4)= sum3

        move    r2,r0                     ;

ENDIIR                                   
End_TONEDET
        rts                               ;Return sum3 in acc a

        ENDSEC
