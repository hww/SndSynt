;****************************** MODULE ************************************
;
; NAME OF THE MODULE: rx_car.asm
;             AUTHOR: N.R.SANJEEV
;     DATE OF ORIGIN: 01/30/1996
;  Modified By     : Mrinalini L  
;  Date            : 21 June 1999
;
;************************** MODULE DESCRIPTION ****************************
;
; This module low pass filters the phase error which is calculated in the
;equalization module. From the lowpass filtered error the cumulative
;phase error is computed which is used to update the carier phase.
;
;************************* CALLING REQUIREMENTS ***************************
;
;  NONE
;
;*********************** INPUT, OUTPUT AND UPDATES ************************
;
;  INPUT
;  (1) DP is the phase error which comes from the equalization error module
;      It is stored in the memory location x:DP 
;  
;  OUTPUT
;  (1) CDP is the cumulative phase error which comes from the equalization
;      error module. It is stored in the memory location x:CDP. 
;      CDP is interpretted as | siii iiii | ffff ffff |
;  
;  UPDATES
;  (1) CLP is the state of the first order IIR filter. It is stored in the
;      memory location x:CLP 
;  (2) COFF is the accumulated value. It is stored in the memory location
;      x:CLP 
;
;Note:
;  The default format of the data storage is | sfff ffff | ffff ffff | 
;  unless specified otherwise
;
;******************************* CONSTANTS ********************************
;
; (1)CARG1, which is an IIR filter coefficient, and in x:CARG1 
;    
; (2)CARG2, which is an IIR filter coefficient, and in x:CARG2.
;   
; (3)CARG3, which is a scaling coefficient, and in x:CARG3.
;  
; (4)CARG4, which is a scaling coefficient, and in x:CARG4.
; 
;
;Note1 : The default format of the data storage is | sfff ffff | ffff ffff | 
;        unless specified otherwise
; 
;Note2 : The constants CARG1,CARG2,CARG3 and CARG4 takes different values
;        during handshaking phase and data phase
;
;******************************* RESOURCES ********************************
;
;              CYCLE COUNT: 23
;            PROGRAM WORDS: 33
;                    NLOAC: 22   
;
;   Address Registers Used:  NONE
;   
;    Offset Registers Used:  NONE
;
;      Data Registers Used:  a0  b0  x0  y0
;                            a1  b1  
;                            a2  b2
;
;        Registers Changed:  a0  b0  x0  y0  sr
;                            a1  b1          pc
;                            a2  b2
;
;****************************** ENVIRONMENT *******************************
;
;   ASSEMBLER: Motorola DSP56800 Assembler Version 6.0.1.0
;   SIMULATOR: Motorola DSP56800 Simulator Version 6.0.33
;     MACHINE: SunSpar
;          OS: 4.1.3_U1
;
;****************************** PSEUDO CODE *******************************
;
; BEGIN
;      temp = DP*CARG1
;      temp = temp + CARG2*CLP
;      CLP = temp
;      COFF = COFF + temp*CARG4
;      temp2 = COFF*$0200
;      CDP = temp2 + CARG3*CLP
; END
;
;***************************** ASSEMBLY CODE ******************************

        SECTION V22B_RX

        GLOBAL  RXCAR

        org p:

RXCAR        
        move x:CARG1,x0                   ;Load CARG1 
        move x:DP,y0                      ;read DP
        mpy  x0,y0,a                      ;perform
                                          ;  temp = DP*CARG1
        move x:CARG2,x0                   ;Load CARG2
        move x:CLP,y0                     ;read CLP
        macr x0,y0,a                      ;perform
                                          ;  temp = temp + CARG2*CLP
        move a,x:CLP                      ;Update CLP with temp
        move a,a1                         ;Saturate a
        move x:CARG4,y0                   ;Load CARG4
        move x:COFF,b                     ;read COFF
        macr y0,a1,b                      ;perform
                                          ;  COFF = COFF + temp*CARG4
        move b,x0                         ;saturate COFF
        move b,x:COFF                     ;update COFF
        move #$0200,y0                  
        mpy  x0,y0,a                      ;perform
                                          ;  temp2 = COFF*$0200
        move x:CARG3,x0                    ;load CARG3
        move x:CLP,y0                     ;read CLP
        macr x0,y0,a                      ;perform
                                          ;  CDP = temp2 + CARG3*CLP
        move a,x:CDP                      ;update CDP

End_RXCAR
        jmp  rx_next_task                 ;go to the next task

        ENDSEC
